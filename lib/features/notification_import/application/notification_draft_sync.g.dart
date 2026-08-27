// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_draft_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(synchronizeNotificationDrafts)
const synchronizeNotificationDraftsProvider =
    SynchronizeNotificationDraftsProvider._();

final class SynchronizeNotificationDraftsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const SynchronizeNotificationDraftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'synchronizeNotificationDraftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$synchronizeNotificationDraftsHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return synchronizeNotificationDrafts(ref);
  }
}

String _$synchronizeNotificationDraftsHash() =>
    r'9801058051f9a700edd1590ecb91d3a1de876441';
