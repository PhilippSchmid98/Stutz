import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/budget/data/expense_node_repository.dart';
import 'package:stutz/features/budget/data/income_source_repository.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/services/budget_calculator.dart';
import 'package:stutz/features/budget/domain/services/tree_builder.dart';
import 'package:stutz/features/budget/domain/view_models/budget_health.dart';

part 'budget_providers.g.dart';

/// Streams expense nodes directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.
@riverpod
Stream<List<ExpenseNode>> expenseTree(Ref ref) {
  return ref.watch(expenseNodeRepositoryProvider).watchAllExpenseNodes();
}

/// Flattened (depth-first) view of the expense tree — this is the public
/// lookup API other features (e.g. Transactions) use for category enrichment,
/// so they never need to depend on the Budget data/repository layer directly.
@riverpod
Future<List<ExpenseNode>> flatExpenseNodes(Ref ref) async {
  final roots = await ref.watch(expenseTreeProvider.future);
  return const TreeBuilder().flattenTree(roots);
}

/// Streams income sources directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.
@riverpod
Stream<List<IncomeSource>> incomeList(Ref ref) {
  return ref.watch(incomeSourceRepositoryProvider).watchAllIncomeSources();
}

@riverpod
Future<double> totalMonthlyIncome(Ref ref) async {
  final sources = await ref.watch(incomeListProvider.future);
  return const BudgetCalculator().totalMonthlyIncome(sources);
}

@riverpod
Future<double> totalMonthlyExpenses(Ref ref) async {
  final roots = await ref.watch(expenseTreeProvider.future);
  return const BudgetCalculator().totalMonthlyExpenses(roots);
}

@riverpod
Future<BudgetHealth> budgetHealth(Ref ref) async {
  // Alle ref.watch()-Aufrufe synchron VOR dem ersten await.
  final sourcesFuture = ref.watch(incomeListProvider.future);
  final rootsFuture = ref.watch(expenseTreeProvider.future);
  final sources = await sourcesFuture;
  final roots = await rootsFuture;
  return const BudgetCalculator().calculateHealth(sources, roots);
}
