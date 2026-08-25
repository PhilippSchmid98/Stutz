import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/shared/widgets/async_state_view.dart';

class DashboardCategoryDetailScreen extends ConsumerWidget {
  final DashboardCategoryProgress category;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const DashboardCategoryDetailScreen({
    super.key,
    required this.category,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.categoryName),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _CategorySummary(category: category, interval: interval),
          const SizedBox(height: 24),
          if (category.children.isNotEmpty)
            ...category.children.map(
              (child) => _ChildCategoryRow(
                category: child,
                selectedMonth: selectedMonth,
                interval: interval,
              ),
            )
          else
            _CategoryTransactions(
              categoryId: category.categoryId,
              selectedMonth: selectedMonth,
              interval: interval,
            ),
        ],
      ),
    );
  }
}

class _CategorySummary extends StatelessWidget {
  final DashboardCategoryProgress category;
  final PaymentInterval interval;

  const _CategorySummary({required this.category, required this.interval});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = category.isOverBudget
        ? colorScheme.error
        : colorScheme.primary;
    final subtitle = interval == PaymentInterval.monthly
        ? 'Monatliche variable Ausgaben'
        : 'Jährliche variable Ausgaben seit Jahresbeginn';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(
              _amount(category.actual),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'von ${_amount(category.planned)} geplant',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: category.ratio.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              color: statusColor,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCategoryRow extends StatelessWidget {
  final DashboardCategoryProgress category;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const _ChildCategoryRow({
    required this.category,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(category.categoryName),
      subtitle: Text(
        '${_amount(category.actual)} von ${_amount(category.planned)}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardCategoryDetailScreen(
            category: category,
            selectedMonth: selectedMonth,
            interval: interval,
          ),
        ),
      ),
    );
  }
}

class _CategoryTransactions extends ConsumerWidget {
  final String categoryId;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const _CategoryTransactions({
    required this.categoryId,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(
      _categoryTransactionsProvider(
        _CategoryPeriod(
          categoryId: categoryId,
          selectedMonth: selectedMonth,
          interval: interval,
        ),
      ),
    );

    return AsyncStateView(
      state: transactionsAsync,
      errorMessage: 'Die Transaktionen konnten nicht geladen werden.',
      builder: (transactions) {
        if (transactions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Keine Ausgaben in diesem Zeitraum.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaktionen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...transactions.map(_TransactionRow.new),
          ],
        );
      },
    );
  }
}

final _categoryTransactionsProvider = FutureProvider.autoDispose
    .family<List<AppTransaction>, _CategoryPeriod>((ref, period) {
      final start = intervalStart(period.selectedMonth, period.interval);
      final end = intervalEnd(period.selectedMonth, period.interval);
      return ref
          .watch(transactionRepositoryProvider)
          .getCategoryTransactionsForPeriod(
            categoryId: period.categoryId,
            periodStart: start,
            periodEnd: end,
          );
    });

class _CategoryPeriod {
  final String categoryId;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const _CategoryPeriod({
    required this.categoryId,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  bool operator ==(Object other) =>
      other is _CategoryPeriod &&
      other.categoryId == categoryId &&
      other.selectedMonth.year == selectedMonth.year &&
      other.selectedMonth.month == selectedMonth.month &&
      other.interval == interval;

  @override
  int get hashCode => Object.hash(
    categoryId,
    selectedMonth.year,
    selectedMonth.month,
    interval,
  );
}

DateTime intervalStart(DateTime month, PaymentInterval interval) {
  return TransactionMonth.startOfMonth(
    interval == PaymentInterval.monthly ? month : DateTime(month.year),
  );
}

DateTime intervalEnd(DateTime month, PaymentInterval interval) {
  return TransactionMonth.startOfMonth(
    interval == PaymentInterval.monthly
        ? DateTime(month.year, month.month + 1)
        : DateTime(month.year, month.month + 1),
  );
}

class _TransactionRow extends StatelessWidget {
  final AppTransaction transaction;

  const _TransactionRow(this.transaction);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.receipt_long_outlined),
      title: Text(transaction.note ?? 'Ausgabe'),
      subtitle: Text(
        DateFormat('d. MMMM yyyy', 'de_CH').format(transaction.dateTime),
      ),
      trailing: Text(
        _amount(transaction.amount),
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

String _amount(double value) => NumberFormat.currency(
  locale: 'de_CH',
  symbol: 'CHF',
  decimalDigits: 2,
).format(value);
