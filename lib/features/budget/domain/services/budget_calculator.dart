import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/view_models/budget_health.dart';

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

  /// Total monthly planned expenses across all root [nodes]
  /// (yearly amounts divided by 12; groups sum their children).
  double totalMonthlyExpenses(List<ExpenseNode> nodes) {
    return nodes.fold<double>(0.0, (sum, n) => sum + n.totalMonthlyCalculated);
  }

  /// Derives the overall [BudgetHealth] from income sources and expense tree.
  BudgetHealth calculateHealth(
    List<IncomeSource> sources,
    List<ExpenseNode> roots,
  ) {
    return BudgetHealth(
      income: totalMonthlyIncome(sources),
      expenses: totalMonthlyExpenses(roots),
    );
  }
}
