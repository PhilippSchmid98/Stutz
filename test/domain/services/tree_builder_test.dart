// Datei: test/domain/services/tree_builder_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/services/tree_builder.dart';
import '../../helpers/test_data.dart';

void main() {
  const builder = TreeBuilder();

  // ---------------------------------------------------------------------------
  // buildTree
  // ---------------------------------------------------------------------------

  group('buildTree', () {
    test('returns empty list for empty input', () {
      expect(builder.buildTree([]), isEmpty);
    });

    test('single root node with no children', () {
      final node = makeExpense(id: 'r1');
      final result = builder.buildTree([node]);
      expect(result, hasLength(1));
      expect(result.first.id, 'r1');
      expect(result.first.children, isEmpty);
    });

    test('attaches children to their parent', () {
      final root = makeExpense(id: 'root', parentId: null);
      final child = makeExpense(id: 'child', parentId: 'root');
      final result = builder.buildTree([root, child]);

      expect(result, hasLength(1));
      expect(result.first.children, hasLength(1));
      expect(result.first.children.first.id, 'child');
    });

    test('two-level deep hierarchy', () {
      final root = makeExpense(id: 'root');
      final childA = makeExpense(id: 'childA', parentId: 'root');
      final grandchild = makeExpense(id: 'gc', parentId: 'childA');
      final result = builder.buildTree([root, childA, grandchild]);

      final child = result.first.children.first;
      expect(child.id, 'childA');
      expect(child.children.first.id, 'gc');
    });

    test('multiple root nodes are returned', () {
      final r1 = makeExpense(id: 'r1', name: 'B');
      final r2 = makeExpense(id: 'r2', name: 'A');
      final result = builder.buildTree([r1, r2]);
      expect(result, hasLength(2));
    });

    test('root nodes are sorted by sortOrder then name', () {
      final r1 = makeExpense(id: 'r1', name: 'Zebra', sortOrder: 2);
      final r2 = makeExpense(id: 'r2', name: 'Apple', sortOrder: 1);
      final r3 = makeExpense(id: 'r3', name: 'Mango', sortOrder: 1);
      final result = builder.buildTree([r1, r2, r3]);
      // r2 and r3 both sortOrder=1 → alphabetical: Apple < Mango
      expect(result[0].id, 'r2');
      expect(result[1].id, 'r3');
      expect(result[2].id, 'r1');
    });

    test('children are sorted by sortOrder then name', () {
      final root = makeExpense(id: 'root');
      final c1 = makeExpense(id: 'c1', name: 'Rent', parentId: 'root', sortOrder: 0);
      final c2 = makeExpense(id: 'c2', name: 'Bills', parentId: 'root', sortOrder: 0);
      final result = builder.buildTree([root, c2, c1]);
      final children = result.first.children;
      expect(children[0].id, 'c2'); // Bills < Rent alphabetically
      expect(children[1].id, 'c1');
    });
  });

  // ---------------------------------------------------------------------------
  // flattenTree
  // ---------------------------------------------------------------------------

  group('flattenTree', () {
    test('returns empty list for empty input', () {
      expect(builder.flattenTree([]), isEmpty);
    });

    test('single leaf node', () {
      final node = makeExpense(id: 'leaf');
      expect(builder.flattenTree([node]), [node]);
    });

    test('root + children returned depth-first', () {
      final child = makeExpense(id: 'child');
      final root = makeExpense(id: 'root', children: [child]);
      final result = builder.flattenTree([root]);
      expect(result, hasLength(2));
      expect(result[0].id, 'root');
      expect(result[1].id, 'child');
    });

    test('deeply nested nodes are all included', () {
      final grandchild = makeExpense(id: 'gc');
      final child = makeExpense(id: 'c', children: [grandchild]);
      final root = makeExpense(id: 'r', children: [child]);
      final result = builder.flattenTree([root]);
      final ids = result.map((n) => n.id).toList();
      expect(ids, containsAll(['r', 'c', 'gc']));
    });

    test('multiple root nodes all flattened', () {
      final r1 = makeExpense(id: 'r1');
      final r2 = makeExpense(id: 'r2');
      expect(builder.flattenTree([r1, r2]), hasLength(2));
    });
  });

  // ---------------------------------------------------------------------------
  // roundtrip: buildTree → flattenTree
  // ---------------------------------------------------------------------------

  group('roundtrip', () {
    test('flattenTree of buildTree recovers all nodes', () {
      final root = makeExpense(id: 'root');
      final child = makeExpense(id: 'child', parentId: 'root');
      final gc = makeExpense(id: 'gc', parentId: 'child');

      final tree = builder.buildTree([root, child, gc]);
      final flat = builder.flattenTree(tree);

      final ids = flat.map((n) => n.id).toSet();
      expect(ids, {'root', 'child', 'gc'});
    });
  });

  // ---------------------------------------------------------------------------
  // Fixed expense nodes (should still build tree normally)
  // ---------------------------------------------------------------------------

  group('fixed nodes', () {
    test('fixed-type nodes are included in tree', () {
      final fixed = ExpenseNode(
        id: 'fixed',
        name: 'Rent',
        type: ExpenseType.fixed,
        interval: PaymentInterval.monthly,
        plannedAmount: 1200,
      );
      final result = builder.buildTree([fixed]);
      expect(result, hasLength(1));
      expect(result.first.type, ExpenseType.fixed);
    });
  });
}
