import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';

void main() {
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

    group('totalMonthlyCalculated', () {
      test('leaf node monthly: returns own amount', () {
        final node = ExpenseNode(
          id: '1',
          name: 'Netflix',
          plannedAmount: 15.0,
          interval: PaymentInterval.monthly,
        );
        expect(node.totalMonthlyCalculated, 15.0);
      });

      test('leaf node yearly: returns amount / 12', () {
        final node = ExpenseNode(
          id: '1',
          name: 'Insurance',
          plannedAmount: 1200.0,
          interval: PaymentInterval.yearly,
        );
        expect(node.totalMonthlyCalculated, 100.0);
      });

      test('group node: sums children and ignores own amount', () {
        final child1 = ExpenseNode(
          id: 'c1',
          name: 'Miete',
          plannedAmount: 1000.0,
          interval: PaymentInterval.monthly,
        );
        final child2 = ExpenseNode(
          id: 'c2',
          name: 'Strom',
          plannedAmount: 600.0,
          interval: PaymentInterval.yearly, // = 50 per month
        );
        final group = ExpenseNode(
          id: 'root',
          name: 'Wohnen',
          plannedAmount: 99999.0, // should be ignored
          interval: PaymentInterval.monthly,
          children: [child1, child2],
        );
        expect(group.totalMonthlyCalculated, 1050.0);
      });
    });
  });
}
