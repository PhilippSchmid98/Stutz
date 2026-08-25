import 'package:flutter/material.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_expense_node_dialog.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';

class ExpenseItemRow extends StatefulWidget {
  final ExpenseNode node;
  final int depth;

  const ExpenseItemRow({super.key, required this.node, required this.depth});

  @override
  State<ExpenseItemRow> createState() => _ExpenseItemRowState();
}

class _ExpenseItemRowState extends State<ExpenseItemRow> {
  static const _indentPerLevel = 16.0;

  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final hasChildren = node.children.isNotEmpty;
    final isGroup = node.plannedAmount == null;
    final isFixed = node.type == ExpenseType.fixed;
    final colorScheme = Theme.of(context).colorScheme;

    final rowContent = Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => showAppBottomSheet(
              context: context,
              builder: (_) => AddExpenseNodeDialog(
                parentId: node.parentId,
                existingNode: node,
              ),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: EdgeInsets.only(
                left: _indentPerLevel * widget.depth,
                top: 6,
                bottom: 6,
              ),
              child: Row(
                children: [
                  if (hasChildren)
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    )
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 4),
                  Icon(
                    isGroup ? Icons.folder_outlined : Icons.sell_outlined,
                    size: 18,
                    color: hasChildren
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: hasChildren
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isFixed
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (node.plannedAmount != null) _buildAmount(context),
                ],
              ),
            ),
          ),
        ),
        if (hasChildren)
          IconButton(
            tooltip: _isExpanded ? 'Gruppe einklappen' : 'Gruppe ausklappen',
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(
              _isExpanded ? Icons.unfold_less : Icons.unfold_more,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        if (hasChildren || node.plannedAmount == null)
          IconButton(
            tooltip: 'Eintrag hinzufügen',
            icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
            onPressed: () => showAppBottomSheet(
              context: context,
              builder: (_) => AddExpenseNodeDialog(parentId: node.id),
            ),
          ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: hasChildren ? 4 : 2),
      child: Column(
        children: [
          rowContent,
          if (hasChildren && _isExpanded)
            ...node.children.map(
              (child) => ExpenseItemRow(node: child, depth: widget.depth + 1),
            ),
        ],
      ),
    );
  }

  Widget _buildAmount(BuildContext context) {
    final node = widget.node;
    final isFixed = node.type == ExpenseType.fixed;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${node.plannedAmount!.toStringAsFixed(2)} CHF",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isFixed
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MetadataLabel(
              label: node.interval == PaymentInterval.monthly
                  ? 'Monatlich'
                  : 'Jährlich',
            ),
            const SizedBox(width: 4),
            _MetadataLabel(label: isFixed ? 'Fix' : 'Variabel'),
          ],
        ),
      ],
    );
  }
}

class _MetadataLabel extends StatelessWidget {
  final String label;

  const _MetadataLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
