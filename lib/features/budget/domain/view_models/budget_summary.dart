import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_summary.freezed.dart';

@freezed
abstract class BudgetSummary with _$BudgetSummary {
  const factory BudgetSummary({
    required double monthlyIncome,
    required double monthlyExpenses,
    required double fixedExpenses,
    required double variableExpenses,
  }) = _BudgetSummary;

  const BudgetSummary._();

  double get balance => monthlyIncome - monthlyExpenses;
  bool get isDeficit => balance < 0;
}
