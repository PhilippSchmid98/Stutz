import 'package:collection/collection.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/view_models/daily_transactions.dart';
import 'package:stutz/features/transactions/domain/view_models/transaction_with_category.dart';

/// Pure domain service for enriching and grouping transactions.
///
/// Consumes [ExpenseNode] only for its id/name/parentId — the Budget feature
/// remains the sole owner of that data (Primary Owner pattern).
class TransactionGrouper {
  const TransactionGrouper();

  /// Enriches [transactions] with category names via [flatNodes] (already
  /// flattened — e.g. Budget's `flatExpenseNodesProvider`) and groups them by day.
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

    final days = groupedMap.entries.map((entry) {
      return DailyTransactions(
        date: entry.key,
        totalAmount: entry.value.fold(
          0.0,
          (sum, t) => sum + t.transaction.amount,
        ),
        transactions: entry.value,
      );
    }).toList();

    days.sort((a, b) => b.date.compareTo(a.date));
    return days;
  }
}
