// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(incomeList)
const incomeListProvider = IncomeListProvider._();

final class IncomeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IncomeSource>>,
          List<IncomeSource>,
          FutureOr<List<IncomeSource>>
        >
    with
        $FutureModifier<List<IncomeSource>>,
        $FutureProvider<List<IncomeSource>> {
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
  $FutureProviderElement<List<IncomeSource>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<IncomeSource>> create(Ref ref) {
    return incomeList(ref);
  }
}

String _$incomeListHash() => r'883769cd24b2f6fee40b443a66098ff22ea8fea2';

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

@ProviderFor(expenseTree)
const expenseTreeProvider = ExpenseTreeProvider._();

final class ExpenseTreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseNode>>,
          List<ExpenseNode>,
          FutureOr<List<ExpenseNode>>
        >
    with
        $FutureModifier<List<ExpenseNode>>,
        $FutureProvider<List<ExpenseNode>> {
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
  $FutureProviderElement<List<ExpenseNode>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExpenseNode>> create(Ref ref) {
    return expenseTree(ref);
  }
}

String _$expenseTreeHash() => r'b459211c3974e86f477c4475a8f3adf908a33a94';

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
          AsyncValue<BudgetHealthState>,
          BudgetHealthState,
          FutureOr<BudgetHealthState>
        >
    with
        $FutureModifier<BudgetHealthState>,
        $FutureProvider<BudgetHealthState> {
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
  $FutureProviderElement<BudgetHealthState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BudgetHealthState> create(Ref ref) {
    return budgetHealth(ref);
  }
}

String _$budgetHealthHash() => r'db2184a6826f3a92f3116389aab925bf2db1f7cc';
