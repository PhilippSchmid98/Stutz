import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/features/budget/application/budget_mutations.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';
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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Neue Hauptkategorie',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Erstellt einen Ordner für weitere Unterkategorien.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
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
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        AppTextButton(
          label: 'Abbrechen',
          foregroundColor: Colors.grey.shade600,
          onPressed: isSaving ? null : () => Navigator.pop(context),
        ),
        AppPrimaryButton(
          label: 'Erstellen',
          width: null,
          height: null,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                        showErrorSnackBar(context, 'Erstellen fehlgeschlagen');
                      }
                      return;
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                },
        ),
      ],
    );
  }
}
