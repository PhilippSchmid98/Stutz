import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/features/budget/application/budget_mutations.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/choice_group.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';
import 'package:stutz/shared/widgets/styled_text_field.dart';
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
    final mutationAsync = ref.watch(budgetMutationsProvider);
    final isSaving = mutationAsync.isLoading;

    final isEdit = existingNode != null;

    String title = "Neuer Eintrag";
    if (isEdit) {
      title = isGroup.value ? "Gruppe bearbeiten" : "Eintrag bearbeiten";
    } else if (parentId == null) {
      title = "Hinzufügen";
    }

    final colorScheme = Theme.of(context).colorScheme;

    return AppBottomSheet(
      title: title,
      onClose: isSaving ? null : () => Navigator.pop(context),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEdit) ...[
              AppChoiceGroup<bool>(
                value: isGroup.value,
                items: const {false: 'Eintrag', true: 'Gruppe'},
                label: 'Art',
                onChanged: (value) => isGroup.value = value,
              ),
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
                validator: positiveAmountValidator,
              ),
              AppChoiceGroup<PaymentInterval>(
                value: interval.value,
                items: const {
                  PaymentInterval.monthly: 'Monatlich',
                  PaymentInterval.yearly: 'Jährlich',
                },
                label: 'Intervall',
                onChanged: (value) => interval.value = value,
              ),
              AppChoiceGroup<ExpenseType>(
                value: type.value,
                items: const {
                  ExpenseType.fixed: 'Fix',
                  ExpenseType.variable: 'Variabel',
                },
                label: 'Typ',
                onChanged: (value) => type.value = value,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Eine Gruppe enthält Unterkategorien. Sie hat keinen eigenen Betrag.",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (isEdit)
          AppDestructiveButton(
            label: 'Löschen',
            onPressed: isSaving
                ? null
                : () async {
                    final hasChildren = existingNode!.children.isNotEmpty;
                    final confirm = await showConfirmationDialog(
                      context: context,
                      title: 'Löschen?',
                      content: hasChildren
                          ? 'ACHTUNG: Gruppe mit Inhalt löschen?'
                          : 'Löschen?',
                      confirmLabel: 'Löschen',
                    );
                    if (confirm == true) {
                      try {
                        await ref
                            .read(budgetMutationsProvider.notifier)
                            .deleteExpenseNode(existingNode!.id);
                      } catch (_) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Kategorie kann nicht gelöscht werden. Entferne zuerst Unterkategorien oder zugehörige Transaktionen.',
                          );
                        }
                        return;
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
          ),
        if (isEdit) const Spacer(),
        if (!isEdit) ...[
          AppTextButton(
            label: 'Abbrechen',
            foregroundColor: colorScheme.onSurfaceVariant,
            onPressed: isSaving ? null : () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: AppPrimaryButton(
            label: 'Speichern',
            width: null,
            height: 48,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onPressed: isSaving
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      final resolvedParentId = isEdit
                          ? existingNode!.parentId
                          : parentId;
                      final id = isEdit ? existingNode!.id : const Uuid().v4();
                      final amount = isGroup.value
                          ? null
                          : parsePositiveAmount(amountCtrl.text);

                      if (!isGroup.value && amount == null) {
                        return;
                      }

                      final node = ExpenseNode(
                        id: id,
                        parentId: resolvedParentId,
                        name: nameCtrl.text.trim(),
                        plannedAmount: amount,
                        interval: isGroup.value ? null : interval.value,
                        type: isGroup.value ? null : type.value,
                        children: isEdit ? existingNode!.children : [],
                      );
                      try {
                        final mutations = ref.read(
                          budgetMutationsProvider.notifier,
                        );
                        if (isEdit) {
                          await mutations.updateExpenseNode(node);
                        } else {
                          await mutations.addExpenseNode(node);
                        }
                      } catch (_) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Speichern fehlgeschlagen',
                          );
                        }
                        return;
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
          ),
        ),
      ],
    );
  }
}
