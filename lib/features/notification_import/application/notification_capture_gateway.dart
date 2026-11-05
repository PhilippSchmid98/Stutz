import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';

abstract interface class NotificationCaptureGateway {
  bool get isSupported;

  Stream<void> get draftCapturedEvents;

  Future<bool> hasNotificationAccess();

  Future<void> openNotificationAccessSettings();

  Future<void> setActiveOwner(String userId);

  Future<void> captureActiveNotifications();

  Future<void> clearActiveOwner();

  Future<List<TransactionDraft>> listUnsyncedDrafts();

  Future<void> acknowledgeSyncedDrafts(List<String> draftIds);
}
