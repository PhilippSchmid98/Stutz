// Datei: lib/presentation/providers/yearly_detail_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';
// Helper Imports für DateFormat
import 'package:intl/intl.dart';

part 'yearly_detail_provider.g.dart';

class YearlyBudgetNode {
  final ExpenseNode node;
  final double planned; // Jahresbudget
  final double actual; // Echte Ausgaben im Jahr
  final double offset; // "Virtuelle" Ausgaben (Zeit vor App-Start)
  final List<YearlyBudgetNode> children;

  // Berechnete Getter je nach Ansicht
  double get totalUsageWithOffset => actual + offset;

  // Prozentualer Verbrauch (Basis: Planned)
  double get percentUsedReal => planned == 0 ? 0.0 : actual / planned;
  double get percentUsedWithOffset =>
      planned == 0 ? 0.0 : (actual + offset) / planned;
  double get percentOffset => planned == 0 ? 0.0 : offset / planned;

  YearlyBudgetNode({
    required this.node,
    required this.planned,
    required this.actual,
    required this.offset,
    required this.children,
  });
}

@riverpod
Future<List<YearlyBudgetNode>> yearlyDetailTree(Ref ref, int year) async {
  // 1. Daten laden
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();
  final allTxns = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();

  // 2. Start-Datum bestimmen (Erste Transaktion ever)
  DateTime? firstTxnDate;
  if (allTxns.isNotEmpty) {
    firstTxnDate = allTxns
        .map((e) => e.dateTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  // 3. Offset-Faktor für das angefragte Jahr berechnen
  double offsetFactor = 0.0;

  if (firstTxnDate != null && firstTxnDate.year == year) {
    // App wurde IN diesem Jahr gestartet.
    // Wir berechnen den Anteil des Jahres, der VOR dem Start lag.
    final daysInYear = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))
        ? 366
        : 365;
    final startDayOfYear = int.parse(
      DateFormat("D").format(firstTxnDate),
    ); // Tag des Jahres (1-365)

    // Beispiel: Start am 100. Tag. 99 Tage sind "Offset".
    offsetFactor = (startDayOfYear - 1) / daysInYear;
  } else if (firstTxnDate != null && firstTxnDate.year > year) {
    // Wir schauen uns ein Jahr in der Vergangenheit an, wo die App noch gar nicht existierte.
    // Hier könnte man Offset 100% machen, aber meistens will man sehen "was wäre wenn".
    // Wir setzen es auf 0 für "reine Daten", oder man könnte Logik anpassen.
    // Für die Anforderung "Unterjähriger Start" ist vor allem das Startjahr relevant.
    offsetFactor = 0.0;
  }
  // Wenn firstTxnDate < year (User nutzt App schon länger), ist Offset 0.0 -> Korrekt.

  final txnsInYear = allTxns.where((t) => t.dateTime.year == year).toList();

  // 4. Rekursive Funktion
  YearlyBudgetNode? processNode(ExpenseNode node) {
    if (node.type == 'Fixed') return null; // Nur Variable Kosten

    List<YearlyBudgetNode> keptChildren = [];
    for (var child in node.children) {
      final processedChild = processNode(child);
      if (processedChild != null) keptChildren.add(processedChild);
    }

    // Eigene Werte
    double ownActual = txnsInYear
        .where((t) => t.expenseNodeId == node.id)
        .fold(0.0, (sum, t) => sum + t.amount);

    double ownPlanned = 0.0;
    if (node.plannedAmount != null) {
      if (node.interval == 'Yearly') {
        ownPlanned = node.plannedAmount!;
      } else {
        // Monatlich * 12
        ownPlanned = node.plannedAmount! * 12;
      }
    }

    double ownOffset = ownPlanned * offsetFactor;

    // Pruning (Leere Gruppen entfernen)
    bool hasChildren = keptChildren.isNotEmpty;
    bool hasOwnValues = ownActual > 0 || ownPlanned > 0;

    if (!hasChildren && !hasOwnValues) return null;

    // Summen (Bubble Up)
    double totalActual =
        ownActual + keptChildren.fold(0.0, (sum, c) => sum + c.actual);
    double totalPlanned =
        ownPlanned + keptChildren.fold(0.0, (sum, c) => sum + c.planned);
    double totalOffset =
        ownOffset + keptChildren.fold(0.0, (sum, c) => sum + c.offset);

    return YearlyBudgetNode(
      node: node,
      planned: totalPlanned,
      actual: totalActual,
      offset: totalOffset,
      children: keptChildren,
    );
  }

  // 5. Baum bauen
  final List<YearlyBudgetNode> result = [];
  for (var root in rootNodes) {
    final processed = processNode(root);
    if (processed != null) result.add(processed);
  }

  return result;
}
