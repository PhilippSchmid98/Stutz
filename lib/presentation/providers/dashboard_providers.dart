import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/budget_calculator.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/presentation/providers/transaction_providers.dart';

part 'dashboard_providers.g.dart';

@riverpod
Future<List<MonthlyBudgetStatus>> dashboardMonthlyStats(Ref ref) async {
  final rootNodes = await ref.watch(expenseTreeProvider.future);
  final allTransactions = await ref.watch(allTransactionsProvider.future);

  return const BudgetCalculator().calculateDashboardStats(
    rootNodes,
    allTransactions,
  );
}
