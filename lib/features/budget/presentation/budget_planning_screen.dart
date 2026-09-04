import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/services/budget_calculator.dart';
import 'package:stutz/features/budget/domain/view_models/budget_summary.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_main_category_dialog.dart';
import 'package:stutz/features/budget/presentation/widgets/budget_overview_card.dart';
import 'package:stutz/features/budget/presentation/widgets/expense_section_card.dart';
import 'package:stutz/features/budget/presentation/widgets/income_section_card.dart';
import 'package:stutz/features/notification_import/presentation/pending_transaction_drafts_indicator.dart';
import 'package:stutz/shared/widgets/async_state_view.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/cloud_status_icon.dart';

class BudgetPlanningScreen extends ConsumerWidget {
  const BudgetPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(incomeListProvider);
    final expenseRootsAsync = ref.watch(expenseTreeProvider);
    final summaryAsync = ref.watch(budgetSummaryProvider);

    return Scaffold(
      appBar: _buildAppBar(ref),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            _buildSummarySection(summaryAsync),

            const SizedBox(height: 24),

            _buildIncomeSection(incomeAsync),

            const SizedBox(height: 28),

            _buildSectionHeading(context),
            const SizedBox(height: 12),

            _buildExpenseSection(expenseRootsAsync, context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(WidgetRef ref) {
    return AppBar(
      title: const Text('Budget Planung'),
      actions: [
        const PendingTransactionDraftsIndicator(),
        const CloudStatusIcon(),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).signOut();
          },
        ),
      ],
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(ref.context).colorScheme.onSurface,
      elevation: 0,
    );
  }

  Widget _buildIncomeSection(AsyncValue<List<IncomeSource>> state) {
    return AsyncStateView(
      state: state,
      errorMessage: 'Einnahmen konnten nicht geladen werden.',
      builder: (incomes) {
        final totals = const BudgetCalculator().incomeIntervalTotals(incomes);
        return IncomeSectionCard(
          incomes: incomes,
          monthlyTotal: totals.monthly,
          yearlyTotal: totals.yearly,
        );
      },
    );
  }

  Widget _buildSectionHeading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'Geplante Ausgaben',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          'Nach Kategorie',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildExpenseSection(
    AsyncValue<List<ExpenseNode>> state,
    BuildContext context,
  ) {
    return AsyncStateView(
      state: state,
      errorMessage: 'Ausgaben konnten nicht geladen werden.',
      builder: (roots) => Column(
        children: [
          ...roots.map(_buildExpenseCard),
          _buildAddMainCategoryButton(context),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseNode rootNode) {
    final totals = const BudgetCalculator().expenseIntervalTotals(
      rootNode.children,
    );
    return ExpenseSectionCard(
      rootNode: rootNode,
      monthlyTotal: totals.monthly,
      yearlyTotal: totals.yearly,
    );
  }

  Widget _buildAddMainCategoryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text("Hauptkategorie hinzufügen"),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => showAppBottomSheet(
            context: context,
            builder: (_) => const AddMainCategoryDialog(),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(AsyncValue<BudgetSummary> state) {
    return AsyncStateView(
      state: state,
      errorMessage: 'Die Budgetübersicht konnte nicht geladen werden.',
      builder: (summary) => BudgetOverviewCard(summary: summary),
    );
  }
}
