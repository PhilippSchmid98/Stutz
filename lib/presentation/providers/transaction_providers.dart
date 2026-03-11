// Datei: lib/presentation/providers/transaction_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';

part 'transaction_providers.g.dart';

class TransactionWithCategory {
  final Transaction transaction;
  final String categoryName;
  final String? groupName;

  TransactionWithCategory({
    required this.transaction,
    required this.categoryName,
    this.groupName,
  });
}

class DailyTransactions {
  final DateTime date;
  final double totalAmount;
  final List<TransactionWithCategory> transactions;

  DailyTransactions({
    required this.date,
    required this.totalAmount,
    required this.transactions,
  });
}

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
    final allNodesFlat = _flattenNodes(rootNodes);

    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final enrichedList = transactions.map((txn) {
      final node = allNodesFlat.firstWhereOrNull(
        (n) => n.id == txn.expenseNodeId,
      );
      return TransactionWithCategory(
        transaction: txn,
        categoryName: node?.name ?? 'Unknown',
        groupName: node?.parentId,
      );
    }).toList();

    final groupedMap = groupBy(enrichedList, (item) {
      final dt = item.transaction.dateTime;
      return DateTime(dt.year, dt.month, dt.day);
    });

    return groupedMap.entries.map((entry) {
      return DailyTransactions(
        date: entry.key,
        totalAmount: entry.value.fold(
          0.0,
          (sum, t) => sum + t.transaction.amount,
        ),
        transactions: entry.value,
      );
    }).toList();
  }

  List<ExpenseNode> _flattenNodes(List<ExpenseNode> nodes) {
    final List<ExpenseNode> flatList = [];
    for (var node in nodes) {
      flatList.add(node);
      if (node.children.isNotEmpty) {
        flatList.addAll(_flattenNodes(node.children));
      }
    }
    return flatList;
  }

  Future<void> addTransaction(Transaction txn) async {
    await ref.read(transactionRepositoryProvider).addTransaction(txn);
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    ref.invalidateSelf();
  }
}
