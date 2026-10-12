import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/core/utils/amount_parser.dart';

part 'budget_summary.freezed.dart';

@freezed
abstract class BudgetSummary with _$BudgetSummary {
  const factory BudgetSummary({
    required int monthlyIncomeMinor,
    required int yearlyIncomeMinor,
    required int fixedMonthlyExpensesMinor,
    required int fixedYearlyExpensesMinor,
    required int variableMonthlyExpensesMinor,
    required int variableYearlyExpensesMinor,
  }) = _BudgetSummary;

  const BudgetSummary._();

  int get averageMonthlyIncomeMinor =>
      monthlyIncomeMinor + annualToMonthlyEstimateMinor(yearlyIncomeMinor);
  int get totalYearlyIncomeMinor => monthlyIncomeMinor * 12 + yearlyIncomeMinor;
  int get fixedExpensesMinor =>
      fixedMonthlyExpensesMinor +
      annualToMonthlyEstimateMinor(fixedYearlyExpensesMinor);
  int get variableExpensesMinor =>
      variableMonthlyExpensesMinor +
      annualToMonthlyEstimateMinor(variableYearlyExpensesMinor);
  int get monthlyExpensesMinor => fixedExpensesMinor + variableExpensesMinor;
  int get balanceMinor => averageMonthlyIncomeMinor - monthlyExpensesMinor;
  bool get isDeficit => balanceMinor < 0;
}
