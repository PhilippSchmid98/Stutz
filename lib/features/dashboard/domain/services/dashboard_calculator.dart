import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

class DashboardCalculator {
  const DashboardCalculator();

  DashboardYearToDateAnalysis calculateYearToDate({
    required DateTime asOf,
    required List<ExpenseNode> expenseRoots,
    required List<TransactionMonthSummary> monthSummaries,
    required List<AppTransaction> currentMonthTransactions,
  }) {
    final date = DateTime(asOf.year, asOf.month, asOf.day);
    final yearStart = DateTime.utc(date.year);
    final nextYear = DateTime.utc(date.year + 1);
    final elapsedDays =
        DateTime.utc(
          date.year,
          date.month,
          date.day,
        ).difference(yearStart).inDays +
        1;
    final daysInYear = nextYear.difference(yearStart).inDays;
    final currentMonthStart = TransactionMonth.startOfMonth(date);
    final periodEnd = TransactionMonth.startOfDay(
      DateTime(date.year, date.month, date.day + 1),
    );
    final currentTotals = <String, int>{};
    for (final transaction in currentMonthTransactions) {
      if (transaction.dateTime.isBefore(currentMonthStart) ||
          !transaction.dateTime.isBefore(periodEnd)) {
        continue;
      }
      currentTotals.update(
        transaction.expenseNodeId,
        (value) => value + transaction.amountMinor,
        ifAbsent: () => transaction.amountMinor,
      );
    }

    final categories = _categoryProgress(
      roots: expenseRoots,
      nodesById: _nodesById(expenseRoots),
      summaries: [
        for (final summary in monthSummaries)
          if (summary.month.year == date.year &&
              summary.month.month < date.month)
            summary,
        TransactionMonthSummary(
          month: DateTime(date.year, date.month),
          transactionCount: currentMonthTransactions.length,
          categoryTotalsMinor: currentTotals,
        ),
      ],
      elapsedDays: elapsedDays,
      daysInYear: daysInYear,
    );
    return DashboardYearToDateAnalysis(
      asOf: date,
      elapsedDays: elapsedDays,
      daysInYear: daysInYear,
      total: _total(categories, includeExpected: true),
      categories: categories,
    );
  }

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
    PaymentInterval? interval,
    int? elapsedDays,
    int? daysInYear,
  }) {
    final actualByNode = <String, int>{};
    for (final summary in summaries) {
      if (summary == null) continue;
      for (final entry in summary.categoryTotalsMinor.entries) {
        final node = nodesById[entry.key];
        if (node?.type != ExpenseType.variable ||
            node?.interval == null ||
            (interval != null && node?.interval != interval)) {
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
        if (node.type != ExpenseType.variable ||
            node.interval == null ||
            (interval != null && node.interval != interval)) {
          return null;
        }
        final planned =
            (node.plannedAmountMinor ?? 0) *
            (interval == null && node.interval == PaymentInterval.monthly
                ? 12
                : 1);
        return DashboardCategoryProgress(
          categoryId: node.id,
          categoryName: node.name,
          isGroup: false,
          actualMinor: actualByNode[node.id] ?? 0,
          plannedMinor: planned,
          expectedMinor: elapsedDays == null || daysInYear == null
              ? null
              : divideMinorUnitsRounded(planned * elapsedDays, daysInYear),
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
        expectedMinor: elapsedDays == null
            ? null
            : children.fold<int>(0, (sum, child) => sum + child.expectedMinor!),
      );
    }

    return [
      for (final root in roots)
        if (progressFor(root) case final progress?) progress,
    ];
  }

  DashboardProgress _total(
    List<DashboardCategoryProgress> categories, {
    bool includeExpected = false,
  }) {
    return DashboardProgress(
      actualMinor: categories.fold<int>(
        0,
        (sum, category) => sum + category.actualMinor,
      ),
      plannedMinor: categories.fold<int>(
        0,
        (sum, category) => sum + category.plannedMinor,
      ),
      expectedMinor: includeExpected
          ? categories.fold<int>(
              0,
              (sum, category) => sum + category.expectedMinor!,
            )
          : null,
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
