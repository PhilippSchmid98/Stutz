import 'package:flutter/material.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/screens/budget/dialogs/add_expense_node_dialog.dart';
import 'package:stutz/presentation/screens/budget/widgets/expense_item_row.dart';
import 'package:stutz/presentation/screens/shared/add_button.dart';
import 'package:stutz/presentation/screens/shared/section_card.dart';

class ExpenseSectionCard extends StatelessWidget {
  final ExpenseNode rootNode;

  const ExpenseSectionCard({super.key, required this.rootNode});

  double _calcSum(List<ExpenseNode> nodes, PaymentInterval targetInterval) {
    double sum = 0;
    for (var node in nodes) {
      if (node.plannedAmount != null && node.interval == targetInterval) {
        sum += node.plannedAmount!;
      }
      if (node.children.isNotEmpty) {
        sum += _calcSum(node.children, targetInterval);
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final monthly = _calcSum(rootNode.children, PaymentInterval.monthly);
    final yearly = _calcSum(rootNode.children, PaymentInterval.yearly);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SectionCard(
        title: rootNode.name.toUpperCase(),
        totalMonthly: monthly,
        totalYearly: yearly,
        icon: Icons.folder_open,
        iconColor: Colors.teal,
        backgroundColor: Colors.white,
        onHeaderTap: () => showDialog(
          context: context,
          builder: (_) => AddExpenseNodeDialog(
            parentId: rootNode.parentId,
            existingNode: rootNode,
          ),
        ),
        children: [
          ...rootNode.children.map(
            (child) => ExpenseItemRow(node: child, depth: 0),
          ),
          const SizedBox(height: 12),
          AddButton(
            label: "Eintrag hinzufügen",
            onTap: () => showDialog(
              context: context,
              builder: (_) => AddExpenseNodeDialog(parentId: rootNode.id),
            ),
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}
