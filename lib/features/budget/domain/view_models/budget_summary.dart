import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_summary.freezed.dart';

@freezed
abstract class BudgetSummary with _$BudgetSummary {
  const factory BudgetSummary({
    required double averageMonthlyIncome,
    required double fixedMonthlyExpenses,
    required double fixedYearlyExpenses,
    required double variableMonthlyExpenses,
    required double variableYearlyExpenses,
  }) = _BudgetSummary;

  const BudgetSummary._();

  double get yearlyIncome => averageMonthlyIncome * 12;
  double get fixedExpenses => fixedMonthlyExpenses + fixedYearlyExpenses / 12;
  double get variableExpenses =>
      variableMonthlyExpenses + variableYearlyExpenses / 12;
  double get monthlyExpenses => fixedExpenses + variableExpenses;
  double get balance => averageMonthlyIncome - monthlyExpenses;
  bool get isDeficit => balance < 0;
}
