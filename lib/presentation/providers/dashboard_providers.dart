import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';

part 'dashboard_providers.g.dart';

class MonthlyBudgetStatus {
  final DateTime month;
  final double totalPlanned; // Nur Variable
  final double totalSpent; // Nur Variable

  // Berechnung
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
  // 1. Daten laden
  // Das Repo gibt bereits den Baum zurück (Roots mit verschachtelten Children)
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();
  final allTransactions = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();

  // 2. Variable IDs und Variables Budget berechnen
  // Wir müssen herausfinden:
  // a) Welche Node-IDs gehören zum "Variablen" Baum? (Damit wir die Transaktionen filtern können)
  // b) Wie hoch ist das gesamte Variable Budget?

  final Set<String> variableNodeIds = {};
  double totalVariablePlannedPerMonth = 0;

  void processNode(ExpenseNode node) {
    // Wenn der Knoten FIX ist, brechen wir diesen Ast komplett ab.
    if (node.type == 'Fixed') {
      return;
    }

    // Dieser Knoten ist Teil des variablen Baums
    variableNodeIds.add(node.id);

    // Budget addieren, falls vorhanden (und nicht Fixed)
    if (node.plannedAmount != null) {
      double amount = node.plannedAmount!;
      if (node.interval == 'Yearly') {
        amount /= 12;
      }
      totalVariablePlannedPerMonth += amount;
    }

    // Rekursiv Kinder verarbeiten
    for (var child in node.children) {
      processNode(child);
    }
  }

  // Den Baum durchgehen
  for (var root in rootNodes) {
    processNode(root);
  }

  // 3. Die letzten 6 Monate generieren
  final now = DateTime.now();
  List<MonthlyBudgetStatus> stats = [];

  for (int i = 0; i < 6; i++) {
    final monthDate = DateTime(now.year, now.month - i);

    // 4. Transaktionen filtern
    // Bedingung 1: Datum passt zum Monat
    // Bedingung 2: Die Kategorie (NodeID) ist im "Variablen Set" enthalten
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
