// Datei: test/domain/services/transaction_grouper_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/transaction_grouper.dart';
import '../../helpers/test_data.dart';

void main() {
  const grouper = TransactionGrouper();

  group('groupByDay', () {
    test('returns empty list for empty transactions', () {
      expect(grouper.groupByDay([], []), isEmpty);
    });

    test('single transaction produces one DailyTransactions entry', () {
      final txn = makeTransaction(dateTime: DateTime(2025, 6, 15));
      final result = grouper.groupByDay([txn], []);
      expect(result, hasLength(1));
      expect(result.first.date, DateTime(2025, 6, 15));
      expect(result.first.totalAmount, txn.amount);
    });

    test('two transactions on the same day are grouped together', () {
      final t1 = makeTransaction(id: 't1', amount: 30, dateTime: DateTime(2025, 6, 15));
      final t2 = makeTransaction(id: 't2', amount: 20, dateTime: DateTime(2025, 6, 15));
      final result = grouper.groupByDay([t1, t2], []);
      expect(result, hasLength(1));
      expect(result.first.totalAmount, 50.0);
      expect(result.first.transactions, hasLength(2));
    });

    test('transactions on different days produce multiple entries', () {
      final t1 = makeTransaction(id: 't1', dateTime: DateTime(2025, 6, 15));
      final t2 = makeTransaction(id: 't2', dateTime: DateTime(2025, 6, 16));
      final result = grouper.groupByDay([t1, t2], []);
      expect(result, hasLength(2));
    });

    test('enriches transaction with category name from flatNodes', () {
      final node = makeExpense(id: 'e1', name: 'Groceries');
      final txn = makeTransaction(expenseNodeId: 'e1', dateTime: DateTime(2025, 6, 15));
      final result = grouper.groupByDay([txn], [node]);
      expect(result.first.transactions.first.categoryName, 'Groceries');
    });

    test('unknown expenseNodeId gets categoryName "Unknown"', () {
      final txn = makeTransaction(expenseNodeId: 'nonexistent', dateTime: DateTime(2025, 6, 15));
      final result = grouper.groupByDay([txn], []);
      expect(result.first.transactions.first.categoryName, 'Unknown');
    });

    test('groupName matches node parentId', () {
      final node = makeExpense(id: 'e1', parentId: 'parent1');
      final txn = makeTransaction(expenseNodeId: 'e1', dateTime: DateTime(2025, 6, 15));
      final result = grouper.groupByDay([txn], [node]);
      expect(result.first.transactions.first.groupName, 'parent1');
    });

    test('totalAmount sums all transactions in a day', () {
      final txns = [
        makeTransaction(id: 't1', amount: 10, dateTime: DateTime(2025, 6, 10)),
        makeTransaction(id: 't2', amount: 20, dateTime: DateTime(2025, 6, 10)),
        makeTransaction(id: 't3', amount: 15, dateTime: DateTime(2025, 6, 10)),
      ];
      final result = grouper.groupByDay(txns, []);
      expect(result.first.totalAmount, 45.0);
    });

    test('does not mutate original transaction list', () {
      final txns = [
        makeTransaction(id: 't1', dateTime: DateTime(2025, 6, 15)),
        makeTransaction(id: 't2', dateTime: DateTime(2025, 6, 14)),
      ];
      final originalOrder = txns.map((t) => t.id).toList();
      grouper.groupByDay(txns, []);
      // Verify the original list is unchanged
      expect(txns.map((t) => t.id).toList(), originalOrder);
    });
  });

  group('TransactionWithCategory', () {
    test('constructor assigns all fields', () {
      final txn = makeTransaction();
      final twc = TransactionWithCategory(
        transaction: txn,
        categoryName: 'Food',
        groupName: 'Living',
      );
      expect(twc.transaction, txn);
      expect(twc.categoryName, 'Food');
      expect(twc.groupName, 'Living');
    });

    test('groupName is nullable', () {
      final txn = makeTransaction();
      final twc = TransactionWithCategory(
        transaction: txn,
        categoryName: 'Food',
      );
      expect(twc.groupName, isNull);
    });
  });
}
