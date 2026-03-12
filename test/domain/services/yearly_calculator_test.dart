// Datei: test/domain/services/yearly_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/yearly_calculator.dart';
import '../../helpers/test_data.dart';

void main() {
  const calc = YearlyCalculator();

  // ---------------------------------------------------------------------------
  // calculateOffsetFactor
  // ---------------------------------------------------------------------------

  group('calculateOffsetFactor', () {
    test('returns 0.0 when firstTxnDate is null', () {
      expect(calc.calculateOffsetFactor(2025, null), 0.0);
    });

    test('returns 0.0 when firstTxnDate is in a different year', () {
      final date = DateTime(2024, 6, 1);
      expect(calc.calculateOffsetFactor(2025, date), 0.0);
    });

    test('returns 0.0 when start is Jan 1', () {
      final date = DateTime(2025, 1, 1);
      expect(calc.calculateOffsetFactor(2025, date), 0.0);
    });

    test('returns ~0.5 when start is July 2 (midyear, non-leap)', () {
      // Day 183 of 365 → (183-1)/365 ≈ 0.4986
      final date = DateTime(2025, 7, 2); // 2025 is not a leap year
      final factor = calc.calculateOffsetFactor(2025, date);
      expect(factor, greaterThan(0.49));
      expect(factor, lessThan(0.51));
    });

    test('leap year: 366 days used in denominator', () {
      // Jan 2 in leap year 2024: (2-1)/366 ≈ 0.00273
      final date = DateTime(2024, 1, 2);
      final factor = calc.calculateOffsetFactor(2024, date);
      expect(factor, closeTo(1 / 366, 0.0001));
    });

    test('non-leap year: 365 days used in denominator', () {
      final date = DateTime(2025, 1, 2);
      final factor = calc.calculateOffsetFactor(2025, date);
      expect(factor, closeTo(1 / 365, 0.0001));
    });
  });

  // ---------------------------------------------------------------------------
  // buildYearlyDetail
  // ---------------------------------------------------------------------------

  group('buildYearlyDetail', () {
    test('returns empty list for empty inputs', () {
      expect(calc.buildYearlyDetail([], [], 2025), isEmpty);
    });

    test('fixed nodes are excluded', () {
      final fixed = ExpenseNode(
        id: 'fixed',
        name: 'Mortgage',
        type: ExpenseType.fixed,
        plannedAmount: 12000,
        interval: PaymentInterval.monthly,
      );
      expect(calc.buildYearlyDetail([fixed], [], 2025), isEmpty);
    });

    test('monthly planned amount multiplied by 12 for yearly total', () {
      final node = makeExpense(id: 'e1', plannedAmount: 100, interval: PaymentInterval.monthly);
      final result = calc.buildYearlyDetail([node], [], 2025);
      expect(result.first.planned, 1200.0);
    });

    test('yearly planned amount kept as-is', () {
      final node = makeExpense(id: 'e1', plannedAmount: 1200, interval: PaymentInterval.yearly);
      final result = calc.buildYearlyDetail([node], [], 2025);
      expect(result.first.planned, 1200.0);
    });

    test('actual spending aggregated from transactions in the given year', () {
      final node = makeExpense(id: 'e1', plannedAmount: 200);
      final txns = [
        makeTransaction(id: 't1', expenseNodeId: 'e1', amount: 40, dateTime: DateTime(2025, 3, 1)),
        makeTransaction(id: 't2', expenseNodeId: 'e1', amount: 60, dateTime: DateTime(2025, 9, 1)),
        makeTransaction(id: 't3', expenseNodeId: 'e1', amount: 20, dateTime: DateTime(2024, 1, 1)),
      ];
      final result = calc.buildYearlyDetail([node], txns, 2025);
      expect(result.first.actual, 100.0); // only 2025 transactions
    });

    test('node with no planned and no actual is pruned', () {
      final node = makeExpense(id: 'e1', plannedAmount: null);
      expect(calc.buildYearlyDetail([node], [], 2025), isEmpty);
    });

    test('offset applied for first year of usage', () {
      final node = makeExpense(id: 'e1', plannedAmount: 1200, interval: PaymentInterval.yearly);
      // First transaction on July 1 → about half year offset
      final txn = makeTransaction(expenseNodeId: 'e1', amount: 50, dateTime: DateTime(2025, 7, 1));
      final result = calc.buildYearlyDetail([node], [txn], 2025);
      expect(result.first.offset, greaterThan(500));
      expect(result.first.offset, lessThan(600));
    });

    test('offset is 0 when first transaction is in a different year', () {
      final node = makeExpense(id: 'e1', plannedAmount: 1200, interval: PaymentInterval.yearly);
      // Transactions from 2024 → for year 2025, offset = 0
      final oldTxn = makeTransaction(expenseNodeId: 'e1', amount: 10, dateTime: DateTime(2024, 1, 1));
      final newTxn = makeTransaction(expenseNodeId: 'e1', amount: 50, dateTime: DateTime(2025, 6, 1));
      final result = calc.buildYearlyDetail([node], [oldTxn, newTxn], 2025);
      expect(result.first.offset, 0.0);
    });

    test('children totals are aggregated into parent', () {
      final child = makeExpense(id: 'child', parentId: 'root', plannedAmount: 100);
      final root = makeExpense(id: 'root', plannedAmount: null, children: [child]);
      final txn = makeTransaction(expenseNodeId: 'child', amount: 50, dateTime: DateTime(2025, 6, 1));
      final result = calc.buildYearlyDetail([root], [txn], 2025);
      expect(result.first.planned, 1200.0); // 100 * 12
      expect(result.first.actual, 50.0);
    });

    test('percentUsedReal calculated correctly', () {
      final node = makeExpense(id: 'e1', plannedAmount: 1200, interval: PaymentInterval.yearly);
      final txn = makeTransaction(expenseNodeId: 'e1', amount: 600, dateTime: DateTime(2025, 6, 1));
      final result = calc.buildYearlyDetail([node], [txn], 2025);
      expect(result.first.percentUsedReal, closeTo(0.5, 0.001));
    });

    test('percentUsedReal is 0.0 when planned is 0', () {
      final node = makeExpense(id: 'e1', plannedAmount: null);
      final txn = makeTransaction(expenseNodeId: 'e1', amount: 50, dateTime: DateTime(2025, 6, 1));
      final result = calc.buildYearlyDetail([node], [txn], 2025);
      // plannedAmount null → ownPlanned = 0 → percentUsedReal = 0
      expect(result.first.percentUsedReal, 0.0);
    });
  });
}
