import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';
import 'package:stutz/presentation/screens/shared/styled_dropdown.dart';
import 'package:stutz/presentation/screens/shared/styled_text_field.dart';
import 'package:uuid/uuid.dart';

class AddExpenseNodeDialog extends HookConsumerWidget {
  final String? parentId;
  final ExpenseNode? existingNode;

  const AddExpenseNodeDialog({super.key, this.parentId, this.existingNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // Derive initial values from existingNode once at widget creation.
    final initialIsGroup =
        existingNode != null && existingNode!.plannedAmount == null;
    final nameCtrl = useTextEditingController(text: existingNode?.name ?? '');
    final amountCtrl = useTextEditingController(
      text: existingNode?.plannedAmount?.toString() ?? '',
    );
    final isGroup = useState(initialIsGroup);
    final interval = useState(
      existingNode?.interval ?? PaymentInterval.monthly,
    );
    final type = useState(existingNode?.type ?? ExpenseType.fixed);

    final isEdit = existingNode != null;

    String title = "Neuer Eintrag";
    if (isEdit) {
      title = isGroup.value ? "Gruppe bearbeiten" : "Eintrag bearbeiten";
    } else if (parentId == null) {
      title = "Hinzufügen";
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
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
                            isSelected: !isGroup.value,
                            onTap: () => isGroup.value = false,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _TypeSelectorButton(
                            label: "Gruppe",
                            icon: Icons.folder_open,
                            isSelected: isGroup.value,
                            onTap: () => isGroup.value = true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                StyledTextField(
                  controller: nameCtrl,
                  label: 'Bezeichnung',
                  icon: isGroup.value ? Icons.folder_outlined : Icons.tag,
                ),
                if (!isGroup.value) ...[
                  StyledTextField(
                    controller: amountCtrl,
                    label: 'Betrag',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    suffixText: 'CHF',
                  ),
                  StyledDropdown<PaymentInterval>(
                    value: interval.value,
                    items: const {
                      PaymentInterval.monthly: 'Monatlich',
                      PaymentInterval.yearly: 'Jährlich',
                    },
                    label: 'Intervall',
                    icon: Icons.calendar_today,
                    onChanged: (v) => interval.value = v!,
                  ),
                  StyledDropdown<ExpenseType>(
                    value: type.value,
                    items: const {
                      ExpenseType.fixed: 'Fix',
                      ExpenseType.variable: 'Variabel',
                    },
                    label: 'Typ',
                    icon: Icons.tune,
                    onChanged: (v) => type.value = v!,
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
              final hasChildren = existingNode!.children.isNotEmpty;
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
                    .deleteExpenseNode(existingNode!.id);
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
            if (formKey.currentState!.validate()) {
              final repo = ref.read(expenseNodeRepositoryProvider);
              final resolvedParentId = isEdit
                  ? existingNode!.parentId
                  : parentId;
              final id = isEdit ? existingNode!.id : const Uuid().v4();

              final node = ExpenseNode(
                id: id,
                parentId: resolvedParentId,
                name: nameCtrl.text,
                plannedAmount: isGroup.value
                    ? null
                    : double.parse(amountCtrl.text.replaceAll(',', '.')),
                interval: isGroup.value ? null : interval.value,
                type: isGroup.value ? null : type.value,
                children: isEdit ? existingNode!.children : [],
              );
              if (isEdit) {
                await repo.updateExpenseNode(node);
              } else {
                await repo.addExpenseNode(node);
              }
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
