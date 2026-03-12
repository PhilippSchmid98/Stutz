import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/expense_node.dart';
import 'package:stutz/domain/models/transaction.dart';
import 'package:stutz/domain/models/yearly_budget_node.dart';

/// Pure domain service for yearly budget calculations.
class YearlyCalculator {
  const YearlyCalculator();

  /// Calculates the offset factor for [year] based on [firstTxnDate].
  ///
  /// When the user started using the app mid-year, a fraction of the yearly
  /// budget is "pre-consumed" because the app cannot track spending before
  /// first use.
  ///
  /// Example: first transaction on April 1 → offset ≈ 90/365 ≈ 0.247.
  ///
  /// Returns 0.0 if [firstTxnDate] is null or belongs to a different year.
  double calculateOffsetFactor(int year, DateTime? firstTxnDate) {
    if (firstTxnDate == null) return 0.0;
    if (firstTxnDate.year != year) return 0.0;

    final daysInYear = _isLeapYear(year) ? 366 : 365;
    final startDay = _dayOfYear(firstTxnDate);
    return (startDay - 1) / daysInYear;
  }

  /// Builds the yearly budget vs. actual tree for [year].
  ///
  /// Fixed expense nodes (and their subtrees) are excluded.
  /// Nodes with no planned amount and no actual spending are pruned.
  List<YearlyBudgetNode> buildYearlyDetail(
    List<ExpenseNode> rootNodes,
    List<AppTransaction> allTransactions,
    int year,
  ) {
    final txnsInYear =
        allTransactions.where((t) => t.dateTime.year == year).toList();

    final DateTime? firstTxnDate = allTransactions.isEmpty
        ? null
        : allTransactions
            .map((e) => e.dateTime)
            .reduce((a, b) => a.isBefore(b) ? a : b);

    final offsetFactor = calculateOffsetFactor(year, firstTxnDate);

    YearlyBudgetNode? processNode(ExpenseNode node) {
      if (node.type == ExpenseType.fixed) return null;

      final keptChildren = <YearlyBudgetNode>[];
      for (var child in node.children) {
        final processed = processNode(child);
        if (processed != null) keptChildren.add(processed);
      }

      final ownActual = txnsInYear
          .where((t) => t.expenseNodeId == node.id)
          .fold(0.0, (sum, t) => sum + t.amount);

      double ownPlanned = 0.0;
      if (node.plannedAmount != null) {
        ownPlanned = node.interval == PaymentInterval.yearly
            ? node.plannedAmount!
            : node.plannedAmount! * 12;
      }

      final ownOffset = ownPlanned * offsetFactor;

      if (keptChildren.isEmpty && ownActual == 0 && ownPlanned == 0) {
        return null;
      }

      return YearlyBudgetNode(
        node: node,
        planned: ownPlanned +
            keptChildren.fold(0.0, (sum, c) => sum + c.planned),
        actual: ownActual +
            keptChildren.fold(0.0, (sum, c) => sum + c.actual),
        offset: ownOffset +
            keptChildren.fold(0.0, (sum, c) => sum + c.offset),
        children: keptChildren,
      );
    }

    final result = <YearlyBudgetNode>[];
    for (var root in rootNodes) {
      final processed = processNode(root);
      if (processed != null) result.add(processed);
    }
    return result;
  }

  bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Returns the 1-based day-of-year for [date].
  int _dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }
}
