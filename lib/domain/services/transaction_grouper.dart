import 'package:collection/collection.dart';
import 'package:stutz/domain/models/daily_transactions.dart';
import 'package:stutz/domain/models/expense_node.dart';
import 'package:stutz/domain/models/transaction.dart';
import 'package:stutz/domain/models/transaction_with_category.dart';

/// Pure domain service for enriching and grouping transactions.
class TransactionGrouper {
  const TransactionGrouper();

  /// Enriches [transactions] with category names via [flatNodes] (already
  /// flattened — use [TreeBuilder.flattenTree] first) and groups them by day.
  ///
  /// The returned list is sorted newest-first within each day, and days are
  /// also ordered newest-first.
  List<DailyTransactions> groupByDay(
    List<AppTransaction> transactions,
    List<ExpenseNode> flatNodes,
  ) {
    final sorted = [...transactions]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final enriched = sorted.map((txn) {
      final node = flatNodes.firstWhereOrNull((n) => n.id == txn.expenseNodeId);
      return TransactionWithCategory(
        transaction: txn,
        categoryName: node?.name ?? 'Unknown',
        groupName: node?.parentId,
      );
    }).toList();

    final groupedMap = groupBy(enriched, (item) {
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
}
