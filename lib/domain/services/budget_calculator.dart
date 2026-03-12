import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/logic_extensions.dart';
import 'package:stutz/domain/models/budget_health.dart';
import 'package:stutz/domain/models/budget_vs_actual_node.dart';
import 'package:stutz/domain/models/expense_node.dart';
import 'package:stutz/domain/models/income_source.dart';
import 'package:stutz/domain/models/monthly_budget_status.dart';
import 'package:stutz/domain/models/transaction.dart';

/// Pure domain service for all budget calculations.
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
    return nodes.fold<double>(
      0.0,
      (sum, n) => sum + n.totalMonthlyCalculated,
    );
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

  /// Builds a budget-vs-actual comparison tree for [txnsInMonth].
  ///
  /// Fixed expense nodes (and their subtrees) are excluded entirely.
  /// Nodes with no planned amount and no actual spending are pruned.
  List<BudgetVsActualNode> buildMonthlyDetail(
    List<ExpenseNode> rootNodes,
    List<AppTransaction> txnsInMonth,
  ) {
    BudgetVsActualNode? processNode(ExpenseNode node) {
      if (node.type == ExpenseType.fixed) return null;

      final keptChildren = <BudgetVsActualNode>[];
      for (var child in node.children) {
        final processed = processNode(child);
        if (processed != null) keptChildren.add(processed);
      }

      final ownActual = txnsInMonth
          .where((t) => t.expenseNodeId == node.id)
          .fold(0.0, (sum, t) => sum + t.amount);

      double ownPlanned = 0.0;
      if (node.plannedAmount != null) {
        ownPlanned = node.interval == PaymentInterval.yearly
            ? node.plannedAmount! / 12
            : node.plannedAmount!;
      }

      if (keptChildren.isEmpty && ownActual == 0 && ownPlanned == 0) {
        return null;
      }

      return BudgetVsActualNode(
        node: node,
        planned: ownPlanned +
            keptChildren.fold(0.0, (sum, c) => sum + c.planned),
        actual: ownActual +
            keptChildren.fold(0.0, (sum, c) => sum + c.actual),
        children: keptChildren,
      );
    }

    final result = <BudgetVsActualNode>[];
    for (var root in rootNodes) {
      final processed = processNode(root);
      if (processed != null) result.add(processed);
    }
    return result;
  }

  /// Calculates [MonthlyBudgetStatus] for the last [monthCount] months.
  ///
  /// Only variable expense nodes are included. Fixed nodes are ignored because
  /// they are handled separately and do not vary month to month.
  List<MonthlyBudgetStatus> calculateDashboardStats(
    List<ExpenseNode> rootNodes,
    List<AppTransaction> allTransactions, {
    int monthCount = 6,
  }) {
    final variableNodeIds = <String>{};
    var totalVariablePlannedPerMonth = 0.0;

    void collectVariableNodes(ExpenseNode node) {
      if (node.type == ExpenseType.fixed) return;
      variableNodeIds.add(node.id);
      if (node.plannedAmount != null) {
        double amount = node.plannedAmount!;
        if (node.interval == PaymentInterval.yearly) amount /= 12;
        totalVariablePlannedPerMonth += amount;
      }
      for (var child in node.children) {
        collectVariableNodes(child);
      }
    }

    for (var root in rootNodes) {
      collectVariableNodes(root);
    }

    final now = DateTime.now();
    final stats = <MonthlyBudgetStatus>[];

    for (int i = 0; i < monthCount; i++) {
      final monthDate = DateTime(now.year, now.month - i);
      final totalSpent = allTransactions
          .where(
            (t) =>
                t.dateTime.year == monthDate.year &&
                t.dateTime.month == monthDate.month &&
                variableNodeIds.contains(t.expenseNodeId),
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      stats.add(
        MonthlyBudgetStatus(
          month: monthDate,
          totalPlanned: totalVariablePlannedPerMonth,
          totalSpent: totalSpent,
        ),
      );
    }

    return stats;
  }
}
