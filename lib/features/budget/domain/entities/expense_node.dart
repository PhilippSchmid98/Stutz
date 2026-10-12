import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

part 'expense_node.freezed.dart';

@freezed
abstract class ExpenseNode with _$ExpenseNode {
  const ExpenseNode._();

  const factory ExpenseNode({
    required String id,
    String? parentId,
    required String name,
    int? plannedAmountMinor,

    /// Calculated field — not persisted in DB.
    int? actualAmountMinor,
    ExpenseType? type,
    PaymentInterval? interval,
    @Default([]) List<ExpenseNode> children,

    /// [sortOrder] 99999 is a lazy-migration sentinel for old documents without sorting.
    @Default(99999) int sortOrder,
  }) = _ExpenseNode;

  bool get isGroup => children.isNotEmpty;

  ({int monthlyMinor, int yearlyMinor}) get intervalTotalsMinor {
    if (children.isNotEmpty) {
      var monthlyMinor = 0;
      var yearlyMinor = 0;
      for (final child in children) {
        final totals = child.intervalTotalsMinor;
        monthlyMinor += totals.monthlyMinor;
        yearlyMinor += totals.yearlyMinor;
      }
      return (monthlyMinor: monthlyMinor, yearlyMinor: yearlyMinor);
    }

    final amountMinor = plannedAmountMinor ?? 0;
    return interval == PaymentInterval.yearly
        ? (monthlyMinor: 0, yearlyMinor: amountMinor)
        : (monthlyMinor: amountMinor, yearlyMinor: 0);
  }

  int get totalMonthlyEstimateMinor {
    final totals = intervalTotalsMinor;
    return totals.monthlyMinor +
        annualToMonthlyEstimateMinor(totals.yearlyMinor);
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
        (plannedAmountMinor == null && interval == null && type == null);
    if (isGroupNode) {
      if (plannedAmountMinor != null || interval != null || type != null) {
        throw const ExpenseNodeValidationException(
          'A group cannot have amount, interval, or type',
        );
      }
      return;
    }

    final amountMinor = plannedAmountMinor;
    if (amountMinor == null || amountMinor <= 0) {
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
