import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';

part 'dashboard_providers.g.dart';

class MonthlyBudgetStatus {
  final DateTime month;
  final double totalPlanned;
  final double totalSpent;

  double get percentage {
    if (totalPlanned == 0) return totalSpent > 0 ? 1.0 : 0.0;
    return totalSpent / totalPlanned;
  }

  double get remaining => totalPlanned - totalSpent;

  MonthlyBudgetStatus({
    required this.month,
    required this.totalPlanned,
    required this.totalSpent,
  });
}

@riverpod
Future<List<MonthlyBudgetStatus>> dashboardMonthlyStats(Ref ref) async {
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();
  final allTransactions = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();

  final Set<String> variableNodeIds = {};
  double totalVariablePlannedPerMonth = 0;

  void processNode(ExpenseNode node) {
    if (node.type == 'Fixed') {
      return;
    }

    variableNodeIds.add(node.id);

    if (node.plannedAmount != null) {
      double amount = node.plannedAmount!;
      if (node.interval == 'Yearly') {
        amount /= 12;
      }
      totalVariablePlannedPerMonth += amount;
    }

    for (var child in node.children) {
      processNode(child);
    }
  }

  for (var root in rootNodes) {
    processNode(root);
  }

  final now = DateTime.now();
  List<MonthlyBudgetStatus> stats = [];

  for (int i = 0; i < 6; i++) {
    final monthDate = DateTime(now.year, now.month - i);

    final txnsInMonth = allTransactions.where((t) {
      final isSameMonth =
          t.dateTime.year == monthDate.year &&
          t.dateTime.month == monthDate.month;
      final isVariableNode = variableNodeIds.contains(t.expenseNodeId);
      return isSameMonth && isVariableNode;
    });

    final totalSpentInMonth = txnsInMonth.fold(0.0, (sum, t) => sum + t.amount);

    stats.add(
      MonthlyBudgetStatus(
        month: monthDate,
        totalPlanned: totalVariablePlannedPerMonth,
        totalSpent: totalSpentInMonth,
      ),
    );
  }

  return stats;
}
