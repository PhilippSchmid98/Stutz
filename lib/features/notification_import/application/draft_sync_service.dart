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

  Future<void> synchronize(String userId, {bool Function()? isCurrent}) async {
    final shouldContinue = isCurrent ?? () => true;
    if (!shouldContinue()) return;
    await _captureGateway.setActiveOwner(userId);
    if (!shouldContinue()) return;
    await _captureGateway.captureActiveNotifications();
    if (!shouldContinue()) return;
    final drafts = await _captureGateway.listUnsyncedDrafts();

    for (final draft in drafts) {
      if (!shouldContinue()) return;
      await _draftStore.upsertCapturedDraft(draft);
    }

    if (drafts.isNotEmpty && shouldContinue()) {
      await _captureGateway.acknowledgeSyncedDrafts(
        drafts.map((draft) => draft.id).toList(),
      );
    }
  }
}
