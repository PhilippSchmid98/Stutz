import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/dashboard/domain/view_models/budget_vs_actual_node.dart';
import 'package:stutz/features/dashboard/domain/view_models/monthly_budget_status.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

/// Pure domain service for analytics that combine planned budget data
/// (Budget feature) with actual spending (Transactions feature).
///
/// All methods are stateless — create an instance with [const DashboardCalculator()].
class DashboardCalculator {
  const DashboardCalculator();

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
        planned:
            ownPlanned + keptChildren.fold(0.0, (sum, c) => sum + c.planned),
        actual: ownActual + keptChildren.fold(0.0, (sum, c) => sum + c.actual),
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
    DateTime? referenceDate,
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

    final now = referenceDate ?? DateTime.now();
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
