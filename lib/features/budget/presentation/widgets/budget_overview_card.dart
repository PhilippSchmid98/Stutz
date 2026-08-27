import 'package:flutter/material.dart';
import 'package:stutz/features/budget/domain/view_models/budget_summary.dart';

class BudgetOverviewCard extends StatelessWidget {
  final BudgetSummary summary;

  const BudgetOverviewCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.balance >= 0;
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
                        value: summary.averageMonthlyIncome,
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
                        value: summary.monthlyExpenses,
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
                      value: summary.yearlyIncome,
                      color: colorScheme.primary,
                    ),
                    _BudgetMetricData(
                      label: 'Jährliche Fixkosten',
                      value: summary.fixedYearlyExpenses,
                    ),
                    _BudgetMetricData(
                      label: 'Jährliche variable Ausgaben',
                      value: summary.variableYearlyExpenses,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: colorScheme.outlineVariant),
                const SizedBox(height: 16),
                _BudgetSummarySection(
                  title: 'Monatliche Ausgaben',
                  leftLabel: 'Fixkosten',
                  leftValue: summary.fixedMonthlyExpenses,
                  rightLabel: 'Variable Ausgaben',
                  rightValue: summary.variableMonthlyExpenses,
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
          "${isPositive ? '+' : ''} ${summary.balance.toStringAsFixed(2)} CHF",
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
            value: metric.value,
            color: metric.color,
          ),
      ],
    );
  }
}

class _BudgetMetricData {
  final String label;
  final double value;
  final Color? color;

  const _BudgetMetricData({
    required this.label,
    required this.value,
    this.color,
  });
}

class _BudgetMetricRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;

  const _BudgetMetricRow({
    required this.label,
    required this.value,
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
            '${value.toStringAsFixed(2)} CHF',
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
  final double leftValue;
  final String rightLabel;
  final double rightValue;

  const _BudgetSummarySection({
    required this.title,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
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
                value: leftValue,
                valueStyle: valueStyle,
              ),
            ),
            Container(width: 1, height: 36, color: colorScheme.outlineVariant),
            const SizedBox(width: 16),
            Expanded(
              child: _BudgetMetric(
                label: rightLabel,
                value: rightValue,
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
  final double value;
  final TextStyle? valueStyle;
  final bool alignEnd;

  const _BudgetMetric({
    required this.label,
    required this.value,
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
        Text('${value.toStringAsFixed(2)} CHF', style: valueStyle),
      ],
    );
  }
}
