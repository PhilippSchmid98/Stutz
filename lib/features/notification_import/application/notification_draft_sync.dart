import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';

class NotificationDraftSynchronizer {
  final NotificationCaptureGateway _captureGateway;
  final Future<void> Function(TransactionDraft) _upsertCapturedDraft;
  final void Function() _onSynchronized;
  Future<void>? _activeSynchronization;
  bool _synchronizationRequested = false;
  bool _isCancelled = false;

  NotificationDraftSynchronizer({
    required NotificationCaptureGateway captureGateway,
    required Future<void> Function(TransactionDraft) upsertCapturedDraft,
    required void Function() onSynchronized,
  }) : _captureGateway = captureGateway,
       _upsertCapturedDraft = upsertCapturedDraft,
       _onSynchronized = onSynchronized;

  Future<void> synchronize(String userId) {
    if (_isCancelled) return Future.value();

    final activeSynchronization = _activeSynchronization;
    if (activeSynchronization != null) {
      _synchronizationRequested = true;
      return activeSynchronization;
    }

    final synchronization = _drain(userId);
    _activeSynchronization = synchronization;
    synchronization.then(
      (_) => _clearActiveSynchronization(synchronization),
      onError: (_, __) => _clearActiveSynchronization(synchronization),
    );
    return synchronization;
  }

  void _clearActiveSynchronization(Future<void> synchronization) {
    if (identical(_activeSynchronization, synchronization)) {
      _activeSynchronization = null;
    }
  }

  void cancel() {
    _isCancelled = true;
    _synchronizationRequested = false;
  }

  Future<void> _drain(String userId) async {
    do {
      _synchronizationRequested = false;
      await _synchronizeDrafts(userId);
      if (_isCancelled) return;
      _onSynchronized();
    } while (_synchronizationRequested && !_isCancelled);
  }

  Future<void> _synchronizeDrafts(String userId) async {
    if (_isCancelled) return;
    await _captureGateway.setActiveOwner(userId);
    if (_isCancelled) return;
    await _captureGateway.captureActiveNotifications();
    if (_isCancelled) return;
    final drafts = await _captureGateway.listUnsyncedDrafts();

    for (final draft in drafts) {
      if (_isCancelled) return;
      await _upsertCapturedDraft(draft);
    }

    if (drafts.isNotEmpty && !_isCancelled) {
      await _captureGateway.acknowledgeSyncedDrafts(
        drafts.map((draft) => draft.id).toList(),
      );
    }
  }
}
