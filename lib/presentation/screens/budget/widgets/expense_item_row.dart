import 'package:flutter/material.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/screens/budget/dialogs/add_expense_node_dialog.dart';

class ExpenseItemRow extends StatelessWidget {
  final ExpenseNode node;
  final int depth;

  const ExpenseItemRow({super.key, required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty;
    final isFixed = node.type == ExpenseType.fixed;

    Widget rowContent = InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) =>
            AddExpenseNodeDialog(parentId: node.parentId, existingNode: node),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              hasChildren
                  ? Icons.folder_outlined
                  : (isFixed
                        ? Icons.lock_outline
                        : Icons.shopping_bag_outlined),
              size: 18,
              color: hasChildren ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: hasChildren ? FontWeight.w600 : FontWeight.normal,
                  color: isFixed ? Colors.grey.shade600 : Colors.black87,
                ),
              ),
            ),
            if (node.plannedAmount != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    node.plannedAmount!.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isFixed ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  Text(
                    node.interval == PaymentInterval.monthly
                        ? "Monatlich"
                        : "Jährlich",
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            if (hasChildren || node.plannedAmount == null)
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: Colors.teal,
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AddExpenseNodeDialog(parentId: node.id),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );

    if (hasChildren) {
      return Column(
        children: [
          rowContent,
          ...node.children.map(
            (child) => ExpenseItemRow(node: child, depth: depth + 1),
          ),
        ],
      );
    }
    return rowContent;
  }
}
