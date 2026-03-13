import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/logic_extensions.dart';
import 'package:stutz/domain/services/budget_calculator.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';

part 'budget_providers.g.dart';

/// Streams income sources directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.
@riverpod
Stream<List<IncomeSource>> incomeList(Ref ref) {
  return ref.watch(incomeSourceRepositoryProvider).watchAllIncomeSources();
}

@riverpod
Future<double> totalMonthlyIncome(Ref ref) async {
  final sources = await ref.watch(incomeListProvider.future);
  return sources.fold<double>(0.0, (sum, item) => sum + item.monthlyAmount);
}

/// Streams expense nodes directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.
@riverpod
Stream<List<ExpenseNode>> expenseTree(Ref ref) {
  return ref.watch(expenseNodeRepositoryProvider).watchAllExpenseNodes();
}

@riverpod
Future<double> totalMonthlyExpenses(Ref ref) async {
  final roots = await ref.watch(expenseTreeProvider.future);
  return roots.fold<double>(
    0.0,
    (sum, node) => sum + node.totalMonthlyCalculated,
  );
}

@riverpod
Future<BudgetHealth> budgetHealth(Ref ref) async {
  final sources = await ref.watch(incomeListProvider.future);
  final roots = await ref.watch(expenseTreeProvider.future);
  return const BudgetCalculator().calculateHealth(sources, roots);
}
