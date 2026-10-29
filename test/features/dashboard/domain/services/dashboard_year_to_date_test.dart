import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/domain/services/dashboard_calculator.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

import '../../../../helpers/test_data.dart';

void main() {
  const calculator = DashboardCalculator();

  test(
    'combines variable intervals through the cutoff and rolls up groups',
    () {
      final result = calculator.calculateYearToDate(
        asOf: DateTime(2024, 7, 1),
        expenseRoots: [
          makeExpense(
            id: 'group',
            plannedAmountMinor: null,
            type: null,
            interval: null,
            children: [
              makeExpense(id: 'monthly', plannedAmountMinor: 10000),
              makeExpense(
                id: 'annual',
                plannedAmountMinor: 20000,
                interval: PaymentInterval.yearly,
              ),
              makeExpense(
                id: 'fixed',
                plannedAmountMinor: 99999,
                type: ExpenseType.fixed,
              ),
            ],
          ),
        ],
        monthSummaries: [
          TransactionMonthSummary(
            month: DateTime(2024, 1),
            transactionCount: 3,
            categoryTotalsMinor: {
              'monthly': 10000,
              'annual': 5000,
              'fixed': 99999,
              'missing': 99999,
            },
          ),
          TransactionMonthSummary(
            month: DateTime(2024, 6),
            transactionCount: 1,
            categoryTotalsMinor: {'monthly': 5000},
          ),
          TransactionMonthSummary(
            month: DateTime(2024, 7),
            transactionCount: 1,
            categoryTotalsMinor: {'monthly': 999999},
          ),
          TransactionMonthSummary(
            month: DateTime(2023, 1),
            transactionCount: 1,
            categoryTotalsMinor: {'monthly': 999999},
          ),
        ],
        currentMonthTransactions: [
          makeTransaction(
            id: 'monthly-today',
            expenseNodeId: 'monthly',
            amountMinor: 20000,
            dateTime: DateTime.utc(2024, 7, 1, 10),
          ),
          makeTransaction(
            id: 'annual-today',
            expenseNodeId: 'annual',
            amountMinor: 7000,
            dateTime: DateTime.utc(2024, 7, 1, 12),
          ),
          makeTransaction(
            id: 'future',
            expenseNodeId: 'annual',
            amountMinor: 999999,
            dateTime: DateTime.utc(2024, 7, 1, 22),
          ),
          makeTransaction(
            id: 'before-month',
            expenseNodeId: 'annual',
            amountMinor: 999999,
            dateTime: DateTime.utc(2024, 6, 30, 21, 59),
          ),
        ],
      );

      expect(result.elapsedDays, 183);
      expect(result.daysInYear, 366);
      expect(result.total.actualMinor, 47000);
      expect(result.total.plannedMinor, 140000);
      expect(result.total.expectedMinor, 70000);
      expect(result.total.isOverPace, isFalse);
      final group = result.categories.single;
      expect(group.actualMinor, result.total.actualMinor);
      expect(group.plannedMinor, result.total.plannedMinor);
      expect(group.expectedMinor, result.total.expectedMinor);
      expect(group.children, hasLength(2));
      expect(group.children[0].actualMinor, 35000);
      expect(group.children[0].plannedMinor, 120000);
      expect(group.children[1].actualMinor, 12000);
      expect(group.children[1].expectedMinor, 10000);
      expect(group.children[1].isOverPace, isTrue);
      expect(group.children[1].isOverBudget, isFalse);
    },
  );

  test('handles new year, leap day, year end, and per-leaf rounding', () {
    final roots = [
      makeExpense(
        id: 'one',
        plannedAmountMinor: 1,
        interval: PaymentInterval.yearly,
      ),
      makeExpense(
        id: 'two',
        plannedAmountMinor: 1,
        interval: PaymentInterval.yearly,
      ),
    ];
    DashboardYearToDateAnalysis resultFor(DateTime date) =>
        calculator.calculateYearToDate(
          asOf: date,
          expenseRoots: roots,
          monthSummaries: [],
          currentMonthTransactions: [],
        );

    final first = resultFor(DateTime(2024));
    expect(first.elapsedDays, 1);
    expect(first.daysInYear, 366);
    expect(first.total.expectedMinor, 0);

    final leap = resultFor(DateTime(2024, 2, 29));
    expect(leap.elapsedDays, 60);
    expect(leap.daysInYear, 366);

    final half = resultFor(DateTime(2024, 7, 1));
    expect(half.total.plannedMinor, 2);
    expect(half.total.expectedMinor, 2);

    final last = resultFor(DateTime(2025, 12, 31));
    expect(last.elapsedDays, 365);
    expect(last.daysInYear, 365);
    expect(last.total.expectedMinor, last.total.plannedMinor);
  });

  test('handles an empty tree without a budget or division by zero', () {
    final result = calculator.calculateYearToDate(
      asOf: DateTime(2026, 1, 1),
      expenseRoots: [],
      monthSummaries: [],
      currentMonthTransactions: [],
    );
    expect(result.categories, isEmpty);
    expect(result.total.actualMinor, 0);
    expect(result.total.plannedMinor, 0);
    expect(result.total.expectedMinor, 0);
    expect(result.total.ratio, 0);
  });
}
