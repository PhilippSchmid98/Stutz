// Datei: lib/presentation/providers/yearly_detail_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/yearly_calculator.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';

part 'yearly_detail_provider.g.dart';

@riverpod
Future<List<YearlyBudgetNode>> yearlyDetailTree(Ref ref, int year) async {
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();
  final allTxns = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();

  return const YearlyCalculator().buildYearlyDetail(rootNodes, allTxns, year);
}
