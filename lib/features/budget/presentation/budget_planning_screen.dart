import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_main_category_dialog.dart';
import 'package:stutz/features/budget/presentation/widgets/budget_overview_card.dart';
import 'package:stutz/features/budget/presentation/widgets/expense_section_card.dart';
import 'package:stutz/features/budget/presentation/widgets/income_section_card.dart';
import 'package:stutz/features/budget/presentation/widgets/legend_row.dart';
import 'package:stutz/shared/widgets/cloud_status_icon.dart';

class BudgetPlanningScreen extends ConsumerWidget {
  const BudgetPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(incomeListProvider);
    final expenseRootsAsync = ref.watch(expenseTreeProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Budget Planung'),
        actions: [
          const CloudStatusIcon(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              // AppRouter reacts to authStateProvider and navigates automatically.
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            // Income section
            incomeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Fehler: $e'),
              data: (incomes) => IncomeSectionCard(incomes: incomes),
            ),

            const SizedBox(height: 32),

            // Separator
            Row(
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
            ),
            const SizedBox(height: 16),

            // Expense sections
            expenseRootsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Fehler: $e'),
              data: (roots) => Column(
                children: [
                  ...roots.map(
                    (rootNode) => ExpenseSectionCard(rootNode: rootNode),
                  ),
                  Padding(
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Budget overview card
            if (incomeAsync.hasValue && expenseRootsAsync.hasValue)
              BudgetOverviewCard(
                incomes: incomeAsync.value!,
                roots: expenseRootsAsync.value!,
              ),

            const LegendRow(),
          ],
        ),
      ),
    );
  }
}
