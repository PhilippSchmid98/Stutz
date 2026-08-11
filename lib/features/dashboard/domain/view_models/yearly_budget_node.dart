import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';

part 'yearly_budget_node.freezed.dart';

/// A node in the yearly budget vs. actual comparison tree, with offset support.
///
/// The [offset] represents "virtual" spending for the portion of the year
/// that occurred before the user started using the app.
@freezed
abstract class YearlyBudgetNode with _$YearlyBudgetNode {
  const YearlyBudgetNode._();

  const factory YearlyBudgetNode({
    required ExpenseNode node,

    /// Total yearly planned budget (own + all children).
    required double planned,

    /// Total actual spending for the year (own + all children).
    required double actual,

    /// Virtual pre-app-usage offset (own + all children).
    required double offset,

    required List<YearlyBudgetNode> children,
  }) = _YearlyBudgetNode;

  double get totalUsageWithOffset => actual + offset;

  double get percentUsedReal => planned == 0 ? 0.0 : actual / planned;
  double get percentUsedWithOffset =>
      planned == 0 ? 0.0 : (actual + offset) / planned;
  double get percentOffset => planned == 0 ? 0.0 : offset / planned;
}
