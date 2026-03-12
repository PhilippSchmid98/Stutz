import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/budget_calculator.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';

part 'monthly_detail_provider.g.dart';

@riverpod
Future<List<BudgetVsActualNode>> monthlyDetailTree(
  Ref ref,
  DateTime month,
) async {
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();

  final allTxns = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();
  final txnsInMonth = allTxns.where((t) {
    return t.dateTime.year == month.year && t.dateTime.month == month.month;
  }).toList();

  return const BudgetCalculator().buildMonthlyDetail(rootNodes, txnsInMonth);
}
