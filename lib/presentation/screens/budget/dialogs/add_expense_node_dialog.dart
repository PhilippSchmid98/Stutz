import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';
import 'package:stutz/presentation/screens/shared/styled_dropdown.dart';
import 'package:stutz/presentation/screens/shared/styled_text_field.dart';
import 'package:uuid/uuid.dart';

class AddExpenseNodeDialog extends ConsumerStatefulWidget {
  final String? parentId;
  final ExpenseNode? existingNode;

  const AddExpenseNodeDialog({super.key, this.parentId, this.existingNode});

  @override
  ConsumerState<AddExpenseNodeDialog> createState() =>
      _AddExpenseNodeDialogState();
}

class _AddExpenseNodeDialogState extends ConsumerState<AddExpenseNodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;

  bool _isGroup = false;
  PaymentInterval _interval = PaymentInterval.monthly;
  ExpenseType _type = ExpenseType.fixed;

  @override
  void initState() {
    super.initState();
    if (widget.existingNode != null) {
      final node = widget.existingNode!;
      _nameCtrl = TextEditingController(text: node.name);
      if (node.plannedAmount == null) {
        _isGroup = true;
        _amountCtrl = TextEditingController();
      } else {
        _isGroup = false;
        _amountCtrl = TextEditingController(
          text: node.plannedAmount.toString(),
        );
        if (node.interval != null) _interval = node.interval!;
        if (node.type != null) _type = node.type!;
      }
    } else {
      _nameCtrl = TextEditingController();
      _amountCtrl = TextEditingController();
      _isGroup = false;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingNode != null;

    String title = "Neuer Eintrag";
    if (isEdit) {
      title = _isGroup ? "Gruppe bearbeiten" : "Eintrag bearbeiten";
    } else if (widget.parentId == null) {
      title = "Hinzufügen";
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit) ...[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TypeSelectorButton(
                            label: "Eintrag",
                            icon: Icons.receipt_long,
                            isSelected: !_isGroup,
                            onTap: () => setState(() => _isGroup = false),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _TypeSelectorButton(
                            label: "Gruppe",
                            icon: Icons.folder_open,
                            isSelected: _isGroup,
                            onTap: () => setState(() => _isGroup = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                StyledTextField(
                  controller: _nameCtrl,
                  label: 'Bezeichnung',
                  icon: _isGroup ? Icons.folder_outlined : Icons.tag,
                ),
                if (!_isGroup) ...[
                  StyledTextField(
                    controller: _amountCtrl,
                    label: 'Betrag',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    suffixText: 'CHF',
                  ),
                  StyledDropdown<PaymentInterval>(
                    value: _interval,
                    items: const {
                      PaymentInterval.monthly: 'Monatlich',
                      PaymentInterval.yearly: 'Jährlich',
                    },
                    label: 'Intervall',
                    icon: Icons.calendar_today,
                    onChanged: (v) => setState(() => _interval = v!),
                  ),
                  StyledDropdown<ExpenseType>(
                    value: _type,
                    items: const {
                      ExpenseType.fixed: 'Fix',
                      ExpenseType.variable: 'Variabel',
                    },
                    label: 'Typ',
                    icon: Icons.tune,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Eine Gruppe enthält Unterkategorien. Sie hat keinen eigenen Betrag.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        if (isEdit)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final hasChildren = widget.existingNode!.children.isNotEmpty;
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Löschen?"),
                  content: Text(
                    hasChildren
                        ? "ACHTUNG: Gruppe mit Inhalt löschen?"
                        : "Löschen?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Abbrechen"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        "Löschen",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(expenseNodeRepositoryProvider)
                    .deleteExpenseNode(widget.existingNode!.id);
                ref.invalidate(expenseTreeProvider);
                ref.invalidate(totalMonthlyExpensesProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Löschen'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Abbrechen',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final repo = ref.read(expenseNodeRepositoryProvider);
              final parentId = isEdit
                  ? widget.existingNode!.parentId
                  : widget.parentId;
              final id = isEdit ? widget.existingNode!.id : const Uuid().v4();

              final node = ExpenseNode(
                id: id,
                parentId: parentId,
                name: _nameCtrl.text,
                plannedAmount: _isGroup
                    ? null
                    : double.parse(_amountCtrl.text.replaceAll(',', '.')),
                interval: _isGroup ? null : _interval,
                type: _isGroup ? null : _type,
                children: isEdit ? widget.existingNode!.children : [],
              );
              if (isEdit) {
                await repo.updateExpenseNode(node);
              } else {
                await repo.addExpenseNode(node);
              }
              ref.invalidate(expenseTreeProvider);
              ref.invalidate(totalMonthlyExpensesProvider);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

class _TypeSelectorButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelectorButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.teal : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
