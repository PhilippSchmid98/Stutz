import 'package:collection/collection.dart';
import 'package:stutz/features/budget/domain/view_models/category_lookup.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/view_models/daily_transactions.dart';
import 'package:stutz/features/transactions/domain/view_models/transaction_with_category.dart';

/// Pure domain service for enriching and grouping transactions.
///
/// Consumes only the Budget feature's read-only category lookup contract.
class TransactionGrouper {
  const TransactionGrouper();

  /// Enriches [transactions] with category names via [categories] and groups
  /// them by day.
  ///
  /// The returned list is sorted newest-first within each day, and days are
  /// also ordered newest-first.
  List<DailyTransactions> groupByDay(
    List<AppTransaction> transactions,
    List<CategoryLookup> categories,
  ) {
    final categoriesById = <String, CategoryLookup>{
      for (final category in categories) category.id: category,
    };
    final sorted = [...transactions]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final enriched = sorted.map((txn) {
      final category = categoriesById[txn.expenseNodeId];
      return TransactionWithCategory(
        transaction: txn,
        categoryName: category?.name ?? 'Unknown',
        parentId: category?.parentId,
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
