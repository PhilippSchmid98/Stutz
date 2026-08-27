import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/domain/repositories/transaction_draft_store.dart';

/// Synchronizes device-captured drafts without allowing replay to alter review state.
class DraftSyncService {
  final NotificationCaptureGateway _captureGateway;
  final TransactionDraftStore _draftStore;

  const DraftSyncService({
    required NotificationCaptureGateway captureGateway,
    required TransactionDraftStore draftStore,
  }) : _captureGateway = captureGateway,
       _draftStore = draftStore;

  Future<void> synchronize(String userId) async {
    await _captureGateway.setActiveOwner(userId);
    await _captureGateway.captureActiveNotifications();
    final drafts = await _captureGateway.listUnsyncedDrafts();

    for (final draft in drafts) {
      await _draftStore.upsertCapturedDraft(draft);
    }

    if (drafts.isNotEmpty) {
      await _captureGateway.acknowledgeSyncedDrafts(
        drafts.map((draft) => draft.id).toList(),
      );
    }
  }
}
