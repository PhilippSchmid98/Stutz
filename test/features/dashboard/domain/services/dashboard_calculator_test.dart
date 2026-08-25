import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/domain/services/dashboard_calculator.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

import '../../../../helpers/test_data.dart';

void main() {
  const calculator = DashboardCalculator();

  final expenseRoots = [
    makeExpense(
      id: 'home',
      name: 'Home',
      plannedAmount: null,
      interval: null,
      type: null,
      children: [
        makeExpense(id: 'groceries', name: 'Groceries', plannedAmount: 500),
        makeExpense(
          id: 'tech',
          name: 'Tech',
          plannedAmount: 2000,
          interval: PaymentInterval.yearly,
        ),
      ],
    ),
  ];

  test('keeps a yearly purchase out of monthly progress', () {
    final analysis = calculator.calculate(
      selectedMonth: DateTime(2026, 6),
      expenseRoots: expenseRoots,
      monthSummaries: [
        TransactionMonthSummary(
          month: DateTime(2026, 6),
          transactionCount: 2,
          categoryTotals: {'groceries': 300, 'tech': 1000},
        ),
      ],
    );

    expect(analysis.monthly.actual, 300);
    expect(analysis.monthly.planned, 500);
    expect(analysis.yearly.actual, 1000);
    expect(analysis.yearly.planned, 2000);
  });

  test('reclassifies historical totals from the current category interval', () {
    final analysis = calculator.calculate(
      selectedMonth: DateTime(2026, 6),
      expenseRoots: [
        makeExpense(
          id: 'tech',
          plannedAmount: 2000,
          interval: PaymentInterval.monthly,
        ),
      ],
      monthSummaries: [
        TransactionMonthSummary(
          month: DateTime(2026, 1),
          transactionCount: 1,
          categoryTotals: {'tech': 1000},
        ),
      ],
    );

    expect(analysis.monthly.actual, 0);
    expect(analysis.yearly.actual, 0);
    expect(analysis.monthlyHistory.first.actual, 1000);
    expect(analysis.yearlyHistory.first.actual, 0);
  });

  test('rolls category values up to the top-level group', () {
    final analysis = calculator.calculate(
      selectedMonth: DateTime(2026, 6),
      expenseRoots: expenseRoots,
      monthSummaries: [
        TransactionMonthSummary(
          month: DateTime(2026, 6),
          transactionCount: 2,
          categoryTotals: {'groceries': 300, 'tech': 1000},
        ),
      ],
    );

    final home = analysis.monthlyCategories.single;
    expect(home.categoryName, 'Home');
    expect(home.isGroup, isTrue);
    expect(home.actual, 300);
    expect(home.planned, 500);
  });

  test(
    'excludes fixed leaves and fixed-only groups from every dashboard view',
    () {
      final analysis = calculator.calculate(
        selectedMonth: DateTime(2026, 6),
        expenseRoots: [
          makeExpense(
            id: 'living',
            name: 'Living',
            plannedAmount: null,
            interval: null,
            type: null,
            children: [
              makeExpense(
                id: 'rent',
                name: 'Rent',
                plannedAmount: 1500,
                type: ExpenseType.fixed,
              ),
              makeExpense(
                id: 'groceries',
                name: 'Groceries',
                plannedAmount: 500,
              ),
            ],
          ),
          makeExpense(
            id: 'fixed-only',
            name: 'Subscriptions',
            plannedAmount: null,
            interval: null,
            type: null,
            children: [
              makeExpense(
                id: 'insurance',
                name: 'Insurance',
                plannedAmount: 2400,
                interval: PaymentInterval.yearly,
                type: ExpenseType.fixed,
              ),
            ],
          ),
        ],
        monthSummaries: [
          TransactionMonthSummary(
            month: DateTime(2026, 6),
            transactionCount: 2,
            categoryTotals: {'rent': 1500, 'groceries': 300},
          ),
        ],
      );

      expect(analysis.monthly.actual, 300);
      expect(analysis.monthly.planned, 500);
      expect(analysis.monthlyHistory[5].actual, 300);
      expect(analysis.monthlyCategories, hasLength(1));
      expect(analysis.monthlyCategories.single.categoryName, 'Living');
      expect(
        analysis.monthlyCategories.single.children.map(
          (child) => child.categoryName,
        ),
        ['Groceries'],
      );
      expect(analysis.yearlyCategories, isEmpty);
    },
  );

  test('returns all months of the selected year with zero-filled gaps', () {
    final analysis = calculator.calculate(
      selectedMonth: DateTime(2026, 6),
      expenseRoots: expenseRoots,
      monthSummaries: [
        TransactionMonthSummary(
          month: DateTime(2026, 1),
          transactionCount: 1,
          categoryTotals: {'groceries': 250},
        ),
      ],
    );

    expect(analysis.monthlyHistory, hasLength(12));
    expect(analysis.monthlyHistory.first.actual, 250);
    expect(analysis.monthlyHistory[1].actual, 0);
    expect(analysis.monthlyHistory.first.planned, 500);
  });

  test('accumulates yearly history from January through each month', () {
    final analysis = calculator.calculate(
      selectedMonth: DateTime(2026, 6),
      expenseRoots: expenseRoots,
      monthSummaries: [
        TransactionMonthSummary(
          month: DateTime(2026, 1),
          transactionCount: 1,
          categoryTotals: {'tech': 100},
        ),
        TransactionMonthSummary(
          month: DateTime(2026, 6),
          transactionCount: 1,
          categoryTotals: {'tech': 1000},
        ),
      ],
    );

    expect(analysis.yearlyHistory.first.actual, 100);
    expect(analysis.yearlyHistory[4].actual, 100);
    expect(analysis.yearlyHistory[5].actual, 1100);
    expect(analysis.yearlyHistory[5].planned, 2000);
  });
}
