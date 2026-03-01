import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/logic_extensions.dart';

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

class BudgetHealthState {
  final double income;
  final double expenses;
  final double balance;
  final bool isDeficit;

  BudgetHealthState({required this.income, required this.expenses})
    : balance = income - expenses,
      isDeficit = (income - expenses) < 0;
}

@riverpod
Future<BudgetHealthState> budgetHealth(Ref ref) async {
  final results = await Future.wait([
    ref.watch(totalMonthlyIncomeProvider.future),
    ref.watch(totalMonthlyExpensesProvider.future),
  ]);

  return BudgetHealthState(income: results[0], expenses: results[1]);
}
