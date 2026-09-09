import 'package:flutter/services.dart';
import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/data/transaction_draft_mapper.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';

class MethodChannelNotificationCaptureGateway
    implements NotificationCaptureGateway {
  static const _channel = MethodChannel('ch.stutz.app/notification_capture');
  static const _events = EventChannel('ch.stutz.app/notification_capture_events');

  const MethodChannelNotificationCaptureGateway();

  @override
  bool get isSupported => true;

  @override
  Stream<void> get draftCapturedEvents => _events
      .receiveBroadcastStream()
      .map((event) {
        if (event != 'captured') {
          throw const FormatException('Notification capture returned an invalid event');
        }
      });

  @override
  Future<void> acknowledgeSyncedDrafts(List<String> draftIds) {
    return _channel.invokeMethod<void>('acknowledgeSyncedDrafts', {
      'draftIds': draftIds,
    });
  }

  @override
  Future<void> clearActiveOwner() {
    return _channel.invokeMethod<void>('clearActiveOwner');
  }

  @override
  Future<void> captureActiveNotifications() {
    return _channel.invokeMethod<void>('captureActiveNotifications');
  }

  @override
  Future<bool> hasNotificationAccess() async {
    return await _channel.invokeMethod<bool>('getNotificationAccessGranted') ??
        false;
  }

  @override
  Future<List<TransactionDraft>> listUnsyncedDrafts() async {
    final response = await _channel.invokeMethod<List<Object?>>(
      'listUnsyncedDrafts',
    );
    if (response == null) return [];

    return response.map((value) {
      if (value is! Map) {
        throw const FormatException(
          'Notification capture returned an invalid draft',
        );
      }
      final data = Map<String, dynamic>.from(value);
      final id = data.remove('id');
      if (id is! String || id.isEmpty) {
        throw const FormatException(
          'Notification capture returned a draft without an ID',
        );
      }
      return TransactionDraftMapper.fromPlatformData(id, data);
    }).toList();
  }

  @override
  Future<void> openNotificationAccessSettings() {
    return _channel.invokeMethod<void>('openNotificationAccessSettings');
  }

  @override
  Future<void> setActiveOwner(String userId) {
    return _channel.invokeMethod<void>('setActiveOwner', {'userId': userId});
  }
}

class UnsupportedNotificationCaptureGateway
    implements NotificationCaptureGateway {
  const UnsupportedNotificationCaptureGateway();

  @override
  bool get isSupported => false;

  @override
  Stream<void> get draftCapturedEvents => const Stream<void>.empty();

  @override
  Future<void> acknowledgeSyncedDrafts(List<String> draftIds) async {}

  @override
  Future<void> clearActiveOwner() async {}

  @override
  Future<void> captureActiveNotifications() async {}

  @override
  Future<bool> hasNotificationAccess() async => false;

  @override
  Future<List<TransactionDraft>> listUnsyncedDrafts() async => [];

  @override
  Future<void> openNotificationAccessSettings() async {}

  @override
  Future<void> setActiveOwner(String userId) async {}
}
