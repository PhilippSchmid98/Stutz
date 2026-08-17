// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentVisibleMonth)
const currentVisibleMonthProvider = CurrentVisibleMonthProvider._();

final class CurrentVisibleMonthProvider
    extends $NotifierProvider<CurrentVisibleMonth, DateTime> {
  const CurrentVisibleMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentVisibleMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentVisibleMonthHash();

  @$internal
  @override
  CurrentVisibleMonth create() => CurrentVisibleMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentVisibleMonthHash() =>
    r'918be05bc0b0fae197a21b69eb379dbe206baabb';

abstract class _$CurrentVisibleMonth extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(availableMonths)
const availableMonthsProvider = AvailableMonthsProvider._();

final class AvailableMonthsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DateTime>>,
          List<DateTime>,
          FutureOr<List<DateTime>>
        >
    with $FutureModifier<List<DateTime>>, $FutureProvider<List<DateTime>> {
  const AvailableMonthsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableMonthsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableMonthsHash();

  @$internal
  @override
  $FutureProviderElement<List<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DateTime>> create(Ref ref) {
    return availableMonths(ref);
  }
}

String _$availableMonthsHash() => r'f494cad622446c41d67198cd3734b819fb7641a2';
