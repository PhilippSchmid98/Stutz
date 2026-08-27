import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/application/dashboard_providers.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/dashboard/presentation/dashboard_category_detail_screen.dart';
import 'package:stutz/shared/widgets/async_state_view.dart';
import 'package:stutz/shared/widgets/cloud_status_icon.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(dashboardSelectedMonthProvider);
    final analysisAsync = ref.watch(dashboardAnalysisProvider);

    Future<void> chooseMonth() async {
      final selected = await showDialog<DateTime>(
        context: context,
        builder: (_) => _MonthPickerDialog(initialMonth: selectedMonth),
      );
      if (selected != null && context.mounted) {
        ref.read(dashboardSelectedMonthProvider.notifier).select(selected);
      }
    }

    final now = DateTime.now();
    final canMoveForward =
        selectedMonth.year < now.year ||
        (selectedMonth.year == now.year && selectedMonth.month < now.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Übersicht'),
        actions: const [CloudStatusIcon()],
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _PeriodSelector(
            selectedMonth: selectedMonth,
            canMoveForward: canMoveForward,
            onPrevious: () =>
                ref.read(dashboardSelectedMonthProvider.notifier).moveBy(-1),
            onNext: canMoveForward
                ? () => ref
                      .read(dashboardSelectedMonthProvider.notifier)
                      .moveBy(1)
                : null,
            onPickMonth: chooseMonth,
          ),
          Expanded(
            child: AsyncStateView(
              state: analysisAsync,
              errorMessage: 'Die Übersicht konnte nicht geladen werden.',
              onRetry: () => ref.invalidate(dashboardAnalysisProvider),
              builder: _DashboardContent.new,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final bool canMoveForward;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPickMonth;

  const _PeriodSelector({
    required this.selectedMonth,
    required this.canMoveForward,
    required this.onPrevious,
    required this.onNext,
    required this.onPickMonth,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final label = DateFormat('MMMM yyyy', 'de_CH').format(selectedMonth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Vorheriger Monat',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: onPickMonth,
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(
                label,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Nächster Monat',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime initialMonth;

  const _MonthPickerDialog({required this.initialMonth});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  static const _firstYear = 2020;
  late int _displayedYear;

  @override
  void initState() {
    super.initState();
    _displayedYear = widget.initialMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canGoBack = _displayedYear > _firstYear;
    final canGoForward = _displayedYear < now.year;

    return AlertDialog(
      title: const Text('Monat wählen'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Vorheriges Jahr',
                  onPressed: canGoBack
                      ? () => setState(() => _displayedYear--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    _displayedYear.toString(),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Nächstes Jahr',
                  onPressed: canGoForward
                      ? () => setState(() => _displayedYear++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                final isFuture =
                    _displayedYear == now.year && month > now.month;
                final isSelected =
                    _displayedYear == widget.initialMonth.year &&
                    month == widget.initialMonth.month;
                final label = DateFormat.MMM(
                  'de_CH',
                ).format(DateTime(_displayedYear, month)).replaceAll('.', '');

                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: TextButton(
                    onPressed: isFuture
                        ? null
                        : () => Navigator.pop(
                            context,
                            DateTime(_displayedYear, month),
                          ),
                    style: TextButton.styleFrom(
                      foregroundColor: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      backgroundColor: isSelected ? colorScheme.primary : null,
                    ),
                    child: Text(label),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }
}

class _DashboardContent extends HookWidget {
  final DashboardAnalysis analysis;

  const _DashboardContent(this.analysis);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        _BudgetProgressCard(
          title: 'Monatlich',
          subtitle: 'Bisher ausgegeben',
          progress: analysis.monthly,
          icon: Icons.calendar_view_month_outlined,
          categories: analysis.monthlyCategories,
          selectedMonth: analysis.selectedMonth,
          interval: PaymentInterval.monthly,
        ),
        const SizedBox(height: 12),
        _BudgetProgressCard(
          title: 'Jährlich · ${analysis.selectedMonth.year}',
          subtitle: 'Seit Jahresbeginn ausgegeben',
          progress: analysis.yearly,
          icon: Icons.calendar_today_outlined,
          categories: analysis.yearlyCategories,
          selectedMonth: analysis.selectedMonth,
          interval: PaymentInterval.yearly,
        ),
        const SizedBox(height: 12),
        _HistoryCard(analysis: analysis),
      ],
    );
  }
}

class _BudgetProgressCard extends HookWidget {
  final String title;
  final String subtitle;
  final DashboardProgress progress;
  final IconData icon;
  final List<DashboardCategoryProgress> categories;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const _BudgetProgressCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.categories,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(true);
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = progress.isOverBudget
        ? colorScheme.error
        : colorScheme.primary;
    final remainingLabel = progress.isOverBudget
        ? '${_amount(progress.actual - progress.planned)} über Budget'
        : '${_amount(progress.remaining)} verfügbar';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: statusColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isExpanded.value
                      ? 'Ausgaben ausblenden'
                      : 'Ausgaben anzeigen',
                  onPressed: () => isExpanded.value = !isExpanded.value,
                  icon: Icon(
                    isExpanded.value ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              _amount(progress.actual),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$subtitle von ${_amount(progress.planned)} geplant',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress.ratio.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              color: statusColor,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 10),
            Text(
              remainingLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isExpanded.value) ...[
              const SizedBox(height: 20),
              _TopExpenses(
                categories: categories,
                selectedMonth: selectedMonth,
                interval: interval,
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardIntervalDetailScreen(
                        categories: categories,
                        selectedMonth: selectedMonth,
                        interval: interval,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Alle Kategorien'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopExpenses extends StatelessWidget {
  final List<DashboardCategoryProgress> categories;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const _TopExpenses({
    required this.categories,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final expenses = _leafExpenses(categories)
      ..sort((left, right) => right.actual.compareTo(left.actual));
    final topExpenses = expenses.take(3).toList();

    if (topExpenses.isEmpty) {
      return Text(
        'Noch keine variablen Ausgaben geplant.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }

    return Column(
      children: [
        for (final expense in topExpenses)
          _ExpensePreviewRow(
            expense: expense,
            selectedMonth: selectedMonth,
            interval: interval,
          ),
      ],
    );
  }
}

class _ExpensePreviewRow extends StatelessWidget {
  final DashboardCategoryProgress expense;
  final DateTime selectedMonth;
  final PaymentInterval interval;

  const _ExpensePreviewRow({
    required this.expense,
    required this.selectedMonth,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = expense.isOverBudget
        ? colorScheme.error
        : colorScheme.primary;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardCategoryDetailScreen(
            category: expense,
            selectedMonth: selectedMonth,
            interval: interval,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(expense.categoryName)),
                Text(
                  '${_amount(expense.actual)} / ${_amount(expense.planned)}',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: expense.ratio.clamp(0.0, 1.0).toDouble(),
              minHeight: 5,
              borderRadius: BorderRadius.circular(3),
              color: statusColor,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DashboardAnalysis analysis;

  const _HistoryCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verlauf', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Variable Ausgaben je Monat',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _HistoryChart(
              history: analysis.monthlyHistory,
              selectedMonth: analysis.selectedMonth,
            ),
          ],
        ),
      ),
    );
  }
}

List<DashboardCategoryProgress> _leafExpenses(
  List<DashboardCategoryProgress> categories,
) {
  return [
    for (final category in categories)
      if (category.children.isEmpty)
        category
      else
        ..._leafExpenses(category.children),
  ];
}

class _HistoryChart extends StatelessWidget {
  final List<DashboardHistoryPoint> history;
  final DateTime selectedMonth;

  const _HistoryChart({required this.history, required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    final maxValue = history.fold<double>(
      0,
      (maximum, point) => [
        maximum,
        point.actual,
        point.planned,
      ].reduce((left, right) => left > right ? left : right),
    );
    final scale = maxValue == 0 ? 1.0 : maxValue;

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: history.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final point = history[index];
          final isSelected = point.month.month == selectedMonth.month;
          final colorScheme = Theme.of(context).colorScheme;
          final actualHeight = (point.actual / scale * 84).clamp(0.0, 84.0);
          final plannedHeight = (point.planned / scale * 84).clamp(0.0, 84.0);

          return SizedBox(
            width: 34,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 92,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 22,
                        height: plannedHeight.toDouble(),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: actualHeight.toDouble(),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.secondary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat(
                    'MMM',
                    'de_CH',
                  ).format(point.month).replaceAll('.', ''),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w800 : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _amount(double value) => NumberFormat.currency(
  locale: 'de_CH',
  symbol: 'CHF',
  decimalDigits: 2,
).format(value);
