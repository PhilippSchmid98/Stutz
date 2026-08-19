import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

part 'expense_node.freezed.dart';

@freezed
abstract class ExpenseNode with _$ExpenseNode {
  const ExpenseNode._();

  const factory ExpenseNode({
    required String id,
    String? parentId,
    required String name,
    double? plannedAmount,

    /// Calculated field — not persisted in DB.
    double? actualAmount,
    ExpenseType? type,
    PaymentInterval? interval,
    @Default([]) List<ExpenseNode> children,

    /// [sortOrder] 99999 is a lazy-migration sentinel for old documents without sorting.
    @Default(99999) int sortOrder,
  }) = _ExpenseNode;

  bool get isGroup => children.isNotEmpty;

  /// Recursively calculates the total monthly cost for this node, including all descendants.
  double get totalMonthlyCalculated {
    if (isGroup) {
      return children.fold<double>(
        0.0,
        (total, child) => total + child.totalMonthlyCalculated,
      );
    }
    final amount = plannedAmount ?? 0.0;
    if (interval == PaymentInterval.yearly) return amount / 12;
    return amount;
  }

  /// Validates the state before it is persisted. Empty groups are valid even
  /// though their children are loaded separately from Firestore.
  void validateForWrite() {
    if (id.trim().isEmpty) {
      throw const ExpenseNodeValidationException('Category ID is required');
    }
    if (name.trim().isEmpty) {
      throw const ExpenseNodeValidationException('Category name is required');
    }

    final isGroupNode =
        children.isNotEmpty ||
        (plannedAmount == null && interval == null && type == null);
    if (isGroupNode) {
      if (plannedAmount != null || interval != null || type != null) {
        throw const ExpenseNodeValidationException(
          'A group cannot have amount, interval, or type',
        );
      }
      return;
    }

    final amount = plannedAmount;
    if (amount == null || !amount.isFinite || amount <= 0) {
      throw const ExpenseNodeValidationException(
        'A leaf category needs a positive amount',
      );
    }
    if (interval == null || type == null) {
      throw const ExpenseNodeValidationException(
        'A leaf category needs an interval and type',
      );
    }
  }
}

class ExpenseNodeValidationException implements Exception {
  final String message;

  const ExpenseNodeValidationException(this.message);

  @override
  String toString() => message;
}
