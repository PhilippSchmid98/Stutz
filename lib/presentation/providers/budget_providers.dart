import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/logic_extensions.dart';
import 'package:stutz/domain/services/budget_calculator.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';

part 'budget_providers.g.dart';

@riverpod
Future<List<IncomeSource>> incomeList(Ref ref) {
  return ref.watch(incomeSourceRepositoryProvider).getAllIncomeSources();
}

@riverpod
Future<double> totalMonthlyIncome(Ref ref) async {
  final sources = await ref.watch(incomeListProvider.future);
  return sources.fold<double>(0.0, (sum, item) => sum + item.monthlyAmount);
}

@riverpod
Future<List<ExpenseNode>> expenseTree(Ref ref) {
  return ref.watch(expenseNodeRepositoryProvider).getAllExpenseNodes();
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
