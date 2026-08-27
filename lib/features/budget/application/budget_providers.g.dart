// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

/// Flattened (depth-first) view of the expense tree — this is the public
/// lookup API other features (e.g. Transactions) use for category enrichment,
/// so they never need to depend on the Budget data/repository layer directly.

@ProviderFor(flatExpenseNodes)
const flatExpenseNodesProvider = FlatExpenseNodesProvider._();

/// Flattened (depth-first) view of the expense tree — this is the public
/// lookup API other features (e.g. Transactions) use for category enrichment,
/// so they never need to depend on the Budget data/repository layer directly.

final class FlatExpenseNodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseNode>>,
          List<ExpenseNode>,
          FutureOr<List<ExpenseNode>>
        >
    with
        $FutureModifier<List<ExpenseNode>>,
        $FutureProvider<List<ExpenseNode>> {
  /// Flattened (depth-first) view of the expense tree — this is the public
  /// lookup API other features (e.g. Transactions) use for category enrichment,
  /// so they never need to depend on the Budget data/repository layer directly.
  const FlatExpenseNodesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flatExpenseNodesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flatExpenseNodesHash();

  @$internal
  @override
  $FutureProviderElement<List<ExpenseNode>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExpenseNode>> create(Ref ref) {
    return flatExpenseNodes(ref);
  }
}

String _$flatExpenseNodesHash() => r'09aa5b807836dcf3151d0462d655aa00d4163041';

/// Read-only category contract for features that enrich transactions.

@ProviderFor(categoryLookups)
const categoryLookupsProvider = CategoryLookupsProvider._();

/// Read-only category contract for features that enrich transactions.

final class CategoryLookupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryLookup>>,
          List<CategoryLookup>,
          FutureOr<List<CategoryLookup>>
        >
    with
        $FutureModifier<List<CategoryLookup>>,
        $FutureProvider<List<CategoryLookup>> {
  /// Read-only category contract for features that enrich transactions.
  const CategoryLookupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryLookupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryLookupsHash();

  @$internal
  @override
  $FutureProviderElement<List<CategoryLookup>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryLookup>> create(Ref ref) {
    return categoryLookups(ref);
  }
}

String _$categoryLookupsHash() => r'f83a907d48cf997f0703afd28ea7e7cf92007a21';

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
    r'dc08bf33ba3dcdbb03c48faa82e9d226262d6b57';

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
    r'b31f5098773ae01ad24b82636c64691777dc0133';

@ProviderFor(budgetSummary)
const budgetSummaryProvider = BudgetSummaryProvider._();

final class BudgetSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BudgetSummary>,
          BudgetSummary,
          FutureOr<BudgetSummary>
        >
    with $FutureModifier<BudgetSummary>, $FutureProvider<BudgetSummary> {
  const BudgetSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetSummaryHash();

  @$internal
  @override
  $FutureProviderElement<BudgetSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BudgetSummary> create(Ref ref) {
    return budgetSummary(ref);
  }
}

String _$budgetSummaryHash() => r'47292a82fda65daf3cbf5b054c5f61dbf5abec57';
