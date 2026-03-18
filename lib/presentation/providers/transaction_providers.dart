// Datei: lib/presentation/providers/transaction_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/transaction_grouper.dart';
import 'package:stutz/domain/services/tree_builder.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';

part 'transaction_providers.g.dart';

@riverpod
class CurrentVisibleMonth extends _$CurrentVisibleMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void set(DateTime date) {
    state = date;
  }
}

/// Streams all transactions directly from Firestore — auto-updates on any
/// change without requiring manual [ref.invalidate] calls after mutations.
@riverpod
Stream<List<AppTransaction>> allTransactions(Ref ref) {
  return ref.watch(transactionRepositoryProvider).watchAllTransactions();
}

/// Groups transactions by day, derived from the reactive [allTransactionsProvider]
/// stream. Rebuilds automatically whenever Firestore data changes.
@riverpod
Future<List<DailyTransactions>> transactionList(Ref ref) async {
  // Alle ref.watch()-Aufrufe synchron VOR dem ersten await.
  final transactionsFuture = ref.watch(allTransactionsProvider.future);
  final rootNodesFuture = ref.watch(expenseTreeProvider.future);
  final transactions = await transactionsFuture;
  final rootNodes = await rootNodesFuture;
  final flatNodes = const TreeBuilder().flattenTree(rootNodes);
  return const TransactionGrouper().groupByDay(transactions, flatNodes);
}

@riverpod
List<DateTime> availableMonths(Ref ref) {
  final transactionsAsync = ref.watch(allTransactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final uniqueMonths = <DateTime>{};
      final now = DateTime.now();
      uniqueMonths.add(DateTime(now.year, now.month));

      for (var txn in transactions) {
        uniqueMonths.add(DateTime(txn.dateTime.year, txn.dateTime.month));
      }

      return uniqueMonths.toList()..sort((a, b) => a.compareTo(b));
    },
    loading: () => [DateTime(DateTime.now().year, DateTime.now().month)],
    error: (_, __) => [DateTime(DateTime.now().year, DateTime.now().month)],
  );
}

/// Handles transaction mutations (add, update, delete).
/// The [allTransactionsProvider] stream refreshes automatically after each
/// mutation — no manual [ref.invalidate] needed anywhere.
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
