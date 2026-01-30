import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/domain/models/models.dart';

void main() {
  group('IncomeSource', () {
    test('constructor assigns values', () {
      final source = IncomeSource(
        id: '1',
        name: 'Job',
        amount: 1000,
        interval: 'Monthly',
        group: 'Main',
      );
      expect(source.id, '1');
      expect(source.name, 'Job');
      expect(source.amount, 1000);
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
  });

  group('Transaction', () {
    test('constructor assigns values', () {
      final now = DateTime.now();
      final txn = Transaction(
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
  });
  test('supports Group Node (null amount)', () {
    final groupNode = ExpenseNode(
      id: 'group_1',
      name: 'Fixed Costs',
      plannedAmount: null, // Teste explizit null
      children: [],
    );
    expect(groupNode.plannedAmount, isNull);
    expect(
      groupNode.isGroup,
      isFalse,
    ); // False, weil children leer sind (Logik getter)
  });
}
