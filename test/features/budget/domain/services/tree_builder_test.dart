import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/services/tree_builder.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const builder = TreeBuilder();

  group('buildTree', () {
    test('returns empty list for empty input', () {
      expect(builder.buildTree([]), isEmpty);
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

    test('root nodes are sorted by sortOrder then name', () {
      final r1 = makeExpense(id: 'r1', name: 'Zebra', sortOrder: 2);
      final r2 = makeExpense(id: 'r2', name: 'Apple', sortOrder: 1);
      final r3 = makeExpense(id: 'r3', name: 'Mango', sortOrder: 1);
      final result = builder.buildTree([r1, r2, r3]);
      expect(result[0].id, 'r2');
      expect(result[1].id, 'r3');
      expect(result[2].id, 'r1');
    });
  });

  group('flattenTree', () {
    test('returns empty list for empty input', () {
      expect(builder.flattenTree([]), isEmpty);
    });

    test('root + children returned depth-first', () {
      final child = makeExpense(id: 'child');
      final root = makeExpense(id: 'root', children: [child]);
      final result = builder.flattenTree([root]);
      expect(result, hasLength(2));
      expect(result[0].id, 'root');
      expect(result[1].id, 'child');
    });
  });

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

  group('fixed nodes', () {
    test('fixed-type nodes are included in tree', () {
      final fixed = ExpenseNode(id: 'fixed', name: 'Rent', plannedAmount: 1200);
      final result = builder.buildTree([fixed]);
      expect(result, hasLength(1));
    });

    test('rejects duplicate IDs', () {
      expect(
        () => builder.buildTree([
          makeExpense(id: 'duplicate'),
          makeExpense(id: 'duplicate'),
        ]),
        throwsA(isA<ExpenseTreeValidationException>()),
      );
    });

    test('rejects missing parents', () {
      expect(
        () =>
            builder.buildTree([makeExpense(id: 'child', parentId: 'missing')]),
        throwsA(isA<ExpenseTreeValidationException>()),
      );
    });

    test('rejects parent cycles', () {
      expect(
        () => builder.buildTree([
          makeExpense(id: 'a', parentId: 'b'),
          makeExpense(id: 'b', parentId: 'a'),
        ]),
        throwsA(isA<ExpenseTreeValidationException>()),
      );
    });
  });
}
