import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/budget_calculator.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';

part 'dashboard_providers.g.dart';

@riverpod
Future<List<MonthlyBudgetStatus>> dashboardMonthlyStats(Ref ref) async {
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();
  final allTransactions = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();

  return const BudgetCalculator().calculateDashboardStats(
    rootNodes,
    allTransactions,
  );
}
