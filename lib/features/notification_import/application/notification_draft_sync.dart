import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/notification_import/application/draft_sync_service.dart';
import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/application/notification_capture_providers.dart';
import 'package:stutz/features/notification_import/data/transaction_draft_repository.dart';
import 'package:stutz/features/notification_import/domain/repositories/transaction_draft_store.dart';

part 'notification_draft_sync.g.dart';

class NotificationDraftSynchronizer {
  final DraftSyncService _service;
  final void Function() _onSynchronized;
  Future<void>? _activeSynchronization;
  bool _synchronizationRequested = false;

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

  Future<void> _drain(String userId) async {
    do {
      _synchronizationRequested = false;
      await _service.synchronize(userId);
      _onSynchronized();
    } while (_synchronizationRequested);
  }
}

@riverpod
Future<void> synchronizeNotificationDrafts(Ref ref) async {
  final gateway = ref.watch(notificationCaptureGatewayProvider);
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;

  if (user == null) {
    if (authState.hasValue) await gateway.clearActiveOwner();
    return;
  }

  final service = DraftSyncService(
    captureGateway: gateway,
    draftStore: ref.watch(transactionDraftRepositoryProvider),
  );
  await service.synchronize(user.uid);
}
