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
import 'package:stutz/features/budget/presentation/widgets/legend_row.dart';
import 'package:stutz/shared/widgets/async_state_view.dart';
import 'package:stutz/shared/widgets/cloud_status_icon.dart';

class BudgetPlanningScreen extends ConsumerWidget {
  const BudgetPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(incomeListProvider);
    final expenseRootsAsync = ref.watch(expenseTreeProvider);
    final summaryAsync = ref.watch(budgetSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(ref),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            _buildIncomeSection(incomeAsync),

            const SizedBox(height: 32),

            _buildExpenseDivider(),
            const SizedBox(height: 16),

            _buildExpenseSection(expenseRootsAsync, context),

            const SizedBox(height: 24),

            _buildSummarySection(summaryAsync),

            const LegendRow(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(WidgetRef ref) {
    return AppBar(
      title: const Text('Budget Planung'),
      actions: [
        const CloudStatusIcon(),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).signOut();
          },
        ),
      ],
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
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

  Widget _buildExpenseDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "AUSGABEN",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
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
        height: 50,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text("Neue Hauptkategorie erstellen"),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade400),
            foregroundColor: Colors.grey.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => showDialog(
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
