// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaginatedTransactionList)
const paginatedTransactionListProvider = PaginatedTransactionListProvider._();

final class PaginatedTransactionListProvider
    extends
        $AsyncNotifierProvider<
          PaginatedTransactionList,
          PaginatedTransactionsState
        > {
  const PaginatedTransactionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedTransactionListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedTransactionListHash();

  @$internal
  @override
  PaginatedTransactionList create() => PaginatedTransactionList();
}

String _$paginatedTransactionListHash() =>
    r'14fbfbf6ed0174ffde433c91f4bb0e0b1469882a';

abstract class _$PaginatedTransactionList
    extends $AsyncNotifier<PaginatedTransactionsState> {
  FutureOr<PaginatedTransactionsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedTransactionsState>,
              PaginatedTransactionsState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedTransactionsState>,
                PaginatedTransactionsState
              >,
              AsyncValue<PaginatedTransactionsState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

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
    r'b79905dc108193c7529f322468d727c51fa56faa';

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
