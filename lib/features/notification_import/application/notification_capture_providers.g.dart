// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_capture_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationCaptureGateway)
const notificationCaptureGatewayProvider =
    NotificationCaptureGatewayProvider._();

final class NotificationCaptureGatewayProvider
    extends
        $FunctionalProvider<
          NotificationCaptureGateway,
          NotificationCaptureGateway,
          NotificationCaptureGateway
        >
    with $Provider<NotificationCaptureGateway> {
  const NotificationCaptureGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationCaptureGatewayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationCaptureGatewayHash();

  @$internal
  @override
  $ProviderElement<NotificationCaptureGateway> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationCaptureGateway create(Ref ref) {
    return notificationCaptureGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationCaptureGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationCaptureGateway>(value),
    );
  }
}

String _$notificationCaptureGatewayHash() =>
    r'670a768b76c5531034a3584c902e1377c3dd9070';

@ProviderFor(notificationCaptureAccessGranted)
const notificationCaptureAccessGrantedProvider =
    NotificationCaptureAccessGrantedProvider._();

final class NotificationCaptureAccessGrantedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const NotificationCaptureAccessGrantedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationCaptureAccessGrantedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationCaptureAccessGrantedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return notificationCaptureAccessGranted(ref);
  }
}

String _$notificationCaptureAccessGrantedHash() =>
    r'737dbad28c83c4f1fbf573fc2ab588aabbe9b4b2';
