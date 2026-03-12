// Datei: lib/presentation/providers/transaction_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/transaction_grouper.dart';
import 'package:stutz/domain/services/tree_builder.dart';
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

@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<DailyTransactions>> build() async {
    final transactions = await ref
        .watch(transactionRepositoryProvider)
        .getAllTransactions();
    final rootNodes = await ref
        .watch(expenseNodeRepositoryProvider)
        .getAllExpenseNodes();
    final flatNodes = const TreeBuilder().flattenTree(rootNodes);

    return const TransactionGrouper().groupByDay(transactions, flatNodes);
  }

  Future<void> addTransaction(AppTransaction txn) async {
    await ref.read(transactionRepositoryProvider).addTransaction(txn);
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    ref.invalidateSelf();
  }
}
