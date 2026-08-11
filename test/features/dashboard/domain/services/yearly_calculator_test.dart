import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/dashboard/domain/services/yearly_calculator.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const calc = YearlyCalculator();

  group('calculateOffsetFactor', () {
    test('returns 0.0 when firstTxnDate is null', () {
      expect(calc.calculateOffsetFactor(2025, null), 0.0);
    });

    test('returns 0.0 when start is Jan 1', () {
      final date = DateTime(2025, 1, 1);
      expect(calc.calculateOffsetFactor(2025, date), 0.0);
    });

    test('returns ~0.5 when start is July 2 (midyear, non-leap)', () {
      final date = DateTime(2025, 7, 2);
      final factor = calc.calculateOffsetFactor(2025, date);
      expect(factor, greaterThan(0.49));
      expect(factor, lessThan(0.51));
    });
  });

  group('buildYearlyDetail', () {
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
      final node = makeExpense(
        id: 'e1',
        plannedAmount: 100,
        interval: PaymentInterval.monthly,
      );
      final result = calc.buildYearlyDetail([node], [], 2025);
      expect(result.first.planned, 1200.0);
    });

    test('actual spending aggregated from transactions in the given year', () {
      final node = makeExpense(id: 'e1', plannedAmount: 200);
      final txns = [
        makeTransaction(
          id: 't1',
          expenseNodeId: 'e1',
          amount: 40,
          dateTime: DateTime(2025, 3, 1),
        ),
        makeTransaction(
          id: 't2',
          expenseNodeId: 'e1',
          amount: 20,
          dateTime: DateTime(2024, 1, 1),
        ),
      ];
      final result = calc.buildYearlyDetail([node], txns, 2025);
      expect(result.first.actual, 40.0);
    });

    test('percentUsedReal calculated correctly', () {
      final node = makeExpense(
        id: 'e1',
        plannedAmount: 1200,
        interval: PaymentInterval.yearly,
      );
      final txn = makeTransaction(
        expenseNodeId: 'e1',
        amount: 600,
        dateTime: DateTime(2025, 6, 1),
      );
      final result = calc.buildYearlyDetail([node], [txn], 2025);
      expect(result.first.percentUsedReal, closeTo(0.5, 0.001));
    });
  });
}
