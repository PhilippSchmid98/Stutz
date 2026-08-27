import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/data/notification_capture_method_channel.dart';

part 'notification_capture_providers.g.dart';

@riverpod
NotificationCaptureGateway notificationCaptureGateway(Ref ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return const UnsupportedNotificationCaptureGateway();
  }
  return const MethodChannelNotificationCaptureGateway();
}

@riverpod
Future<bool> notificationCaptureAccessGranted(Ref ref) {
  return ref.watch(notificationCaptureGatewayProvider).hasNotificationAccess();
}
