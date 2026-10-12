import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

void main() {
  group('ExpenseNode', () {
    test('constructor assigns values', () {
      final node = ExpenseNode(
        id: '1',
        name: 'Food',
        plannedAmountMinor: 200,
        actualAmountMinor: 150,
      );
      expect(node.id, '1');
      expect(node.name, 'Food');
      expect(node.plannedAmountMinor, 200);
      expect(node.actualAmountMinor, 150);
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
      final a = ExpenseNode(id: '1', name: 'X', plannedAmountMinor: 100);
      final b = ExpenseNode(id: '1', name: 'X', plannedAmountMinor: 100);
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

    group('totalMonthlyEstimateMinor', () {
      test('leaf node monthly: returns own amount', () {
        final node = ExpenseNode(
          id: '1',
          name: 'Netflix',
          plannedAmountMinor: 15,
          interval: PaymentInterval.monthly,
        );
        expect(node.totalMonthlyEstimateMinor, 15);
      });

      test('leaf node yearly: returns amount / 12', () {
        final node = ExpenseNode(
          id: '1',
          name: 'Insurance',
          plannedAmountMinor: 1200,
          interval: PaymentInterval.yearly,
        );
        expect(node.totalMonthlyEstimateMinor, 100);
      });

      test('group node: sums children and ignores own amount', () {
        final child1 = ExpenseNode(
          id: 'c1',
          name: 'Miete',
          plannedAmountMinor: 1000,
          interval: PaymentInterval.monthly,
        );
        final child2 = ExpenseNode(
          id: 'c2',
          name: 'Strom',
          plannedAmountMinor: 600,
          interval: PaymentInterval.yearly, // = 50 per month
        );
        final group = ExpenseNode(
          id: 'root',
          name: 'Wohnen',
          plannedAmountMinor: 99999, // should be ignored
          interval: PaymentInterval.monthly,
          children: [child1, child2],
        );
        expect(group.totalMonthlyEstimateMinor, 1050);
      });
    });

    group('validateForWrite', () {
      test('accepts an empty group', () {
        expect(
          () => ExpenseNode(id: 'group', name: 'Housing').validateForWrite(),
          returnsNormally,
        );
      });

      test('rejects an incomplete leaf', () {
        expect(
          () => ExpenseNode(
            id: 'leaf',
            name: 'Housing',
            plannedAmountMinor: 100,
          ).validateForWrite(),
          throwsA(isA<ExpenseNodeValidationException>()),
        );
      });

      test('rejects non-positive leaf amounts', () {
        expect(
          () => ExpenseNode(
            id: 'leaf',
            name: 'Housing',
            plannedAmountMinor: 0,
            interval: PaymentInterval.monthly,
            type: ExpenseType.fixed,
          ).validateForWrite(),
          throwsA(isA<ExpenseNodeValidationException>()),
        );
      });
    });
  });
}
