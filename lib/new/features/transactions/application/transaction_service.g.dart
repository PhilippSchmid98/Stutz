// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allTransactions)
const allTransactionsProvider = AllTransactionsProvider._();

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

@ProviderFor(transactionList)
const transactionListProvider = TransactionListProvider._();

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

String _$transactionListHash() => r'9f1779d733080c1706aaa80d9cdd8500545ed2b4';

@ProviderFor(TransactionMutations)
const transactionMutationsProvider = TransactionMutationsProvider._();

final class TransactionMutationsProvider
    extends $AsyncNotifierProvider<TransactionMutations, void> {
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
