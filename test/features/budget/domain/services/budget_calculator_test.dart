import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/services/budget_calculator.dart';

import '../../../../helpers/test_data.dart';

void main() {
  const calc = BudgetCalculator();

  group('totalMonthlyIncomeMinor', () {
    test('returns 0 for empty list', () {
      expect(calc.totalMonthlyIncomeMinor([]), 0);
    });

    test('mixes monthly and yearly incomes correctly', () {
      final sources = [
        makeIncome(
          id: '1',
          amountMinor: 3000,
          interval: PaymentInterval.monthly,
        ),
        makeIncome(
          id: '2',
          amountMinor: 2400,
          interval: PaymentInterval.yearly,
        ),
      ];
      expect(calc.totalMonthlyIncomeMinor(sources), 3200);
    });
  });

  group('totalMonthlyExpensesMinor', () {
    test('group node sums its children (ignores own amount)', () {
      final child1 = makeExpense(
        id: 'c1',
        plannedAmountMinor: 400,
        interval: PaymentInterval.monthly,
      );
      final child2 = makeExpense(
        id: 'c2',
        plannedAmountMinor: 600,
        interval: PaymentInterval.yearly,
      );
      final group = makeExpense(
        id: 'g',
        plannedAmountMinor: 9999,
        children: [child1, child2],
      );
      expect(calc.totalMonthlyExpensesMinor([group]), 450);
    });
  });

  group('calculateSummary balance', () {
    test('positive balance when income > expenses', () {
      final sources = [makeIncome(amountMinor: 5000)];
      final nodes = [makeExpense(plannedAmountMinor: 3000)];
      final summary = calc.calculateSummary(sources, nodes);
      expect(summary.balanceMinor, 2000);
      expect(summary.isDeficit, isFalse);
    });

    test('isDeficit true when expenses > income', () {
      final sources = [makeIncome(amountMinor: 1000)];
      final nodes = [makeExpense(plannedAmountMinor: 2000)];
      final summary = calc.calculateSummary(sources, nodes);
      expect(summary.isDeficit, isTrue);
      expect(summary.balanceMinor, -1000);
    });
  });

  group('calculateSummary', () {
    test('calculates all displayed budget totals in one result', () {
      final sources = [
        makeIncome(amountMinor: 3000),
        makeIncome(
          id: 'yearly-income',
          amountMinor: 1200,
          interval: PaymentInterval.yearly,
        ),
      ];
      final roots = [
        makeExpense(
          id: 'fixed',
          plannedAmountMinor: 1200,
          type: ExpenseType.fixed,
        ),
        makeExpense(
          id: 'variable',
          plannedAmountMinor: 600,
          type: ExpenseType.variable,
          interval: PaymentInterval.yearly,
        ),
      ];

      final summary = calc.calculateSummary(sources, roots);

      expect(summary.averageMonthlyIncomeMinor, 3100);
      expect(summary.totalYearlyIncomeMinor, 37200);
      expect(summary.monthlyExpensesMinor, 1250);
      expect(summary.fixedMonthlyExpensesMinor, 1200);
      expect(summary.fixedYearlyExpensesMinor, 0);
      expect(summary.variableMonthlyExpensesMinor, 0);
      expect(summary.variableYearlyExpensesMinor, 600);
      expect(summary.fixedExpensesMinor, 1200);
      expect(summary.variableExpensesMinor, 50);
      expect(summary.balanceMinor, 1850);
      expect(summary.isDeficit, isFalse);
    });

    test('calculates raw monthly and yearly interval totals', () {
      final incomeTotals = calc.incomeIntervalTotals([
        makeIncome(amountMinor: 3000),
        makeIncome(
          id: 'yearly-income',
          amountMinor: 1200,
          interval: PaymentInterval.yearly,
        ),
      ]);
      final expenseTotals = calc.expenseIntervalTotals([
        makeExpense(plannedAmountMinor: 400),
        makeExpense(
          id: 'yearly-expense',
          plannedAmountMinor: 600,
          interval: PaymentInterval.yearly,
        ),
      ]);

      expect(incomeTotals.monthlyMinor, 3000);
      expect(incomeTotals.yearlyMinor, 1200);
      expect(expenseTotals.monthlyMinor, 400);
      expect(expenseTotals.yearlyMinor, 600);
    });

    test('rounds non-divisible annual minor units half away from zero', () {
      final summary = calc.calculateSummary([
        makeIncome(amountMinor: 10000, interval: PaymentInterval.yearly),
      ], []);

      expect(summary.yearlyIncomeMinor, 10000);
      expect(summary.averageMonthlyIncomeMinor, 833);
    });
  });
}
