// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:stutz/domain/models/models.dart';
// import 'package:stutz/domain/services/budget_calculator.dart';
// import 'package:stutz/presentation/providers/budget_providers.dart';
// import 'package:stutz/presentation/providers/transaction_providers.dart';

// part 'dashboard_providers.g.dart';

// @riverpod
// Future<List<MonthlyBudgetStatus>> dashboardMonthlyStats(Ref ref) async {
//   // Alle ref.watch()-Aufrufe synchron VOR dem ersten await.
//   final rootNodesFuture = ref.watch(expenseTreeProvider.future);
//   final allTransactionsFuture = ref.watch(allTransactionsProvider.future);
//   final rootNodes = await rootNodesFuture;
//   final allTransactions = await allTransactionsFuture;

//   return const BudgetCalculator().calculateDashboardStats(
//     rootNodes,
//     allTransactions,
//   );
// }
