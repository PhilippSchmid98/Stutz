import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/presentation/screens/budget/new/widgets/expandable_expense_group.dart';

class BudgetPlanningScreenNew extends ConsumerWidget {
  const BudgetPlanningScreenNew({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final incomeAsync = ref.watch(incomeListProvider);
    final expenseRootsAsync = ref.watch(expenseTreeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          children: [
            _buildSectionHeader(
              context: context,
              title: 'Monatlicher\nCashflow',
              subtitle: 'EINKOMMEN',
              hasAddButton: true,
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 32),
            _buildSectionHeader(
              context: context,
              title: 'Kostenstruktur',
              subtitle: 'AUSGABEN',
              hasAddButton: true,
            ),
            const SizedBox(height: 32),

            ExpandableExpenseGroup(
              title: 'Test',
              itemCount: 3,
              totalAmount: 30,
            ),
          ],
        ),
      ),
    );
  }

  // Hilfs-Methode für die konsistenten Sektions-Header
  Widget _buildSectionHeader({
    required BuildContext context,
    required String subtitle,
    required String title,
    bool hasAddButton = false,
    Widget? trailingWidget,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle (z.B. EINKOMMEN) in Uppercase mit 1px Spacing
        Text(
          subtitle.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.0,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Headline in Manrope Bold
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  height: 1.1, // Etwas kompakterer Zeilenabstand
                ),
              ),
            ),
            if (trailingWidget != null) ...[
              trailingWidget,
              const SizedBox(width: 12),
            ],
            if (hasAddButton)
              Container(
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme
                      .surfaceContainerLow, // Leichter Hintergrund
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.add, color: theme.colorScheme.primary),
              ),
          ],
        ),
      ],
    );
  }
}
