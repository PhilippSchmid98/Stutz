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
      final selected = await showDatePicker(
        context: context,
        initialDate: selectedMonth,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        helpText: 'Monat wählen',
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

class _DashboardContent extends HookWidget {
  final DashboardAnalysis analysis;

  const _DashboardContent(this.analysis);

  @override
  Widget build(BuildContext context) {
    final interval = useState(PaymentInterval.monthly);
    final categories = interval.value == PaymentInterval.monthly
        ? analysis.monthlyCategories
        : analysis.yearlyCategories;
    final history = interval.value == PaymentInterval.monthly
        ? analysis.monthlyHistory
        : analysis.yearlyHistory;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        _BudgetProgressCard(
          title: 'Monatliche variable Ausgaben',
          subtitle: 'Bisher ausgegeben',
          progress: analysis.monthly,
          icon: Icons.calendar_view_month_outlined,
        ),
        const SizedBox(height: 12),
        _BudgetProgressCard(
          title: 'Jährliche variable Ausgaben · ${analysis.selectedMonth.year}',
          subtitle: 'Seit Jahresbeginn ausgegeben',
          progress: analysis.yearly,
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 28),
        Text('Nach Kategorie', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SegmentedButton<PaymentInterval>(
          segments: const [
            ButtonSegment(
              value: PaymentInterval.monthly,
              icon: Icon(Icons.calendar_view_month_outlined),
              label: Text('Monatlich'),
            ),
            ButtonSegment(
              value: PaymentInterval.yearly,
              icon: Icon(Icons.calendar_today_outlined),
              label: Text('Jährlich'),
            ),
          ],
          selected: {interval.value},
          onSelectionChanged: (selection) => interval.value = selection.single,
        ),
        const SizedBox(height: 12),
        if (categories.every((category) => category.planned == 0))
          _EmptyBudgetState(interval: interval.value)
        else
          ...categories.map(
            (category) => _CategoryProgressRow(
              category,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardCategoryDetailScreen(
                    category: category,
                    selectedMonth: analysis.selectedMonth,
                    interval: interval.value,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 28),
        Text('Verlauf', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          interval.value == PaymentInterval.monthly
              ? 'Variable Ausgaben je Monat'
              : 'Kumulierte variable Jahresausgaben',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _HistoryChart(history: history, selectedMonth: analysis.selectedMonth),
      ],
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final DashboardProgress progress;
  final IconData icon;

  const _BudgetProgressCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  final DashboardCategoryProgress category;
  final VoidCallback onTap;

  const _CategoryProgressRow(this.category, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = category.isOverBudget
        ? colorScheme.error
        : colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      category.isGroup
                          ? Icons.folder_outlined
                          : Icons.sell_outlined,
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category.categoryName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _amount(category.actual),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
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
        ),
      ),
    );
  }
}

class _EmptyBudgetState extends StatelessWidget {
  final PaymentInterval interval;

  const _EmptyBudgetState({required this.interval});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Text(
        interval == PaymentInterval.monthly
            ? 'Noch keine monatlichen variablen Kategorien geplant.'
            : 'Noch keine jährlichen variablen Kategorien geplant.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
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
