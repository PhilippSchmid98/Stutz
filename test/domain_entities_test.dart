import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';

void main() {
  group('IncomeSource', () {
    test('constructor assigns values', () {
      final source = IncomeSource(
        id: '1',
        name: 'Job',
        amount: 1000,
        interval: PaymentInterval.monthly,
        group: IncomeGroup.main,
      );
      expect(source.id, '1');
      expect(source.name, 'Job');
      expect(source.amount, 1000);
    });

    test('default interval is monthly', () {
      final s = IncomeSource(id: '1', name: 'X', amount: 100);
      expect(s.interval, PaymentInterval.monthly);
    });

    test('default group is main', () {
      final s = IncomeSource(id: '1', name: 'X', amount: 100);
      expect(s.group, IncomeGroup.main);
    });

    test('Freezed equality: same values are equal', () {
      final a = IncomeSource(id: '1', name: 'Job', amount: 1000);
      final b = IncomeSource(id: '1', name: 'Job', amount: 1000);
      expect(a, equals(b));
    });

    test('Freezed equality: different ids are not equal', () {
      final a = IncomeSource(id: '1', name: 'Job', amount: 1000);
      final b = IncomeSource(id: '2', name: 'Job', amount: 1000);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = IncomeSource(id: '1', name: 'Old', amount: 100);
      final modified = original.copyWith(name: 'New');
      expect(modified.name, 'New');
      expect(modified.id, '1');
      expect(original.name, 'Old');
    });
  });

  group('ExpenseNode', () {
    test('constructor assigns values', () {
      final node = ExpenseNode(
        id: '1',
        name: 'Food',
        plannedAmount: 200,
        actualAmount: 150,
      );
      expect(node.id, '1');
      expect(node.name, 'Food');
      expect(node.plannedAmount, 200);
      expect(node.actualAmount, 150);
      expect(node.children, isEmpty);
    });

    test('default sortOrder is 99999', () {
      final node = ExpenseNode(id: '1', name: 'X');
      expect(node.sortOrder, 99999);
    });

    test('isGroup returns true when children non-empty', () {
      final node = ExpenseNode(
        id: '1',
        name: 'X',
        children: [ExpenseNode(id: '2', name: 'Y')],
      );
      expect(node.isGroup, isTrue);
    });

    test('isGroup returns false when children empty', () {
      final node = ExpenseNode(id: '1', name: 'X', children: []);
      expect(node.isGroup, isFalse);
    });

    test('supports Group Node with null plannedAmount', () {
      final groupNode = ExpenseNode(
        id: 'group_1',
        name: 'Fixed Costs',
        plannedAmount: null,
        children: [],
      );
      expect(groupNode.plannedAmount, isNull);
      expect(groupNode.isGroup, isFalse);
    });

    test('Freezed equality: same values are equal', () {
      final a = ExpenseNode(id: '1', name: 'X', plannedAmount: 100);
      final b = ExpenseNode(id: '1', name: 'X', plannedAmount: 100);
      expect(a, equals(b));
    });

    test('Freezed equality: different values are not equal', () {
      final a = ExpenseNode(id: '1', name: 'X');
      final b = ExpenseNode(id: '2', name: 'X');
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = ExpenseNode(id: '1', name: 'Old');
      final modified = original.copyWith(name: 'New');
      expect(modified.name, 'New');
      expect(modified.id, '1');
      expect(original.name, 'Old');
    });
  });

  group('AppTransaction', () {
    test('constructor assigns values', () {
      final now = DateTime.now();
      final txn = AppTransaction(
        id: '1',
        expenseNodeId: '2',
        amount: 50,
        dateTime: now,
        note: 'Lunch',
      );
      expect(txn.id, '1');
      expect(txn.expenseNodeId, '2');
      expect(txn.amount, 50);
      expect(txn.dateTime, now);
      expect(txn.note, 'Lunch');
    });

    test('Freezed equality: same values are equal', () {
      final dt = DateTime(2025, 6, 15);
      final a = AppTransaction(
        id: '1',
        expenseNodeId: 'e1',
        amount: 50,
        dateTime: dt,
      );
      final b = AppTransaction(
        id: '1',
        expenseNodeId: 'e1',
        amount: 50,
        dateTime: dt,
      );
      expect(a, equals(b));
    });

    test('copyWith creates modified copy', () {
      final dt = DateTime(2025, 6, 15);
      final original = AppTransaction(
        id: '1',
        expenseNodeId: 'e1',
        amount: 50,
        dateTime: dt,
      );
      final modified = original.copyWith(amount: 99);
      expect(modified.amount, 99);
      expect(original.amount, 50);
    });
  });

  group('BudgetHealth', () {
    test('balance equals income minus expenses', () {
      final h = BudgetHealth(income: 5000, expenses: 3000);
      expect(h.balance, 2000.0);
    });

    test('isDeficit false when income >= expenses', () {
      expect(BudgetHealth(income: 1000, expenses: 1000).isDeficit, isFalse);
    });

    test('isDeficit true when expenses > income', () {
      expect(BudgetHealth(income: 1000, expenses: 1500).isDeficit, isTrue);
    });

    test('Freezed equality', () {
      final a = BudgetHealth(income: 5000, expenses: 3000);
      final b = BudgetHealth(income: 5000, expenses: 3000);
      expect(a, equals(b));
    });
  });

  group('MonthlyBudgetStatus', () {
    test('percentage computed correctly', () {
      final s = MonthlyBudgetStatus(
        month: DateTime(2025, 6),
        totalPlanned: 200,
        totalSpent: 100,
      );
      expect(s.percentage, 0.5);
      expect(s.remaining, 100.0);
    });

    test('percentage is 1.0 when planned is 0 but spent > 0', () {
      final s = MonthlyBudgetStatus(
        month: DateTime(2025, 6),
        totalPlanned: 0,
        totalSpent: 50,
      );
      expect(s.percentage, 1.0);
    });

    test('percentage is 0.0 when both are 0', () {
      final s = MonthlyBudgetStatus(
        month: DateTime(2025, 6),
        totalPlanned: 0,
        totalSpent: 0,
      );
      expect(s.percentage, 0.0);
    });

    test('Freezed equality', () {
      final a = MonthlyBudgetStatus(
        month: DateTime(2025, 6),
        totalPlanned: 200,
        totalSpent: 100,
      );
      final b = MonthlyBudgetStatus(
        month: DateTime(2025, 6),
        totalPlanned: 200,
        totalSpent: 100,
      );
      expect(a, equals(b));
    });
  });
}
