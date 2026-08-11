import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/dashboard/domain/services/dashboard_calculator.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const calc = DashboardCalculator();

  group('buildMonthlyDetail', () {
    test('fixed nodes are excluded', () {
      final fixed = ExpenseNode(
        id: 'fixed',
        name: 'Mortgage',
        type: ExpenseType.fixed,
        plannedAmount: 1500,
        interval: PaymentInterval.monthly,
      );
      final result = calc.buildMonthlyDetail([fixed], []);
      expect(result, isEmpty);
    });

    test('transactions summed correctly for a node', () {
      final node = makeExpense(id: 'e1', plannedAmount: 200);
      final txns = [
        makeTransaction(id: 't1', expenseNodeId: 'e1', amount: 50),
        makeTransaction(id: 't2', expenseNodeId: 'e1', amount: 30),
      ];
      final result = calc.buildMonthlyDetail([node], txns);
      expect(result.first.actual, 80.0);
    });

    test('children totals are aggregated into parent', () {
      final child = makeExpense(
        id: 'child',
        parentId: 'root',
        plannedAmount: 100,
      );
      final root = makeExpense(
        id: 'root',
        plannedAmount: null,
        children: [child],
      );
      final txn = makeTransaction(expenseNodeId: 'child', amount: 60);
      final result = calc.buildMonthlyDetail([root], [txn]);
      expect(result.first.planned, 100.0);
      expect(result.first.actual, 60.0);
    });
  });

  group('calculateDashboardStats', () {
    test('returns stats for the requested month count', () {
      final result = calc.calculateDashboardStats([], [], monthCount: 3);
      expect(result, hasLength(3));
    });
  });
}
