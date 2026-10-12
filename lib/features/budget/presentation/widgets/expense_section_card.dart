import 'package:flutter/material.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_expense_node_dialog.dart';
import 'package:stutz/features/budget/presentation/widgets/expense_item_row.dart';
import 'package:stutz/shared/widgets/add_button.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/section_card.dart';

class ExpenseSectionCard extends StatelessWidget {
  final ExpenseNode rootNode;
  final int monthlyTotalMinor;
  final int yearlyTotalMinor;

  const ExpenseSectionCard({
    super.key,
    required this.rootNode,
    required this.monthlyTotalMinor,
    required this.yearlyTotalMinor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SectionCard(
        title: rootNode.name,
        totalMonthlyMinor: monthlyTotalMinor,
        totalYearlyMinor: yearlyTotalMinor,
        icon: Icons.folder_open,
        iconColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        expandable: true,
        onHeaderTap: () => showAppBottomSheet(
          context: context,
          builder: (_) => AddExpenseNodeDialog(
            parentId: rootNode.parentId,
            existingNode: rootNode,
          ),
        ),
        onAdd: () => showAppBottomSheet(
          context: context,
          builder: (_) => AddExpenseNodeDialog(parentId: rootNode.id),
        ),
        children: [
          ...rootNode.children.map(
            (child) => ExpenseItemRow(node: child, depth: 0),
          ),
          const SizedBox(height: 12),
          AddButton(
            label: "Eintrag hinzufügen",
            onTap: () => showAppBottomSheet(
              context: context,
              builder: (_) => AddExpenseNodeDialog(parentId: rootNode.id),
            ),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
