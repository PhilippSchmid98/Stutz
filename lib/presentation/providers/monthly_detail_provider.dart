import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';

part 'monthly_detail_provider.g.dart';

class BudgetVsActualNode {
  final ExpenseNode node;
  final double planned; // Total (Own + Children)
  final double actual; // Total (Own + Children)
  final List<BudgetVsActualNode> children;

  double get difference => planned - actual;

  double get percentUsed {
    if (planned == 0) return actual > 0 ? 1.0 : 0.0;
    return actual / planned;
  }

  BudgetVsActualNode({
    required this.node,
    required this.planned,
    required this.actual,
    required this.children,
  });
}

@riverpod
Future<List<BudgetVsActualNode>> monthlyDetailTree(
  Ref ref,
  DateTime month,
) async {
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();

  final allTxns = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();
  final txnsInMonth = allTxns.where((t) {
    return t.dateTime.year == month.year && t.dateTime.month == month.month;
  }).toList();

  BudgetVsActualNode? processNode(ExpenseNode node) {
    if (node.type == 'Fixed') {
      return null;
    }

    List<BudgetVsActualNode> keptChildren = [];
    for (var child in node.children) {
      final processedChild = processNode(child);
      if (processedChild != null) {
        keptChildren.add(processedChild);
      }
    }

    double ownActual = txnsInMonth
        .where((t) => t.expenseNodeId == node.id)
        .fold(0.0, (sum, t) => sum + t.amount);

    double ownPlanned = 0.0;
    if (node.plannedAmount != null) {
      if (node.interval == 'Yearly') {
        ownPlanned = node.plannedAmount! / 12;
      } else {
        ownPlanned = node.plannedAmount!;
      }
    }

    bool hasChildren = keptChildren.isNotEmpty;
    bool hasOwnValues = ownActual > 0 || ownPlanned > 0;

    if (!hasChildren && !hasOwnValues) {
      return null;
    }

    double totalActual =
        ownActual + keptChildren.fold(0.0, (sum, c) => sum + c.actual);
    double totalPlanned =
        ownPlanned + keptChildren.fold(0.0, (sum, c) => sum + c.planned);

    return BudgetVsActualNode(
      node: node,
      planned: totalPlanned,
      actual: totalActual,
      children: keptChildren,
    );
  }

  final List<BudgetVsActualNode> result = [];
  for (var root in rootNodes) {
    final processed = processNode(root);
    if (processed != null) {
      result.add(processed);
    }
  }

  return result;
}
