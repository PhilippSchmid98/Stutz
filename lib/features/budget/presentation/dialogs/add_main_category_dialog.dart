import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/features/budget/application/budget_mutations.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';
import 'package:stutz/shared/widgets/styled_text_field.dart';
import 'package:uuid/uuid.dart';

class AddMainCategoryDialog extends HookConsumerWidget {
  const AddMainCategoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameCtrl = useTextEditingController();
    final mutationAsync = ref.watch(budgetMutationsProvider);
    final isSaving = mutationAsync.isLoading;

    return AppBottomSheet(
      title: 'Neue Hauptkategorie',
      onClose: isSaving ? null : () => Navigator.pop(context),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Erstellt einen Ordner für weitere Unterkategorien.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 20),
            StyledTextField(
              controller: nameCtrl,
              label: 'Name der Kategorie',
              icon: Icons.folder_open,
            ),
          ],
        ),
      ),
      actions: [
        AppTextButton(
          label: 'Abbrechen',
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          onPressed: isSaving ? null : () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppPrimaryButton(
            label: 'Erstellen',
            width: null,
            height: 48,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onPressed: isSaving
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      final node = ExpenseNode(
                        id: const Uuid().v4(),
                        parentId: null,
                        name: nameCtrl.text.trim(),
                        plannedAmount: null,
                        interval: null,
                        type: null,
                        children: [],
                      );
                      try {
                        await ref
                            .read(budgetMutationsProvider.notifier)
                            .addExpenseNode(node);
                      } catch (_) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context,
                            'Erstellen fehlgeschlagen',
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
