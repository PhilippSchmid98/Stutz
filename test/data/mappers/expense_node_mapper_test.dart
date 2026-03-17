// test/data/mappers/expense_node_mapper_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/data/mappers/expense_node_mapper.dart';
import 'package:stutz/domain/models/models.dart';

void main() {
  // ---------------------------------------------------------------------------
  // toFirestore
  // ---------------------------------------------------------------------------

  group('ExpenseNodeMapper.toFirestore', () {
    test('serializes all fields', () {
      final node = ExpenseNode(
        id: 'e1',
        parentId: 'p1',
        name: 'Rent',
        plannedAmount: 1200.0,
        interval: PaymentInterval.monthly,
        type: ExpenseType.fixed,
        sortOrder: 3,
      );
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['parentId'], 'p1');
      expect(map['name'], 'Rent');
      expect(map['plannedAmount'], 1200.0);
      expect(map['interval'], 'monthly');
      expect(map['type'], 'fixed');
      expect(map['sortOrder'], 3);
    });

    test('serializes yearly interval', () {
      final node = ExpenseNode(
        id: 'e1',
        name: 'Insurance',
        interval: PaymentInterval.yearly,
      );
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['interval'], 'yearly');
    });

    test('serializes variable type', () {
      final node = ExpenseNode(
        id: 'e1',
        name: 'Food',
        type: ExpenseType.variable,
      );
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['type'], 'variable');
    });

    test('serializes null interval and type as null', () {
      final node = ExpenseNode(id: 'e1', name: 'Group');
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['interval'], isNull);
      expect(map['type'], isNull);
    });

    test('serializes null plannedAmount', () {
      final node = ExpenseNode(id: 'e1', name: 'Group', plannedAmount: null);
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['plannedAmount'], isNull);
    });

    test('serializes null parentId', () {
      final node = ExpenseNode(id: 'e1', name: 'Root');
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['parentId'], isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // fromMap
  // ---------------------------------------------------------------------------

  group('ExpenseNodeMapper.fromMap', () {
    test('parses all fields correctly', () {
      final data = {
        'parentId': 'p1',
        'name': 'Groceries',
        'plannedAmount': 300.0,
        'interval': 'monthly',
        'type': 'variable',
        'sortOrder': 5,
      };
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.id, 'e1');
      expect(node.parentId, 'p1');
      expect(node.name, 'Groceries');
      expect(node.plannedAmount, 300.0);
      expect(node.interval, PaymentInterval.monthly);
      expect(node.type, ExpenseType.variable);
      expect(node.sortOrder, 5);
      expect(node.children, isEmpty);
    });

    test('parses yearly interval', () {
      final data = {'name': 'Insurance', 'interval': 'yearly'};
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.interval, PaymentInterval.yearly);
    });

    test('parses fixed type', () {
      final data = {'name': 'Mortgage', 'type': 'fixed'};
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.type, ExpenseType.fixed);
    });

    test(
      'backward compat: parses PascalCase interval (legacy Firestore docs)',
      () {
        final data = {'name': 'X', 'interval': 'Monthly'};
        final node = ExpenseNodeMapper.fromMap('e1', data);
        expect(node.interval, PaymentInterval.monthly);
      },
    );

    test('backward compat: parses PascalCase type (legacy Firestore docs)', () {
      final data = {'name': 'X', 'type': 'Fixed'};
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.type, ExpenseType.fixed);
    });

    test('unknown interval returns null', () {
      final data = {'name': 'X', 'interval': 'quarterly'};
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.interval, isNull);
    });

    test('unknown type returns null', () {
      final data = {'name': 'X', 'type': 'discretionary'};
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.type, isNull);
    });

    test('missing sortOrder defaults to 99999', () {
      final data = {'name': 'X'};
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.sortOrder, 99999);
    });

    test('missing name defaults to Unknown', () {
      final data = <String, dynamic>{};
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.name, 'Unknown');
    });

    test('null plannedAmount is preserved', () {
      final data = {'name': 'Group', 'plannedAmount': null};
      final node = ExpenseNodeMapper.fromMap('e1', data);
      expect(node.plannedAmount, isNull);
    });
  });
}
