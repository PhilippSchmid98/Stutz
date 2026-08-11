import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/dashboard/domain/services/dashboard_calculator.dart';
import 'package:stutz/features/dashboard/domain/view_models/monthly_budget_status.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';

part 'dashboard_providers.g.dart';

@riverpod
Future<List<MonthlyBudgetStatus>> dashboardMonthlyStats(Ref ref) async {
  // Alle ref.watch()-Aufrufe synchron VOR dem ersten await.
  final rootNodesFuture = ref.watch(expenseTreeProvider.future);
  final allTransactionsFuture = ref.watch(allTransactionsProvider.future);
  final rootNodes = await rootNodesFuture;
  final allTransactions = await allTransactionsFuture;

  return const DashboardCalculator().calculateDashboardStats(
    rootNodes,
    allTransactions,
  );
}
