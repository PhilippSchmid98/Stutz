// // Datei: lib/presentation/providers/yearly_detail_provider.dart
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:stutz/domain/models/models.dart';
// import 'package:stutz/domain/services/yearly_calculator.dart';
// import 'package:stutz/presentation/providers/repository_providers.dart';

// part 'yearly_detail_provider.g.dart';

// @riverpod
// Future<List<YearlyBudgetNode>> yearlyDetailTree(Ref ref, int year) async {
//   // Alle ref.watch()-Aufrufe synchron VOR dem ersten await.
//   final expenseRepo = ref.watch(expenseNodeRepositoryProvider);
//   final txnRepo = ref.watch(transactionRepositoryProvider);
//   final rootNodes = await expenseRepo.getAllExpenseNodes();
//   final allTxns = await txnRepo.getAllTransactions();

//   return const YearlyCalculator().buildYearlyDetail(rootNodes, allTxns, year);
// }
