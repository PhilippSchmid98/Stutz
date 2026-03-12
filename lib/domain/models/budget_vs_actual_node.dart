import 'package:stutz/domain/models/expense_node.dart';

/// A node in the monthly budget vs. actual comparison tree.
///
/// [planned] and [actual] are the totals including all descendants.
class BudgetVsActualNode {
  final ExpenseNode node;

  /// Total planned budget (own + all children).
  final double planned;

  /// Total actual spending (own + all children).
  final double actual;

  final List<BudgetVsActualNode> children;

  double get difference => planned - actual;

  double get percentUsed {
    if (planned == 0) return actual > 0 ? 1.0 : 0.0;
    return actual / planned;
  }

  const BudgetVsActualNode({
    required this.node,
    required this.planned,
    required this.actual,
    required this.children,
  });
}
