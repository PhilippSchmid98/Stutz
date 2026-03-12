// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentUserId)
const currentUserIdProvider = CurrentUserIdProvider._();

final class CurrentUserIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  const CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserIdHash() => r'e72cfb0559323475253e573efd2f5ab2c0dadabb';

@ProviderFor(transactionRepository)
const transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  const TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'f64d86c54950c4703e4943b43efd26bec062e63e';

@ProviderFor(expenseNodeRepository)
const expenseNodeRepositoryProvider = ExpenseNodeRepositoryProvider._();

final class ExpenseNodeRepositoryProvider
    extends
        $FunctionalProvider<
          ExpenseNodeRepository,
          ExpenseNodeRepository,
          ExpenseNodeRepository
        >
    with $Provider<ExpenseNodeRepository> {
  const ExpenseNodeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseNodeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseNodeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExpenseNodeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpenseNodeRepository create(Ref ref) {
    return expenseNodeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseNodeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseNodeRepository>(value),
    );
  }
}

String _$expenseNodeRepositoryHash() =>
    r'edf78320685302466d0d1dca52f2aaaea342863e';

@ProviderFor(incomeSourceRepository)
const incomeSourceRepositoryProvider = IncomeSourceRepositoryProvider._();

final class IncomeSourceRepositoryProvider
    extends
        $FunctionalProvider<
          IncomeSourceRepository,
          IncomeSourceRepository,
          IncomeSourceRepository
        >
    with $Provider<IncomeSourceRepository> {
  const IncomeSourceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeSourceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeSourceRepositoryHash();

  @$internal
  @override
  $ProviderElement<IncomeSourceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IncomeSourceRepository create(Ref ref) {
    return incomeSourceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncomeSourceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncomeSourceRepository>(value),
    );
  }
}

String _$incomeSourceRepositoryHash() =>
    r'4967b3753dd28839b4d3a4844cfdd096fc56bbb1';
