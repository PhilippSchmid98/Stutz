import 'package:material_ui/material_ui.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/view_models/budget_summary.dart';

class BudgetOverviewCard extends StatelessWidget {
  final BudgetSummary summary;

  const BudgetOverviewCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.balanceMinor >= 0;
    final colorScheme = Theme.of(context).colorScheme;
    final balanceColor = isPositive ? colorScheme.primary : colorScheme.error;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: balanceColor.withValues(alpha: 0.35)),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                Text(
                  "VERFÜGBAR NACH GEPLANTEN AUSGABEN",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBalance(context, balanceColor, isPositive),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _BudgetMetric(
                        label: 'Ø Einnahmen pro Monat',
                        valueMinor: summary.averageMonthlyIncomeMinor,
                        valueStyle: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _BudgetMetric(
                        label: 'Geplante Ausgaben pro Monat',
                        valueMinor: summary.monthlyExpensesMinor,
                        valueStyle: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                _BudgetMetricList(
                  title: 'Jahresplanung',
                  metrics: [
                    _BudgetMetricData(
                      label: 'Jahreseinnahmen',
                      valueMinor: summary.totalYearlyIncomeMinor,
                      color: colorScheme.primary,
                    ),
                    _BudgetMetricData(
                      label: 'Jährliche Fixkosten',
                      valueMinor: summary.fixedYearlyExpensesMinor,
                    ),
                    _BudgetMetricData(
                      label: 'Jährliche variable Ausgaben',
                      valueMinor: summary.variableYearlyExpensesMinor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: colorScheme.outlineVariant),
                const SizedBox(height: 16),
                _BudgetSummarySection(
                  title: 'Monatliche Ausgaben',
                  leftLabel: 'Fixkosten',
                  leftValueMinor: summary.fixedMonthlyExpensesMinor,
                  rightLabel: 'Variable Ausgaben',
                  rightValueMinor: summary.variableMonthlyExpensesMinor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalance(
    BuildContext context,
    Color balanceColor,
    bool isPositive,
  ) {
    return Column(
      children: [
        Text(
          '${isPositive ? '+' : ''} ${formatChfMinor(summary.balanceMinor)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: balanceColor,
          ),
        ),
        Text(
          isPositive
              ? "Verfügbarer Überschuss pro Monat"
              : "Budgetdefizit pro Monat",
          style: TextStyle(
            color: balanceColor.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BudgetMetricList extends StatelessWidget {
  final String title;
  final List<_BudgetMetricData> metrics;

  const _BudgetMetricList({required this.title, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        for (final metric in metrics)
          _BudgetMetricRow(
            label: metric.label,
            valueMinor: metric.valueMinor,
            color: metric.color,
          ),
      ],
    );
  }
}

class _BudgetMetricData {
  final String label;
  final int valueMinor;
  final Color? color;

  const _BudgetMetricData({
    required this.label,
    required this.valueMinor,
    this.color,
  });
}

class _BudgetMetricRow extends StatelessWidget {
  final String label;
  final int valueMinor;
  final Color? color;

  const _BudgetMetricRow({
    required this.label,
    required this.valueMinor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            formatChfMinor(valueMinor),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetSummarySection extends StatelessWidget {
  final String title;
  final String leftLabel;
  final int leftValueMinor;
  final String rightLabel;
  final int rightValueMinor;

  const _BudgetSummarySection({
    required this.title,
    required this.leftLabel,
    required this.leftValueMinor,
    required this.rightLabel,
    required this.rightValueMinor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _BudgetMetric(
                label: leftLabel,
                valueMinor: leftValueMinor,
                valueStyle: valueStyle,
              ),
            ),
            Container(width: 1, height: 36, color: colorScheme.outlineVariant),
            const SizedBox(width: 16),
            Expanded(
              child: _BudgetMetric(
                label: rightLabel,
                valueMinor: rightValueMinor,
                valueStyle: valueStyle,
                alignEnd: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  final String label;
  final int valueMinor;
  final TextStyle? valueStyle;
  final bool alignEnd;

  const _BudgetMetric({
    required this.label,
    required this.valueMinor,
    required this.valueStyle,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(formatChfMinor(valueMinor), style: valueStyle),
      ],
    );
  }
}
