import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/view_models/budget_summary.dart';

/// Pure domain service for budget planning calculations (income vs. planned
/// expenses). Analytics that combine planned budget with actual spending
/// (e.g. monthly/yearly detail, dashboard stats) live in the Dashboard feature.
///
/// All methods are stateless — create an instance with [const BudgetCalculator()].
class BudgetCalculator {
  const BudgetCalculator();

  int totalMonthlyIncomeMinor(List<IncomeSource> sources) {
    final totals = incomeIntervalTotals(sources);
    return totals.monthlyMinor +
        annualToMonthlyEstimateMinor(totals.yearlyMinor);
  }

  ({int monthlyMinor, int yearlyMinor}) incomeIntervalTotals(
    List<IncomeSource> sources,
  ) {
    var monthlyMinor = 0;
    var yearlyMinor = 0;

    for (final source in sources) {
      if (source.interval == PaymentInterval.yearly) {
        yearlyMinor += source.amountMinor;
      } else {
        monthlyMinor += source.amountMinor;
      }
    }

    return (monthlyMinor: monthlyMinor, yearlyMinor: yearlyMinor);
  }

  int totalMonthlyExpensesMinor(List<ExpenseNode> nodes) {
    final totals = expenseIntervalTotals(nodes);
    return totals.monthlyMinor +
        annualToMonthlyEstimateMinor(totals.yearlyMinor);
  }

  ({int monthlyMinor, int yearlyMinor}) expenseIntervalTotals(
    List<ExpenseNode> nodes,
  ) {
    var monthlyMinor = 0;
    var yearlyMinor = 0;

    for (final node in nodes) {
      if (node.children.isEmpty && node.plannedAmountMinor != null) {
        if (node.interval == PaymentInterval.yearly) {
          yearlyMinor += node.plannedAmountMinor!;
        } else {
          monthlyMinor += node.plannedAmountMinor!;
        }
      }

      final children = expenseIntervalTotals(node.children);
      monthlyMinor += children.monthlyMinor;
      yearlyMinor += children.yearlyMinor;
    }

    return (monthlyMinor: monthlyMinor, yearlyMinor: yearlyMinor);
  }

  /// Derives all budget totals from income sources and the expense tree.
  BudgetSummary calculateSummary(
    List<IncomeSource> sources,
    List<ExpenseNode> roots,
  ) {
    var fixedMonthlyExpensesMinor = 0;
    var fixedYearlyExpensesMinor = 0;
    var variableMonthlyExpensesMinor = 0;
    var variableYearlyExpensesMinor = 0;

    void collectExpenseTypes(List<ExpenseNode> nodes) {
      for (final node in nodes) {
        if (node.plannedAmountMinor != null) {
          final amountMinor = node.plannedAmountMinor!;
          switch ((node.type, node.interval)) {
            case (ExpenseType.fixed, PaymentInterval.monthly):
              fixedMonthlyExpensesMinor += amountMinor;
            case (ExpenseType.fixed, PaymentInterval.yearly):
              fixedYearlyExpensesMinor += amountMinor;
            case (ExpenseType.variable, PaymentInterval.monthly):
              variableMonthlyExpensesMinor += amountMinor;
            case (ExpenseType.variable, PaymentInterval.yearly):
              variableYearlyExpensesMinor += amountMinor;
            case (_, _):
              break;
          }
        }
        collectExpenseTypes(node.children);
      }
    }

    collectExpenseTypes(roots);

    final incomeTotals = incomeIntervalTotals(sources);
    return BudgetSummary(
      monthlyIncomeMinor: incomeTotals.monthlyMinor,
      yearlyIncomeMinor: incomeTotals.yearlyMinor,
      fixedMonthlyExpensesMinor: fixedMonthlyExpensesMinor,
      fixedYearlyExpensesMinor: fixedYearlyExpensesMinor,
      variableMonthlyExpensesMinor: variableMonthlyExpensesMinor,
      variableYearlyExpensesMinor: variableYearlyExpensesMinor,
    );
  }
}
