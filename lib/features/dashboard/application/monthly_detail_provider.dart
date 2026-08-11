import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/dashboard/domain/services/dashboard_calculator.dart';
import 'package:stutz/features/dashboard/domain/view_models/budget_vs_actual_node.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';

part 'monthly_detail_provider.g.dart';

@riverpod
Future<List<BudgetVsActualNode>> monthlyDetailTree(
  Ref ref,
  DateTime month,
) async {
  // Alle ref.watch()-Aufrufe synchron VOR dem ersten await.
  final rootNodesFuture = ref.watch(expenseTreeProvider.future);
  final allTxnsFuture = ref.watch(allTransactionsProvider.future);
  final rootNodes = await rootNodesFuture;
  final allTxns = await allTxnsFuture;
  final txnsInMonth = allTxns.where((t) {
    return t.dateTime.year == month.year && t.dateTime.month == month.month;
  }).toList();

  return const DashboardCalculator().buildMonthlyDetail(rootNodes, txnsInMonth);
}
