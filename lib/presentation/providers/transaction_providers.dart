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
  final transactions = await ref.watch(allTransactionsProvider.future);
  final rootNodes = await ref.watch(expenseTreeProvider.future);
  final flatNodes = const TreeBuilder().flattenTree(rootNodes);
  return const TransactionGrouper().groupByDay(transactions, flatNodes);
}

@riverpod
List<DateTime> availableMonths(Ref ref) {
  final transactionsAsync = ref.watch(transactionListProvider);

  return transactionsAsync.when(
    data: (dailyGroups) {
      if (dailyGroups.isEmpty) {
        final now = DateTime.now();
        return [DateTime(now.year, now.month)];
      }

      final uniqueMonths = <DateTime>{};
      final now = DateTime.now();
      uniqueMonths.add(DateTime(now.year, now.month));

      for (var group in dailyGroups) {
        uniqueMonths.add(DateTime(group.date.year, group.date.month));
      }

      final sortedMonths = uniqueMonths.toList()
        ..sort((a, b) => a.compareTo(b));

      return sortedMonths;
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
