import 'package:stutz/features/budget/domain/entities/expense_node.dart';

/// Pure domain service for assembling and decomposing the expense node tree.
///
/// All methods are stateless and produce no side effects.
class TreeBuilder {
  const TreeBuilder();

  /// Assembles a flat list of [ExpenseNode] items into a proper parent–child
  /// hierarchy. Root nodes are nodes whose [parentId] is null.
  ///
  /// Nodes at each level are sorted by [sortOrder] (ascending), with name as
  /// tie-breaker.
  List<ExpenseNode> buildTree(List<ExpenseNode> flatNodes) {
    _validateStructure(flatNodes);

    final Map<String, List<ExpenseNode>> childrenMap = {};
    for (var node in flatNodes) {
      if (node.parentId != null) {
        childrenMap.putIfAbsent(node.parentId!, () => []).add(node);
      }
    }

    ExpenseNode attachChildren(ExpenseNode parent) {
      final children = childrenMap[parent.id] ?? [];
      children.sort((a, b) {
        final res = a.sortOrder.compareTo(b.sortOrder);
        if (res == 0) return a.name.compareTo(b.name);
        return res;
      });
      return parent.copyWith(
        children: children.map((c) => attachChildren(c)).toList(),
      );
    }

    final roots = flatNodes.where((n) => n.parentId == null).toList();
    roots.sort((a, b) {
      final res = a.sortOrder.compareTo(b.sortOrder);
      if (res == 0) return a.name.compareTo(b.name);
      return res;
    });

    return roots.map((root) => attachChildren(root)).toList();
  }

  void _validateStructure(List<ExpenseNode> flatNodes) {
    final nodesById = <String, ExpenseNode>{};
    for (final node in flatNodes) {
      if (node.id.trim().isEmpty) {
        throw const ExpenseTreeValidationException('Category ID is required');
      }
      if (nodesById.containsKey(node.id)) {
        throw ExpenseTreeValidationException(
          'Duplicate category ID: ${node.id}',
        );
      }
      nodesById[node.id] = node;
    }

    for (final node in flatNodes) {
      final parentId = node.parentId;
      if (parentId != null && !nodesById.containsKey(parentId)) {
        throw ExpenseTreeValidationException(
          'Category ${node.id} references missing parent $parentId',
        );
      }
    }

    final visiting = <String>{};
    final visited = <String>{};

    void visit(String id) {
      if (visiting.contains(id)) {
        throw ExpenseTreeValidationException(
          'Category tree contains a cycle at $id',
        );
      }
      if (!visited.add(id)) return;

      visiting.add(id);
      final parentId = nodesById[id]!.parentId;
      if (parentId != null) visit(parentId);
      visiting.remove(id);
    }

    for (final node in flatNodes) {
      visit(node.id);
    }
  }

  /// Recursively flattens a tree of [ExpenseNode] into a single flat list
  /// (depth-first, parent before children).
  List<ExpenseNode> flattenTree(List<ExpenseNode> nodes) {
    final List<ExpenseNode> flatList = [];
    for (var node in nodes) {
      flatList.add(node);
      if (node.children.isNotEmpty) {
        flatList.addAll(flattenTree(node.children));
      }
    }
    return flatList;
  }
}

class ExpenseTreeValidationException implements Exception {
  final String message;

  const ExpenseTreeValidationException(this.message);

  @override
  String toString() => message;
}
