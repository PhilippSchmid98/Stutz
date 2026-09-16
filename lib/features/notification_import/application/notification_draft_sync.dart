import 'package:stutz/features/notification_import/application/draft_sync_service.dart';
import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/domain/repositories/transaction_draft_store.dart';

class NotificationDraftSynchronizer {
  final DraftSyncService _service;
  final void Function() _onSynchronized;
  Future<void>? _activeSynchronization;
  bool _synchronizationRequested = false;
  bool _isCancelled = false;

  NotificationDraftSynchronizer({
    required NotificationCaptureGateway captureGateway,
    required TransactionDraftStore draftStore,
    required void Function() onSynchronized,
  }) : _service = DraftSyncService(
         captureGateway: captureGateway,
         draftStore: draftStore,
       ),
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
      await _service.synchronize(userId, isCurrent: () => !_isCancelled);
      if (_isCancelled) return;
      _onSynchronized();
    } while (_synchronizationRequested && !_isCancelled);
  }
}
