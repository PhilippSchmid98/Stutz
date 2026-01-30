import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/logic_extensions.dart';

void main() {
  group('ExpenseLogic Extension (Calculation)', () {
    test('Leaf Node: returns own amount (Monthly)', () {
      final node = ExpenseNode(
        id: '1',
        name: 'Netflix',
        plannedAmount: 15.0,
        interval: 'Monthly',
      );
      expect(node.totalMonthlyCalculated, 15.0);
    });

    test('Leaf Node: returns amount / 12 (Yearly)', () {
      final node = ExpenseNode(
        id: '1',
        name: 'Insurance',
        plannedAmount: 1200.0,
        interval: 'Yearly',
      );
      expect(node.totalMonthlyCalculated, 100.0); // 1200 / 12
    });

    test('Group Node: sums children and ignores own amount', () {
      final child1 = ExpenseNode(
        id: 'c1',
        name: 'Miete',
        plannedAmount: 1000.0,
        interval: 'Monthly',
      );
      final child2 = ExpenseNode(
        id: 'c2',
        name: 'Strom',
        plannedAmount: 600.0,
        interval: 'Yearly', // = 50 pro Monat
      );

      final group = ExpenseNode(
        id: 'root',
        name: 'Wohnen',
        plannedAmount: 99999.0, // Sollte ignoriert werden!
        interval: 'Monthly',
        children: [child1, child2],
      );

      // Rechnung: 1000 (Miete) + 50 (Strom) = 1050
      expect(group.totalMonthlyCalculated, 1050.0);
    });

    test('Recursive Grouping: Sums grandchildren correctly', () {
      final grandchild = ExpenseNode(
        id: 'gc',
        name: 'Spotify',
        plannedAmount: 10.0,
        interval: 'Monthly',
      );
      final childGroup = ExpenseNode(
        id: 'c_group',
        name: 'Abos',
        children: [grandchild],
      );
      final root = ExpenseNode(
        id: 'root',
        name: 'Fixkosten',
        children: [childGroup],
      );

      expect(root.totalMonthlyCalculated, 10.0);
    });
  });
}
