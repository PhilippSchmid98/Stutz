import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/application/dashboard_providers.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/dashboard/presentation/dashboard_pace_widgets.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/shared/widgets/async_state_view.dart';

class DashboardIntervalDetailScreen extends ConsumerWidget {
  final List<DashboardCategoryProgress> categories;
  final DateTime selectedMonth;
  final PaymentInterval interval;
  final DateTime? yearToDateAsOf;

  const DashboardIntervalDetailScreen({
    super.key,
    required this.categories,
    required this.selectedMonth,
    required this.interval,
    this.yearToDateAsOf,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = yearToDateAsOf != null
        ? 'Jahresbilanz'
        : interval == PaymentInterval.monthly
        ? 'Monatliche Ausgaben'
        : 'Jährliche Ausgaben';

    Widget content(List<DashboardCategoryProgress> items, DateTime? asOf) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (items.isEmpty)
            _EmptyCategoryState(interval: interval, yearToDate: asOf != null)
          else
            ...items.map(
              (category) => _DashboardCategorySectionCard(
                category: category,
                selectedMonth: selectedMonth,
                interval: interval,
                yearToDateAsOf: asOf,
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: yearToDateAsOf == null
          ? content(categories, null)
          : AsyncStateView(
              state: ref.watch(dashboardYearToDateAnalysisProvider),
              errorMessage: 'Die Jahresbilanz konnte nicht geladen werden.',
              builder: (analysis) =>
                  content(analysis.categories, analysis.asOf),
            ),
    );
  }
}

class DashboardCategoryDetailScreen extends ConsumerWidget {
  final DashboardCategoryProgress category;
  final DateTime selectedMonth;
  final PaymentInterval interval;
  final DateTime? yearToDateAsOf;

  const DashboardCategoryDetailScreen({
    super.key,
    required this.category,
    required this.selectedMonth,
    required this.interval,
    this.yearToDateAsOf,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget content(DashboardCategoryProgress item, DateTime? asOf) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _CategorySummary(
            category: item,
            interval: interval,
            yearToDate: asOf != null,
          ),
          const SizedBox(height: 24),
          if (item.children.isNotEmpty)
            ...item.children.map(
              (child) => _DashboardCategoryProgressRow(
                category: child,
                selectedMonth: selectedMonth,
                interval: interval,
                yearToDateAsOf: asOf,
                depth: 0,
              ),
            )
          else
            _CategoryTransactions(
              categoryId: item.categoryId,
              selectedMonth: selectedMonth,
              interval: interval,
              yearToDateAsOf: asOf,
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category.categoryName),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: yearToDateAsOf == null
          ? content(category, null)
          : AsyncStateView(
              state: ref.watch(dashboardYearToDateAnalysisProvider),
              errorMessage: 'Die Jahresbilanz konnte nicht geladen werden.',
              builder: (analysis) {
                final item = _findCategory(
                  analysis.categories,
                  category.categoryId,
                );
                return item == null
                    ? const Center(
                        child: Text(
                          'Diese Kategorie ist nicht mehr in der Jahresbilanz.',
                        ),
                      )
                    : content(item, analysis.asOf);
              },
            ),
    );
  }
}

class _CategorySummary extends StatelessWidget {
  final DashboardCategoryProgress category;
  final PaymentInterval interval;
  final bool yearToDate;

  const _CategorySummary({
    required this.category,
    required this.interval,
    required this.yearToDate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor =
        (yearToDate ? category.isOverPace : category.isOverBudget)
        ? colorScheme.error
        : colorScheme.primary;
    final subtitle = yearToDate
        ? 'Variable Ausgaben seit Jahresbeginn'
        : interval == PaymentInterval.monthly
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
            if (yearToDate)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: _amount(category.actualMinor)),
                    TextSpan(
                      text: ' / ${_amount(category.plannedMinor)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                ),
              )
            else ...[
              Text(
                _amount(category.actualMinor),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'von ${_amount(category.plannedMinor)} geplant',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 14),
            DashboardProgressBar(progress: category),
            if (yearToDate) ...[
              const SizedBox(height: 8),
              DashboardPaceLabel(progress: category),
            ],
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
  final DateTime? yearToDateAsOf;

  const _DashboardCategorySectionCard({
    required this.category,
    required this.selectedMonth,
    required this.interval,
    this.yearToDateAsOf,
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
    final statusColor =
        (widget.yearToDateAsOf == null
            ? category.isOverBudget
            : category.isOverPace)
        ? colorScheme.error
        : colorScheme.primary;
    final hasChildren = category.children.isNotEmpty;
    final amountStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: statusColor,
      fontWeight: FontWeight.w800,
    );
    final amountLabel = widget.yearToDateAsOf == null
        ? Text(_amount(category.actualMinor), style: amountStyle)
        : DashboardAmountPair(
            actualMinor: category.actualMinor,
            plannedMinor: category.plannedMinor,
            style: amountStyle,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: !hasChildren && widget.yearToDateAsOf != null
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardCategoryDetailScreen(
                      category: category,
                      selectedMonth: widget.selectedMonth,
                      interval: widget.interval,
                      yearToDateAsOf: widget.yearToDateAsOf,
                    ),
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: widget.yearToDateAsOf == null ? 1 : 2,
                          child: Text(
                            category.categoryName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (widget.yearToDateAsOf != null)
                          const SizedBox(width: 8),
                        if (widget.yearToDateAsOf == null)
                          amountLabel
                        else
                          Flexible(flex: 3, child: amountLabel),
                        if (hasChildren)
                          IconButton(
                            tooltip: _isExpanded ? 'Einklappen' : 'Ausklappen',
                            onPressed: () =>
                                setState(() => _isExpanded = !_isExpanded),
                            icon: Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            visualDensity: VisualDensity.compact,
                          )
                        else if (widget.yearToDateAsOf != null)
                          const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DashboardProgressBar(progress: category, height: 6),
                    const SizedBox(height: 8),
                    if (widget.yearToDateAsOf == null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_amount(category.plannedMinor)} geplant',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    else
                      DashboardPaceLabel(progress: category),
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
                          yearToDateAsOf: widget.yearToDateAsOf,
                          depth: 0,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCategoryProgressRow extends StatefulWidget {
  final DashboardCategoryProgress category;
  final DateTime selectedMonth;
  final PaymentInterval interval;
  final DateTime? yearToDateAsOf;
  final int depth;

  const _DashboardCategoryProgressRow({
    required this.category,
    required this.selectedMonth,
    required this.interval,
    this.yearToDateAsOf,
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
    final statusColor =
        (widget.yearToDateAsOf == null
            ? category.isOverBudget
            : category.isOverPace)
        ? colorScheme.error
        : colorScheme.primary;
    final amountStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: statusColor,
      fontWeight: FontWeight.bold,
    );
    final amountLabel = widget.yearToDateAsOf == null
        ? Text(_amount(category.actualMinor), style: amountStyle)
        : DashboardAmountPair(
            actualMinor: category.actualMinor,
            plannedMinor: category.plannedMinor,
            style: amountStyle,
          );

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
                        yearToDateAsOf: widget.yearToDateAsOf,
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
                        flex: widget.yearToDateAsOf == null ? 1 : 2,
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
                      if (widget.yearToDateAsOf != null)
                        const SizedBox(width: 8),
                      if (widget.yearToDateAsOf == null)
                        amountLabel
                      else
                        Flexible(flex: 3, child: amountLabel),
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
                  DashboardProgressBar(progress: category, height: 5),
                  const SizedBox(height: 5),
                  if (widget.yearToDateAsOf == null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_amount(category.plannedMinor)} geplant',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    DashboardPaceLabel(progress: category),
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
              yearToDateAsOf: widget.yearToDateAsOf,
              depth: widget.depth + 1,
            ),
      ],
    );
  }
}

class _EmptyCategoryState extends StatelessWidget {
  final PaymentInterval interval;
  final bool yearToDate;

  const _EmptyCategoryState({required this.interval, required this.yearToDate});

  @override
  Widget build(BuildContext context) {
    final message = yearToDate
        ? 'Noch keine variablen Kategorien geplant.'
        : interval == PaymentInterval.monthly
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
  final DateTime? yearToDateAsOf;

  const _CategoryTransactions({
    required this.categoryId,
    required this.selectedMonth,
    required this.interval,
    this.yearToDateAsOf,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = _CategoryPeriod(
      categoryId: categoryId,
      selectedMonth: selectedMonth,
      interval: interval,
      yearToDateAsOf: yearToDateAsOf,
    );
    final transactionsAsync = yearToDateAsOf == null
        ? ref.watch(_categoryTransactionsProvider(period))
        : ref.watch(_yearToDateCategoryTransactionsProvider(period));

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

final _yearToDateCategoryTransactionsProvider = StreamProvider.autoDispose
    .family<List<AppTransaction>, _CategoryPeriod>((ref, period) {
      final asOf = period.yearToDateAsOf!;
      return ref
          .watch(transactionRepositoryProvider)
          .watchCategoryTransactionsForPeriod(
            categoryId: period.categoryId,
            periodStart: TransactionMonth.startOfMonth(DateTime(asOf.year)),
            periodEnd: TransactionMonth.startOfDay(
              DateTime(asOf.year, asOf.month, asOf.day + 1),
            ),
          );
    });

class _CategoryPeriod {
  final String categoryId;
  final DateTime selectedMonth;
  final PaymentInterval interval;
  final DateTime? yearToDateAsOf;

  const _CategoryPeriod({
    required this.categoryId,
    required this.selectedMonth,
    required this.interval,
    this.yearToDateAsOf,
  });

  @override
  bool operator ==(Object other) =>
      other is _CategoryPeriod &&
      other.categoryId == categoryId &&
      other.selectedMonth.year == selectedMonth.year &&
      other.selectedMonth.month == selectedMonth.month &&
      other.interval == interval &&
      other.yearToDateAsOf == yearToDateAsOf;

  @override
  int get hashCode => Object.hash(
    categoryId,
    selectedMonth.year,
    selectedMonth.month,
    interval,
    yearToDateAsOf,
  );
}

DashboardCategoryProgress? _findCategory(
  List<DashboardCategoryProgress> categories,
  String id,
) {
  for (final category in categories) {
    if (category.categoryId == id) return category;
    final child = _findCategory(category.children, id);
    if (child != null) return child;
  }
  return null;
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
        _amount(transaction.amountMinor),
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

String _amount(int valueMinor) => formatChfMinor(valueMinor);
