// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams income sources directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.

@ProviderFor(incomeList)
const incomeListProvider = IncomeListProvider._();

/// Streams income sources directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.

final class IncomeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IncomeSource>>,
          List<IncomeSource>,
          Stream<List<IncomeSource>>
        >
    with
        $FutureModifier<List<IncomeSource>>,
        $StreamProvider<List<IncomeSource>> {
  /// Streams income sources directly from Firestore — auto-updates on any change
  /// without requiring manual [ref.invalidate] calls after mutations.
  const IncomeListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeListHash();

  @$internal
  @override
  $StreamProviderElement<List<IncomeSource>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<IncomeSource>> create(Ref ref) {
    return incomeList(ref);
  }
}

String _$incomeListHash() => r'5406652a87c545b12c93e044b1659a668b69292c';

@ProviderFor(totalMonthlyIncome)
const totalMonthlyIncomeProvider = TotalMonthlyIncomeProvider._();

final class TotalMonthlyIncomeProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  const TotalMonthlyIncomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalMonthlyIncomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalMonthlyIncomeHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return totalMonthlyIncome(ref);
  }
}

String _$totalMonthlyIncomeHash() =>
    r'a925ddfa7046efc8d6f3190de5c277f39cb1ae69';

/// Streams expense nodes directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.

@ProviderFor(expenseTree)
const expenseTreeProvider = ExpenseTreeProvider._();

/// Streams expense nodes directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.

final class ExpenseTreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseNode>>,
          List<ExpenseNode>,
          Stream<List<ExpenseNode>>
        >
    with
        $FutureModifier<List<ExpenseNode>>,
        $StreamProvider<List<ExpenseNode>> {
  /// Streams expense nodes directly from Firestore — auto-updates on any change
  /// without requiring manual [ref.invalidate] calls after mutations.
  const ExpenseTreeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseTreeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseTreeHash();

  @$internal
  @override
  $StreamProviderElement<List<ExpenseNode>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ExpenseNode>> create(Ref ref) {
    return expenseTree(ref);
  }
}

String _$expenseTreeHash() => r'c0a0ba514cdbee400afe3b49d39414c2105d7d06';

@ProviderFor(totalMonthlyExpenses)
const totalMonthlyExpensesProvider = TotalMonthlyExpensesProvider._();

final class TotalMonthlyExpensesProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  const TotalMonthlyExpensesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalMonthlyExpensesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalMonthlyExpensesHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return totalMonthlyExpenses(ref);
  }
}

String _$totalMonthlyExpensesHash() =>
    r'3cf38cdef57389278e846859a11fd398d2b73bd3';

@ProviderFor(budgetHealth)
const budgetHealthProvider = BudgetHealthProvider._();

final class BudgetHealthProvider
    extends
        $FunctionalProvider<
          AsyncValue<BudgetHealth>,
          BudgetHealth,
          FutureOr<BudgetHealth>
        >
    with $FutureModifier<BudgetHealth>, $FutureProvider<BudgetHealth> {
  const BudgetHealthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetHealthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetHealthHash();

  @$internal
  @override
  $FutureProviderElement<BudgetHealth> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BudgetHealth> create(Ref ref) {
    return budgetHealth(ref);
  }
}

String _$budgetHealthHash() => r'80b186a061d25385df3fdcb9a2e07b6877a40d6b';
