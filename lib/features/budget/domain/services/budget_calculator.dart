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

  /// Total monthly income from all [sources] (yearly amounts divided by 12).
  double totalMonthlyIncome(List<IncomeSource> sources) {
    return sources.fold<double>(0.0, (sum, s) => sum + s.monthlyAmount);
  }

  ({double monthly, double yearly}) incomeIntervalTotals(
    List<IncomeSource> sources,
  ) {
    var monthly = 0.0;
    var yearly = 0.0;

    for (final source in sources) {
      if (source.interval == PaymentInterval.yearly) {
        yearly += source.amount;
      } else {
        monthly += source.amount;
      }
    }

    return (monthly: monthly, yearly: yearly);
  }

  /// Total monthly planned expenses across all root [nodes]
  /// (yearly amounts divided by 12; groups sum their children).
  double totalMonthlyExpenses(List<ExpenseNode> nodes) {
    return nodes.fold<double>(0.0, (sum, n) => sum + n.totalMonthlyCalculated);
  }

  ({double monthly, double yearly}) expenseIntervalTotals(
    List<ExpenseNode> nodes,
  ) {
    var monthly = 0.0;
    var yearly = 0.0;

    for (final node in nodes) {
      if (node.plannedAmount != null) {
        if (node.interval == PaymentInterval.yearly) {
          yearly += node.plannedAmount!;
        } else {
          monthly += node.plannedAmount!;
        }
      }

      final children = expenseIntervalTotals(node.children);
      monthly += children.monthly;
      yearly += children.yearly;
    }

    return (monthly: monthly, yearly: yearly);
  }

  /// Derives all budget totals from income sources and the expense tree.
  BudgetSummary calculateSummary(
    List<IncomeSource> sources,
    List<ExpenseNode> roots,
  ) {
    var fixedExpenses = 0.0;
    var variableExpenses = 0.0;

    void collectExpenseTypes(List<ExpenseNode> nodes) {
      for (final node in nodes) {
        if (node.plannedAmount != null) {
          final amount = node.interval == PaymentInterval.yearly
              ? node.plannedAmount! / 12
              : node.plannedAmount!;
          if (node.type == ExpenseType.fixed) {
            fixedExpenses += amount;
          } else {
            variableExpenses += amount;
          }
        }
        collectExpenseTypes(node.children);
      }
    }

    collectExpenseTypes(roots);

    return BudgetSummary(
      monthlyIncome: totalMonthlyIncome(sources),
      monthlyExpenses: totalMonthlyExpenses(roots),
      fixedExpenses: fixedExpenses,
      variableExpenses: variableExpenses,
    );
  }
}
