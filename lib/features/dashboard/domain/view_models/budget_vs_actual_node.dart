import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';

part 'budget_vs_actual_node.freezed.dart';

/// A node in the monthly budget vs. actual comparison tree.
///
/// [planned] and [actual] are the totals including all descendants.
@freezed
abstract class BudgetVsActualNode with _$BudgetVsActualNode {
  const BudgetVsActualNode._();

  const factory BudgetVsActualNode({
    required ExpenseNode node,

    /// Total planned budget (own + all children).
    required double planned,

    /// Total actual spending (own + all children).
    required double actual,

    required List<BudgetVsActualNode> children,
  }) = _BudgetVsActualNode;

  double get difference => planned - actual;

  double get percentUsed {
    if (planned == 0) return actual > 0 ? 1.0 : 0.0;
    return actual / planned;
  }
}
