// Datei: lib/presentation/providers/yearly_detail_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:intl/intl.dart';

part 'yearly_detail_provider.g.dart';

class YearlyBudgetNode {
  final ExpenseNode node;
  final double planned; // Yearly budget
  final double actual; // Actual yearly expenses
  final double offset; // "Virtual" expenses (time before app start)
  final List<YearlyBudgetNode> children;

  double get totalUsageWithOffset => actual + offset;

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
  final rootNodes = await ref
      .watch(expenseNodeRepositoryProvider)
      .getAllExpenseNodes();
  final allTxns = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();

  DateTime? firstTxnDate;
  if (allTxns.isNotEmpty) {
    firstTxnDate = allTxns
        .map((e) => e.dateTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  double offsetFactor = 0.0;

  if (firstTxnDate != null && firstTxnDate.year == year) {
    final daysInYear = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))
        ? 366
        : 365;
    final startDayOfYear = int.parse(DateFormat("D").format(firstTxnDate));

    offsetFactor = (startDayOfYear - 1) / daysInYear;
  } else if (firstTxnDate != null && firstTxnDate.year > year) {
    offsetFactor = 0.0;
  }

  final txnsInYear = allTxns.where((t) => t.dateTime.year == year).toList();

  YearlyBudgetNode? processNode(ExpenseNode node) {
    if (node.type == 'Fixed') return null;

    List<YearlyBudgetNode> keptChildren = [];
    for (var child in node.children) {
      final processedChild = processNode(child);
      if (processedChild != null) keptChildren.add(processedChild);
    }

    double ownActual = txnsInYear
        .where((t) => t.expenseNodeId == node.id)
        .fold(0.0, (sum, t) => sum + t.amount);

    double ownPlanned = 0.0;
    if (node.plannedAmount != null) {
      if (node.interval == 'Yearly') {
        ownPlanned = node.plannedAmount!;
      } else {
        ownPlanned = node.plannedAmount! * 12;
      }
    }

    double ownOffset = ownPlanned * offsetFactor;

    bool hasChildren = keptChildren.isNotEmpty;
    bool hasOwnValues = ownActual > 0 || ownPlanned > 0;

    if (!hasChildren && !hasOwnValues) return null;

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

  final List<YearlyBudgetNode> result = [];
  for (var root in rootNodes) {
    final processed = processNode(root);
    if (processed != null) result.add(processed);
  }

  return result;
}
