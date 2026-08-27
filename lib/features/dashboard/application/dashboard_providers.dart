import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/dashboard/domain/services/dashboard_calculator.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

final dashboardSelectedMonthProvider =
    NotifierProvider<DashboardSelectedMonth, DateTime>(
      DashboardSelectedMonth.new,
    );

class DashboardSelectedMonth extends Notifier<DateTime> {
  @override
  DateTime build() => TransactionMonth.current();

  void select(DateTime month) {
    state = TransactionMonth.fromDateTime(month);
  }

  void moveBy(int months) {
    state = DateTime(state.year, state.month + months);
  }
}

final dashboardYearSummariesProvider = StreamProvider.autoDispose
    .family<List<TransactionMonthSummary>, int>((ref, year) {
      return ref
          .watch(transactionRepositoryProvider)
          .watchMonthSummariesForYear(year);
    });

final dashboardAnalysisProvider =
    Provider.autoDispose<AsyncValue<DashboardAnalysis>>((ref) {
      final selectedMonth = ref.watch(dashboardSelectedMonthProvider);
      final expensesAsync = ref.watch(expenseTreeProvider);
      final summariesAsync = ref.watch(
        dashboardYearSummariesProvider(selectedMonth.year),
      );

      return expensesAsync.when(
        loading: () => const AsyncLoading(),
        error: AsyncError.new,
        data: (expenseRoots) => summariesAsync.when(
          loading: () => const AsyncLoading(),
          error: AsyncError.new,
          data: (summaries) => AsyncData(
            const DashboardCalculator().calculate(
              selectedMonth: selectedMonth,
              expenseRoots: expenseRoots,
              monthSummaries: summaries,
            ),
          ),
        ),
      );
    });
