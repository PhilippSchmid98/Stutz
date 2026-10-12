import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

class DashboardCalculator {
  const DashboardCalculator();

  DashboardAnalysis calculate({
    required DateTime selectedMonth,
    required List<ExpenseNode> expenseRoots,
    required List<TransactionMonthSummary> monthSummaries,
  }) {
    final normalizedMonth = DateTime(selectedMonth.year, selectedMonth.month);
    final nodesById = _nodesById(expenseRoots);
    final summariesByMonth = {
      for (final summary in monthSummaries) _monthKey(summary.month): summary,
    };

    final monthlyCategories = _categoryProgress(
      roots: expenseRoots,
      nodesById: nodesById,
      summaries: [summariesByMonth[_monthKey(normalizedMonth)]],
      interval: PaymentInterval.monthly,
    );
    final yearlyCategories = _categoryProgress(
      roots: expenseRoots,
      nodesById: nodesById,
      summaries: [
        for (var month = 1; month <= 12; month++)
          summariesByMonth[_monthKey(DateTime(normalizedMonth.year, month))],
      ],
      interval: PaymentInterval.yearly,
    );

    return DashboardAnalysis(
      selectedMonth: normalizedMonth,
      monthly: _total(monthlyCategories),
      yearly: _total(yearlyCategories),
      monthlyCategories: monthlyCategories,
      yearlyCategories: yearlyCategories,
      monthlyHistory: _history(
        year: normalizedMonth.year,
        expenseRoots: expenseRoots,
        nodesById: nodesById,
        summariesByMonth: summariesByMonth,
        interval: PaymentInterval.monthly,
      ),
      yearlyHistory: _history(
        year: normalizedMonth.year,
        expenseRoots: expenseRoots,
        nodesById: nodesById,
        summariesByMonth: summariesByMonth,
        interval: PaymentInterval.yearly,
      ),
    );
  }

  Map<String, ExpenseNode> _nodesById(List<ExpenseNode> roots) {
    final result = <String, ExpenseNode>{};

    void collect(ExpenseNode node) {
      result[node.id] = node;
      for (final child in node.children) {
        collect(child);
      }
    }

    for (final root in roots) {
      collect(root);
    }
    return result;
  }

  List<DashboardCategoryProgress> _categoryProgress({
    required List<ExpenseNode> roots,
    required Map<String, ExpenseNode> nodesById,
    required List<TransactionMonthSummary?> summaries,
    required PaymentInterval interval,
  }) {
    final actualByNode = <String, int>{};
    for (final summary in summaries) {
      if (summary == null) continue;
      for (final entry in summary.categoryTotalsMinor.entries) {
        final node = nodesById[entry.key];
        if (node?.type != ExpenseType.variable || node?.interval != interval) {
          continue;
        }
        actualByNode.update(
          entry.key,
          (actual) => actual + entry.value,
          ifAbsent: () => entry.value,
        );
      }
    }

    DashboardCategoryProgress? progressFor(ExpenseNode node) {
      final isLeaf = node.children.isEmpty;
      if (isLeaf) {
        if (node.type != ExpenseType.variable || node.interval != interval) {
          return null;
        }
        return DashboardCategoryProgress(
          categoryId: node.id,
          categoryName: node.name,
          isGroup: false,
          actualMinor: actualByNode[node.id] ?? 0,
          plannedMinor: node.plannedAmountMinor ?? 0,
        );
      }

      final children = [
        for (final child in node.children)
          if (progressFor(child) case final progress?) progress,
      ];
      if (children.isEmpty) return null;

      return DashboardCategoryProgress(
        categoryId: node.id,
        categoryName: node.name,
        isGroup: true,
        children: children,
        actualMinor: children.fold<int>(
          0,
          (sum, child) => sum + child.actualMinor,
        ),
        plannedMinor: children.fold<int>(
          0,
          (sum, child) => sum + child.plannedMinor,
        ),
      );
    }

    return [
      for (final root in roots)
        if (progressFor(root) case final progress?) progress,
    ];
  }

  DashboardProgress _total(List<DashboardCategoryProgress> categories) {
    return DashboardProgress(
      actualMinor: categories.fold<int>(
        0,
        (sum, category) => sum + category.actualMinor,
      ),
      plannedMinor: categories.fold<int>(
        0,
        (sum, category) => sum + category.plannedMinor,
      ),
    );
  }

  List<DashboardHistoryPoint> _history({
    required int year,
    required List<ExpenseNode> expenseRoots,
    required Map<String, ExpenseNode> nodesById,
    required Map<String, TransactionMonthSummary> summariesByMonth,
    required PaymentInterval interval,
  }) {
    var yearToDateActual = 0;
    return [
      for (var month = 1; month <= 12; month++)
        () {
          final point = _historyPoint(
            DateTime(year, month),
            expenseRoots,
            nodesById,
            summariesByMonth,
            interval,
          );
          if (interval == PaymentInterval.yearly) {
            yearToDateActual += point.actualMinor;
            return DashboardHistoryPoint(
              month: point.month,
              actualMinor: yearToDateActual,
              plannedMinor: point.plannedMinor,
            );
          }
          return point;
        }(),
    ];
  }

  DashboardHistoryPoint _historyPoint(
    DateTime month,
    List<ExpenseNode> expenseRoots,
    Map<String, ExpenseNode> nodesById,
    Map<String, TransactionMonthSummary> summariesByMonth,
    PaymentInterval interval,
  ) {
    final categories = _categoryProgress(
      roots: expenseRoots,
      nodesById: nodesById,
      summaries: [summariesByMonth[_monthKey(month)]],
      interval: interval,
    );
    final total = _total(categories);
    return DashboardHistoryPoint(
      month: month,
      actualMinor: total.actualMinor,
      plannedMinor: total.plannedMinor,
    );
  }

  String _monthKey(DateTime date) => '${date.year}-${date.month}';
}
