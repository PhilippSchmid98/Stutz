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
    final availableAfterFixed = summary.monthlyIncome - summary.fixedExpenses;

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
                _buildIncomeExpenseTotals(context),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                _buildFixedCostAvailability(context, availableAfterFixed),
                const SizedBox(height: 16),
                _buildExpenseBreakdown(context),
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
          isPositive ? "Verfügbarer Überschuss" : "Budgetdefizit",
          style: TextStyle(
            color: balanceColor.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseTotals(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _OverviewItem(
            label: "Einnahmen",
            value: summary.monthlyIncome,
            color: colorScheme.primary,
          ),
        ),
        Expanded(
          child: _OverviewItem(
            label: "Geplante Ausgaben",
            value: summary.monthlyExpenses,
            color: colorScheme.onSurface,
            alignEnd: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFixedCostAvailability(
    BuildContext context,
    double availableAfterFixed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final availabilityColor = availableAfterFixed >= 0
        ? colorScheme.primary
        : colorScheme.error;

    return Row(
      children: [
        Icon(Icons.lock_open_outlined, size: 20, color: availabilityColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nach Fixkosten verfügbar",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                "Einnahmen minus monatliche Fixkosten",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          "${availableAfterFixed.toStringAsFixed(2)} CHF",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: availabilityColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _ExpenseBreakdownItem(
            label: "Monatlich fix",
            value: summary.fixedExpenses,
          ),
        ),
        Container(width: 1, height: 32, color: colorScheme.outlineVariant),
        Expanded(
          child: _ExpenseBreakdownItem(
            label: "Monatlich variabel",
            value: summary.variableExpenses,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool alignEnd;

  const _OverviewItem({
    required this.label,
    required this.value,
    required this.color,
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
        Text(
          "${value.toStringAsFixed(2)} CHF",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ExpenseBreakdownItem extends StatelessWidget {
  final String label;
  final double value;
  final bool alignEnd;

  const _ExpenseBreakdownItem({
    required this.label,
    required this.value,
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
        Text(
          "${value.toStringAsFixed(2)} CHF",
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
