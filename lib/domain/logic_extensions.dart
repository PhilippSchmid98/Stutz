import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';

extension IncomeLogic on IncomeSource {
  /// Returns the monthly amount.
  /// Automatically divides yearly amounts by 12.
  double get monthlyAmount {
    if (interval == PaymentInterval.yearly) {
      return amount / 12;
    }
    return amount;
  }
}

extension ExpenseLogic on ExpenseNode {
  /// Recursively calculates the total monthly cost for this node,
  /// including all subcategories (children).
  double get totalMonthlyCalculated {
    // Case 1: It is a group (has children)
    if (isGroup) {
      return children.fold<double>(
        0.0,
        (sum, child) => sum + child.totalMonthlyCalculated,
      );
    }

    // Case 2: It is a leaf (no children) -> Calculate its own value
    final amount = plannedAmount ?? 0.0;

    if (interval == PaymentInterval.yearly) {
      return amount / 12;
    }
    return amount;
  }
}
