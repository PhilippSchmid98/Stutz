import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/shared/widgets/async_state_view.dart';

class DashboardIntervalDetailScreen extends StatelessWidget {
  final List<DashboardCategoryProgress> categories;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const DashboardIntervalDetailScreen({
    super.key,
    required this.categories,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final title = interval == PaymentInterval.monthly
        ? 'Monatliche Ausgaben'
        : 'Jährliche Ausgaben';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (categories.isEmpty)
            _EmptyCategoryState(interval: interval)
          else
            ...categories.map(
              (category) => _DashboardCategorySectionCard(
                category: category,
                selectedMonth: selectedMonth,
                interval: interval,
              ),
            ),
        ],
      ),
    );
  }
}

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
              (child) => _DashboardCategoryProgressRow(
                category: child,
                selectedMonth: selectedMonth,
                interval: interval,
                depth: 0,
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

class _DashboardCategorySectionCard extends StatefulWidget {
  final DashboardCategoryProgress category;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const _DashboardCategorySectionCard({
    required this.category,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  State<_DashboardCategorySectionCard> createState() =>
      _DashboardCategorySectionCardState();
}

class _DashboardCategorySectionCardState
    extends State<_DashboardCategorySectionCard> {
  var _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = category.isOverBudget
        ? colorScheme.error
        : colorScheme.primary;
    final hasChildren = category.children.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder_outlined, color: statusColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          category.categoryName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        _amount(category.actual),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (hasChildren)
                        IconButton(
                          tooltip: _isExpanded ? 'Einklappen' : 'Ausklappen',
                          onPressed: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: category.ratio.clamp(0.0, 1.0).toDouble(),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    color: statusColor,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_amount(category.planned)} geplant',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasChildren && _isExpanded) ...[
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final child in category.children)
                      _DashboardCategoryProgressRow(
                        category: child,
                        selectedMonth: widget.selectedMonth,
                        interval: widget.interval,
                        depth: 0,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardCategoryProgressRow extends StatefulWidget {
  final DashboardCategoryProgress category;
  final DateTime selectedMonth;
  final PaymentInterval interval;
  final int depth;

  const _DashboardCategoryProgressRow({
    required this.category,
    required this.selectedMonth,
    required this.interval,
    required this.depth,
  });

  @override
  State<_DashboardCategoryProgressRow> createState() =>
      _DashboardCategoryProgressRowState();
}

class _DashboardCategoryProgressRowState
    extends State<_DashboardCategoryProgressRow> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.category.isGroup;
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = category.isOverBudget
        ? colorScheme.error
        : colorScheme.primary;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.depth * 16.0, bottom: 4),
          child: InkWell(
            onTap: category.isGroup
                ? () => setState(() => _isExpanded = !_isExpanded)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardCategoryDetailScreen(
                        category: category,
                        selectedMonth: widget.selectedMonth,
                        interval: widget.interval,
                      ),
                    ),
                  ),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (category.isGroup)
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        )
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 4),
                      Icon(
                        category.isGroup
                            ? Icons.folder_outlined
                            : Icons.sell_outlined,
                        size: 18,
                        color: category.isGroup
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.categoryName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: category.isGroup
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                      Text(
                        _amount(category.actual),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 18,
                        child: category.isGroup
                            ? null
                            : Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: category.ratio.clamp(0.0, 1.0).toDouble(),
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(3),
                    color: statusColor,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_amount(category.planned)} geplant',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (category.isGroup && _isExpanded)
          for (final child in category.children)
            _DashboardCategoryProgressRow(
              category: child,
              selectedMonth: widget.selectedMonth,
              interval: widget.interval,
              depth: widget.depth + 1,
            ),
      ],
    );
  }
}

class _EmptyCategoryState extends StatelessWidget {
  final PaymentInterval interval;

  const _EmptyCategoryState({required this.interval});

  @override
  Widget build(BuildContext context) {
    final message = interval == PaymentInterval.monthly
        ? 'Noch keine monatlichen variablen Kategorien geplant.'
        : 'Noch keine jährlichen variablen Kategorien geplant.';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        : DateTime(month.year + 1),
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
