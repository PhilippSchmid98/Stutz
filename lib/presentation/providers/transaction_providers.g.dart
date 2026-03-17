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

/// Streams all transactions directly from Firestore — auto-updates on any
/// change without requiring manual [ref.invalidate] calls after mutations.

@ProviderFor(allTransactions)
const allTransactionsProvider = AllTransactionsProvider._();

/// Streams all transactions directly from Firestore — auto-updates on any
/// change without requiring manual [ref.invalidate] calls after mutations.

final class AllTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTransaction>>,
          List<AppTransaction>,
          Stream<List<AppTransaction>>
        >
    with
        $FutureModifier<List<AppTransaction>>,
        $StreamProvider<List<AppTransaction>> {
  /// Streams all transactions directly from Firestore — auto-updates on any
  /// change without requiring manual [ref.invalidate] calls after mutations.
  const AllTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTransactionsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTransaction>> create(Ref ref) {
    return allTransactions(ref);
  }
}

String _$allTransactionsHash() => r'ec84642372f6cacb5f6df77387701e84918de184';

/// Groups transactions by day, derived from the reactive [allTransactionsProvider]
/// stream. Rebuilds automatically whenever Firestore data changes.

@ProviderFor(transactionList)
const transactionListProvider = TransactionListProvider._();

/// Groups transactions by day, derived from the reactive [allTransactionsProvider]
/// stream. Rebuilds automatically whenever Firestore data changes.

final class TransactionListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyTransactions>>,
          List<DailyTransactions>,
          FutureOr<List<DailyTransactions>>
        >
    with
        $FutureModifier<List<DailyTransactions>>,
        $FutureProvider<List<DailyTransactions>> {
  /// Groups transactions by day, derived from the reactive [allTransactionsProvider]
  /// stream. Rebuilds automatically whenever Firestore data changes.
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
  $FutureProviderElement<List<DailyTransactions>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DailyTransactions>> create(Ref ref) {
    return transactionList(ref);
  }
}

String _$transactionListHash() => r'd750641ca1f82049f7c86964f585f6a1b971b73f';

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

String _$availableMonthsHash() => r'485e37c4ea93d362c05a36c6b1170f4eb0d4ea99';

/// Handles transaction mutations (add, update, delete).
/// The [allTransactionsProvider] stream refreshes automatically after each
/// mutation — no manual [ref.invalidate] needed anywhere.

@ProviderFor(TransactionMutations)
const transactionMutationsProvider = TransactionMutationsProvider._();

/// Handles transaction mutations (add, update, delete).
/// The [allTransactionsProvider] stream refreshes automatically after each
/// mutation — no manual [ref.invalidate] needed anywhere.
final class TransactionMutationsProvider
    extends $AsyncNotifierProvider<TransactionMutations, void> {
  /// Handles transaction mutations (add, update, delete).
  /// The [allTransactionsProvider] stream refreshes automatically after each
  /// mutation — no manual [ref.invalidate] needed anywhere.
  const TransactionMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionMutationsHash();

  @$internal
  @override
  TransactionMutations create() => TransactionMutations();
}

String _$transactionMutationsHash() =>
    r'fb806308cd0dc294a732148f44ffb1d3e302c667';

/// Handles transaction mutations (add, update, delete).
/// The [allTransactionsProvider] stream refreshes automatically after each
/// mutation — no manual [ref.invalidate] needed anywhere.

abstract class _$TransactionMutations extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
