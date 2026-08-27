import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/notification_import/application/draft_sync_service.dart';
import 'package:stutz/features/notification_import/application/notification_capture_providers.dart';
import 'package:stutz/features/notification_import/data/transaction_draft_repository.dart';

part 'notification_draft_sync.g.dart';

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
