import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/dashboard/domain/services/yearly_calculator.dart';
import 'package:stutz/features/dashboard/domain/view_models/yearly_budget_node.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';

part 'yearly_detail_provider.g.dart';

@riverpod
Future<List<YearlyBudgetNode>> yearlyDetailTree(Ref ref, int year) async {
  // Alle ref.watch()-Aufrufe synchron VOR dem ersten await.
  final rootNodesFuture = ref.watch(expenseTreeProvider.future);
  final allTxnsFuture = ref.watch(allTransactionsProvider.future);
  final rootNodes = await rootNodesFuture;
  final allTxns = await allTxnsFuture;

  return const YearlyCalculator().buildYearlyDetail(rootNodes, allTxns, year);
}
