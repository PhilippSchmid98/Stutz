import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/services/transaction_grouper.dart';
import 'package:stutz/domain/services/tree_builder.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import '../domain/entities/app_transaction.dart';
import '../domain/view_models/daily_transactions.dart';
import '../data/transaction_repository.dart';

// Import ins Budget-Feature ist ERLAUBT, weil wir nur den Provider rufen!
//import '../../budget/application/budget_providers.dart';

part 'transaction_service.g.dart';

@riverpod
Stream<List<AppTransaction>> allTransactions(Ref ref) {
  return ref.watch(transactionRepositoryProvider).watchAllTransactions();
}

@riverpod
Future<List<DailyTransactions>> transactionList(Ref ref) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  final rootNodes = await ref.watch(
    expenseTreeProvider.future,
  ); // Aus dem Budget-Feature

  // Deine Logik bleibt exakt gleich!
  final flatNodes = const TreeBuilder().flattenTree(rootNodes);
  //return const TransactionGrouper().groupByDay(transactions, flatNodes);
  return [];
}

@riverpod
class TransactionMutations extends _$TransactionMutations {
  @override
  FutureOr<void> build() {}

  Future<void> addTransaction(AppTransaction txn) async {
    await ref.read(transactionRepositoryProvider).addTransaction(txn);
  }

  Future<void> updateTransaction(AppTransaction txn) async {
    await ref.read(transactionRepositoryProvider).updateTransaction(txn);
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
  }
}
