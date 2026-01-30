// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

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
    extends $FunctionalProvider<List<DateTime>, List<DateTime>, List<DateTime>>
    with $Provider<List<DateTime>> {
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
  $ProviderElement<List<DateTime>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<DateTime> create(Ref ref) {
    return availableMonths(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DateTime>>(value),
    );
  }
}

String _$availableMonthsHash() => r'5f810a9c5febc07f2d487b1a4e42f829e2336607';

@ProviderFor(TransactionList)
const transactionListProvider = TransactionListProvider._();

final class TransactionListProvider
    extends $AsyncNotifierProvider<TransactionList, List<DailyTransactions>> {
  const TransactionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionListHash();

  @$internal
  @override
  TransactionList create() => TransactionList();
}

String _$transactionListHash() => r'126ef8d45e99f8ee82ddad847f9427bc15694a9a';

abstract class _$TransactionList
    extends $AsyncNotifier<List<DailyTransactions>> {
  FutureOr<List<DailyTransactions>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<DailyTransactions>>,
              List<DailyTransactions>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<DailyTransactions>>,
                List<DailyTransactions>
              >,
              AsyncValue<List<DailyTransactions>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
