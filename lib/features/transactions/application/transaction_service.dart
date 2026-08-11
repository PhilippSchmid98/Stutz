import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import '../domain/entities/app_transaction.dart';
import '../domain/services/transaction_grouper.dart';
import '../domain/view_models/daily_transactions.dart';
import '../data/transaction_repository.dart';

part 'transaction_service.g.dart';

@riverpod
Stream<List<AppTransaction>> allTransactions(Ref ref) {
  return ref.watch(transactionRepositoryProvider).watchAllTransactions();
}

@riverpod
Future<List<DailyTransactions>> transactionList(Ref ref) async {
  // Alle ref.watch()-Aufrufe synchron VOR dem ersten await.
  final transactionsFuture = ref.watch(allTransactionsProvider.future);
  final flatNodesFuture = ref.watch(
    flatExpenseNodesProvider.future,
  ); // Budget feature's public lookup API
  final transactions = await transactionsFuture;
  final flatNodes = await flatNodesFuture;

  return const TransactionGrouper().groupByDay(transactions, flatNodes);
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
