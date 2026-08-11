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

  group('calculateHealth', () {
    test('positive balance when income > expenses', () {
      final sources = [makeIncome(amount: 5000)];
      final nodes = [makeExpense(plannedAmount: 3000)];
      final health = calc.calculateHealth(sources, nodes);
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
  });
}
