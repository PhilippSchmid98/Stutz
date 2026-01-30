import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';

part 'monthly_detail_provider.g.dart';

class BudgetVsActualNode {
  final ExpenseNode node;
  final double planned; // Total (Eigen + Kinder)
  final double actual; // Total (Eigen + Kinder)
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
  // 1. Den fertigen Baum laden (Roots enthalten bereits ihre Children)
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();

  // 2. Transaktionen laden und filtern
  final allTxns = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();
  final txnsInMonth = allTxns.where((t) {
    return t.dateTime.year == month.year && t.dateTime.month == month.month;
  }).toList();

  // 3. Rekursive Funktion: Filtert den Baum und berechnet Werte
  BudgetVsActualNode? processNode(ExpenseNode node) {
    // REGEL 1: Fixkosten sofort entfernen
    if (node.type == 'Fixed') {
      return null;
    }

    // REGEL 2: Kinder verarbeiten (Rekursion durch node.children)
    List<BudgetVsActualNode> keptChildren = [];
    for (var child in node.children) {
      final processedChild = processNode(child);
      if (processedChild != null) {
        keptChildren.add(processedChild);
      }
    }

    // REGEL 3: Eigene Werte berechnen
    // Actual: Summe der Transaktionen für genau diese Node-ID
    double ownActual = txnsInMonth
        .where((t) => t.expenseNodeId == node.id)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Planned: Eigenes Budget (Intervall beachten)
    double ownPlanned = 0.0;
    if (node.plannedAmount != null) {
      if (node.interval == 'Yearly') {
        ownPlanned = node.plannedAmount! / 12;
      } else {
        ownPlanned = node.plannedAmount!;
      }
    }

    // REGEL 4: Bereinigen (Pruning)
    // Wenn es eine Gruppe ist (kein eigenes Budget/Ausgaben) UND durch das Filtern
    // keine Kinder mehr übrig sind -> Entfernen.
    // Ausnahme: Wenn man auf einer Gruppe direkt Ausgaben gebucht hätte (sollte man nicht, kann aber passieren), zeigen wir sie an.
    bool hasChildren = keptChildren.isNotEmpty;
    bool hasOwnValues = ownActual > 0 || ownPlanned > 0;

    if (!hasChildren && !hasOwnValues) {
      return null;
    }

    // REGEL 5: Summen bilden (Bubble Up)
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

  // 4. Starten mit den Root-Nodes
  final List<BudgetVsActualNode> result = [];
  for (var root in rootNodes) {
    final processed = processNode(root);
    if (processed != null) {
      result.add(processed);
    }
  }

  return result;
}
