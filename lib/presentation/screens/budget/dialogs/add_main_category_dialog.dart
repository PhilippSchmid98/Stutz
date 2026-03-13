import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';
import 'package:stutz/presentation/screens/shared/styled_text_field.dart';
import 'package:uuid/uuid.dart';

class AddMainCategoryDialog extends ConsumerStatefulWidget {
  const AddMainCategoryDialog({super.key});

  @override
  ConsumerState<AddMainCategoryDialog> createState() =>
      _AddMainCategoryDialogState();
}

class _AddMainCategoryDialogState extends ConsumerState<AddMainCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Neue Hauptkategorie',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Erstellt einen Ordner für weitere Unterkategorien.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              StyledTextField(
                controller: _nameCtrl,
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
            if (_formKey.currentState!.validate()) {
              final node = ExpenseNode(
                id: const Uuid().v4(),
                parentId: null,
                name: _nameCtrl.text,
                plannedAmount: null,
                interval: null,
                type: null,
                children: [],
              );
              await ref
                  .read(expenseNodeRepositoryProvider)
                  .addExpenseNode(node);
              ref.invalidate(expenseTreeProvider);
              ref.invalidate(totalMonthlyExpensesProvider);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Erstellen'),
        ),
      ],
    );
  }
}
