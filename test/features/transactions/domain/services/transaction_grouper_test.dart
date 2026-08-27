import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/view_models/category_lookup.dart';
import 'package:stutz/features/transactions/domain/services/transaction_grouper.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const grouper = TransactionGrouper();

  group('groupByDay', () {
    test('returns empty list for empty input', () {
      expect(grouper.groupByDay([], []), isEmpty);
    });

    test('enriches transaction with category name from flatNodes', () {
      const node = CategoryLookup(id: 'e1', name: 'Groceries');
      final txn = makeTransaction(id: 't1', expenseNodeId: 'e1', amount: 20);
      final result = grouper.groupByDay([txn], [node]);

      expect(result, hasLength(1));
      expect(result.first.transactions.first.categoryName, 'Groceries');
    });

    test('unknown category falls back to "Unknown"', () {
      final txn = makeTransaction(id: 't1', expenseNodeId: 'missing');
      final result = grouper.groupByDay([txn], []);
      expect(result.first.transactions.first.categoryName, 'Unknown');
    });

    test('groups multiple transactions on the same day together', () {
      const node = CategoryLookup(id: 'e1', name: 'Food');
      final txns = [
        makeTransaction(
          id: 't1',
          expenseNodeId: 'e1',
          amount: 10,
          dateTime: DateTime(2025, 6, 15, 8),
        ),
        makeTransaction(
          id: 't2',
          expenseNodeId: 'e1',
          amount: 20,
          dateTime: DateTime(2025, 6, 15, 18),
        ),
      ];
      final result = grouper.groupByDay(txns, [node]);

      expect(result, hasLength(1));
      expect(result.first.totalAmount, 30.0);
      expect(result.first.transactions, hasLength(2));
      // Newest-first within the day.
      expect(result.first.transactions.first.transaction.id, 't2');
    });

    test('days are sorted newest-first', () {
      final txns = [
        makeTransaction(id: 't1', dateTime: DateTime(2025, 1, 1)),
        makeTransaction(id: 't2', dateTime: DateTime(2025, 6, 1)),
      ];
      final result = grouper.groupByDay(txns, []);

      expect(result, hasLength(2));
      expect(result.first.date, DateTime(2025, 6, 1));
      expect(result.last.date, DateTime(2025, 1, 1));
    });
  });
}
