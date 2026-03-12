// Datei: test/domain/services/budget_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/budget_calculator.dart';
import '../../helpers/test_data.dart';

void main() {
  const calc = BudgetCalculator();

  // ---------------------------------------------------------------------------
  // totalMonthlyIncome
  // ---------------------------------------------------------------------------

  group('totalMonthlyIncome', () {
    test('returns 0 for empty list', () {
      expect(calc.totalMonthlyIncome([]), 0.0);
    });

    test('sums monthly incomes directly', () {
      final sources = [
        makeIncome(id: '1', amount: 5000, interval: PaymentInterval.monthly),
        makeIncome(id: '2', amount: 1000, interval: PaymentInterval.monthly),
      ];
      expect(calc.totalMonthlyIncome(sources), 6000.0);
    });

    test('divides yearly income by 12', () {
      final sources = [
        makeIncome(id: '1', amount: 12000, interval: PaymentInterval.yearly),
      ];
      expect(calc.totalMonthlyIncome(sources), 1000.0);
    });

    test('mixes monthly and yearly incomes correctly', () {
      final sources = [
        makeIncome(id: '1', amount: 3000, interval: PaymentInterval.monthly),
        makeIncome(id: '2', amount: 2400, interval: PaymentInterval.yearly), // = 200/month
      ];
      expect(calc.totalMonthlyIncome(sources), 3200.0);
    });
  });

  // ---------------------------------------------------------------------------
  // totalMonthlyExpenses
  // ---------------------------------------------------------------------------

  group('totalMonthlyExpenses', () {
    test('returns 0 for empty list', () {
      expect(calc.totalMonthlyExpenses([]), 0.0);
    });

    test('sums monthly leaf node amounts', () {
      final nodes = [
        makeExpense(id: 'e1', plannedAmount: 100, interval: PaymentInterval.monthly),
        makeExpense(id: 'e2', plannedAmount: 200, interval: PaymentInterval.monthly),
      ];
      expect(calc.totalMonthlyExpenses(nodes), 300.0);
    });

    test('yearly node amount divided by 12', () {
      final node = makeExpense(
        id: 'e1',
        plannedAmount: 1200,
        interval: PaymentInterval.yearly,
      );
      expect(calc.totalMonthlyExpenses([node]), 100.0);
    });

    test('group node sums its children (ignores own amount)', () {
      final child1 = makeExpense(id: 'c1', plannedAmount: 400.0, interval: PaymentInterval.monthly);
      final child2 = makeExpense(id: 'c2', plannedAmount: 600.0, interval: PaymentInterval.yearly); // 50/month
      final group = makeExpense(
        id: 'g',
        plannedAmount: 9999.0, // Should be ignored
        children: [child1, child2],
      );
      expect(calc.totalMonthlyExpenses([group]), closeTo(450.0, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // calculateHealth
  // ---------------------------------------------------------------------------

  group('calculateHealth', () {
    test('positive balance when income > expenses', () {
      final sources = [makeIncome(amount: 5000)];
      final nodes = [makeExpense(plannedAmount: 3000)];
      final health = calc.calculateHealth(sources, nodes);
      expect(health.income, 5000.0);
      expect(health.expenses, 3000.0);
      expect(health.balance, 2000.0);
      expect(health.isDeficit, isFalse);
    });

    test('isDeficit true when expenses > income', () {
      final sources = [makeIncome(amount: 1000)];
      final nodes = [makeExpense(plannedAmount: 2000)];
      final health = calc.calculateHealth(sources, nodes);
      expect(health.isDeficit, isTrue);
      expect(health.balance, -1000.0);
    });

    test('zero balance', () {
      final sources = [makeIncome(amount: 1000)];
      final nodes = [makeExpense(plannedAmount: 1000)];
      final health = calc.calculateHealth(sources, nodes);
      expect(health.balance, 0.0);
      expect(health.isDeficit, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // buildMonthlyDetail
  // ---------------------------------------------------------------------------

  group('buildMonthlyDetail', () {
    test('returns empty list when no transactions and no planned amounts', () {
      final node = makeExpense(id: 'e1', plannedAmount: null);
      final result = calc.buildMonthlyDetail([node], []);
      expect(result, isEmpty);
    });

    test('includes node with planned amount even without transactions', () {
      final node = makeExpense(id: 'e1', plannedAmount: 100);
      final result = calc.buildMonthlyDetail([node], []);
      expect(result, hasLength(1));
      expect(result.first.planned, 100.0);
      expect(result.first.actual, 0.0);
    });

    test('includes node with actual spending even without planned', () {
      final node = makeExpense(id: 'e1', plannedAmount: null);
      final txn = makeTransaction(expenseNodeId: 'e1', amount: 75);
      final result = calc.buildMonthlyDetail([node], [txn]);
      expect(result, hasLength(1));
      expect(result.first.actual, 75.0);
    });

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

    test('yearly planned amount divided by 12', () {
      final node = makeExpense(
        id: 'e1',
        plannedAmount: 1200,
        interval: PaymentInterval.yearly,
      );
      final result = calc.buildMonthlyDetail([node], []);
      expect(result.first.planned, closeTo(100.0, 0.001));
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
      final child = makeExpense(id: 'child', parentId: 'root', plannedAmount: 100);
      final root = makeExpense(id: 'root', plannedAmount: null, children: [child]);
      final txn = makeTransaction(expenseNodeId: 'child', amount: 60);
      final result = calc.buildMonthlyDetail([root], [txn]);
      expect(result.first.planned, 100.0);
      expect(result.first.actual, 60.0);
    });
  });

  // ---------------------------------------------------------------------------
  // calculateDashboardStats
  // ---------------------------------------------------------------------------

  group('calculateDashboardStats', () {
    test('returns empty stats for empty inputs', () {
      final result = calc.calculateDashboardStats([], [], monthCount: 3);
      expect(result, hasLength(3));
      for (final s in result) {
        expect(s.totalPlanned, 0.0);
        expect(s.totalSpent, 0.0);
      }
    });

    test('fixed nodes not included in planned total', () {
      final fixed = ExpenseNode(
        id: 'fixed',
        name: 'Rent',
        type: ExpenseType.fixed,
        plannedAmount: 1000,
        interval: PaymentInterval.monthly,
      );
      final result = calc.calculateDashboardStats([fixed], [], monthCount: 1);
      expect(result.first.totalPlanned, 0.0);
    });

    test('variable monthly node contributes to planned', () {
      final node = makeExpense(id: 'e1', plannedAmount: 500);
      final result = calc.calculateDashboardStats([node], [], monthCount: 1);
      expect(result.first.totalPlanned, 500.0);
    });

    test('transaction in matching month adds to totalSpent', () {
      final node = makeExpense(id: 'e1', plannedAmount: 200);
      final now = DateTime.now();
      final txn = makeTransaction(
        expenseNodeId: 'e1',
        amount: 75,
        dateTime: DateTime(now.year, now.month, 5),
      );
      final result = calc.calculateDashboardStats([node], [txn], monthCount: 1);
      expect(result.first.totalSpent, 75.0);
    });

    test('returns [monthCount] months', () {
      final result = calc.calculateDashboardStats([], [], monthCount: 6);
      expect(result, hasLength(6));
    });

    test('percentage computed correctly', () {
      final status = MonthlyBudgetStatus(
        month: DateTime(2025, 6),
        totalPlanned: 200,
        totalSpent: 100,
      );
      expect(status.percentage, 0.5);
      expect(status.remaining, 100.0);
    });

    test('percentage is 1.0 when spent > 0 and planned is 0', () {
      final status = MonthlyBudgetStatus(
        month: DateTime(2025, 6),
        totalPlanned: 0,
        totalSpent: 50,
      );
      expect(status.percentage, 1.0);
    });
  });
}
