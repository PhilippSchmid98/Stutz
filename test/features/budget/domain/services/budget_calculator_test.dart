import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/services/budget_calculator.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const calc = BudgetCalculator();

  group('totalMonthlyIncome', () {
    test('returns 0 for empty list', () {
      expect(calc.totalMonthlyIncome([]), 0.0);
    });

    test('mixes monthly and yearly incomes correctly', () {
      final sources = [
        makeIncome(id: '1', amount: 3000, interval: PaymentInterval.monthly),
        makeIncome(id: '2', amount: 2400, interval: PaymentInterval.yearly),
      ];
      expect(calc.totalMonthlyIncome(sources), 3200.0);
    });
  });

  group('totalMonthlyExpenses', () {
    test('group node sums its children (ignores own amount)', () {
      final child1 = makeExpense(
        id: 'c1',
        plannedAmount: 400.0,
        interval: PaymentInterval.monthly,
      );
      final child2 = makeExpense(
        id: 'c2',
        plannedAmount: 600.0,
        interval: PaymentInterval.yearly,
      );
      final group = makeExpense(
        id: 'g',
        plannedAmount: 9999.0,
        children: [child1, child2],
      );
      expect(calc.totalMonthlyExpenses([group]), closeTo(450.0, 0.001));
    });
  });

  group('calculateSummary balance', () {
    test('positive balance when income > expenses', () {
      final sources = [makeIncome(amount: 5000)];
      final nodes = [makeExpense(plannedAmount: 3000)];
      final summary = calc.calculateSummary(sources, nodes);
      expect(summary.balance, 2000.0);
      expect(summary.isDeficit, isFalse);
    });

    test('isDeficit true when expenses > income', () {
      final sources = [makeIncome(amount: 1000)];
      final nodes = [makeExpense(plannedAmount: 2000)];
      final summary = calc.calculateSummary(sources, nodes);
      expect(summary.isDeficit, isTrue);
      expect(summary.balance, -1000.0);
    });
  });

  group('calculateSummary', () {
    test('calculates all displayed budget totals in one result', () {
      final sources = [
        makeIncome(amount: 3000),
        makeIncome(
          id: 'yearly-income',
          amount: 1200,
          interval: PaymentInterval.yearly,
        ),
      ];
      final roots = [
        makeExpense(id: 'fixed', plannedAmount: 1200, type: ExpenseType.fixed),
        makeExpense(
          id: 'variable',
          plannedAmount: 600,
          type: ExpenseType.variable,
          interval: PaymentInterval.yearly,
        ),
      ];

      final summary = calc.calculateSummary(sources, roots);

      expect(summary.monthlyIncome, 3100.0);
      expect(summary.monthlyExpenses, 1250.0);
      expect(summary.fixedExpenses, 1200.0);
      expect(summary.variableExpenses, 50.0);
      expect(summary.balance, 1850.0);
      expect(summary.isDeficit, isFalse);
    });

    test('calculates raw monthly and yearly interval totals', () {
      final incomeTotals = calc.incomeIntervalTotals([
        makeIncome(amount: 3000),
        makeIncome(
          id: 'yearly-income',
          amount: 1200,
          interval: PaymentInterval.yearly,
        ),
      ]);
      final expenseTotals = calc.expenseIntervalTotals([
        makeExpense(plannedAmount: 400),
        makeExpense(
          id: 'yearly-expense',
          plannedAmount: 600,
          interval: PaymentInterval.yearly,
        ),
      ]);

      expect(incomeTotals.monthly, 3000.0);
      expect(incomeTotals.yearly, 1200.0);
      expect(expenseTotals.monthly, 400.0);
      expect(expenseTotals.yearly, 600.0);
    });
  });
}
