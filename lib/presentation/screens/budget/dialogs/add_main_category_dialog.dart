import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';
import 'package:stutz/presentation/screens/shared/styled_text_field.dart';
import 'package:uuid/uuid.dart';

class AddMainCategoryDialog extends HookConsumerWidget {
  const AddMainCategoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameCtrl = useTextEditingController();

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
              final node = ExpenseNode(
                id: const Uuid().v4(),
                parentId: null,
                name: nameCtrl.text,
                plannedAmount: null,
                interval: null,
                type: null,
                children: [],
              );
              await ref
                  .read(expenseNodeRepositoryProvider)
                  .addExpenseNode(node);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Erstellen'),
        ),
      ],
    );
  }
}
