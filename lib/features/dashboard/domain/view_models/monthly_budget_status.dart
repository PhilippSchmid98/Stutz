import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_budget_status.freezed.dart';

/// Budget vs. actual spending summary for a single calendar month.
@freezed
abstract class MonthlyBudgetStatus with _$MonthlyBudgetStatus {
  const MonthlyBudgetStatus._();

  const factory MonthlyBudgetStatus({
    required DateTime month,
    required double totalPlanned,
    required double totalSpent,
  }) = _MonthlyBudgetStatus;

  double get percentage {
    if (totalPlanned == 0) return totalSpent > 0 ? 1.0 : 0.0;
    return totalSpent / totalPlanned;
  }

  double get remaining => totalPlanned - totalSpent;
}
