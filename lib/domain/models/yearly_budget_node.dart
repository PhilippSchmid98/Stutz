import 'package:stutz/domain/models/expense_node.dart';

/// A node in the yearly budget vs. actual comparison tree, with offset support.
///
/// The [offset] represents "virtual" spending for the portion of the year
/// that occurred before the user started using the app.
class YearlyBudgetNode {
  final ExpenseNode node;

  /// Total yearly planned budget (own + all children).
  final double planned;

  /// Total actual spending for the year (own + all children).
  final double actual;

  /// Virtual pre-app-usage offset (own + all children).
  final double offset;

  final List<YearlyBudgetNode> children;

  double get totalUsageWithOffset => actual + offset;

  double get percentUsedReal => planned == 0 ? 0.0 : actual / planned;
  double get percentUsedWithOffset =>
      planned == 0 ? 0.0 : (actual + offset) / planned;
  double get percentOffset => planned == 0 ? 0.0 : offset / planned;

  const YearlyBudgetNode({
    required this.node,
    required this.planned,
    required this.actual,
    required this.offset,
    required this.children,
  });
}
