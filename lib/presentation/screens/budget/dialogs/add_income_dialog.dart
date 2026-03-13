import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';
import 'package:stutz/presentation/screens/shared/styled_dropdown.dart';
import 'package:stutz/presentation/screens/shared/styled_text_field.dart';
import 'package:uuid/uuid.dart';

class AddIncomeDialog extends HookConsumerWidget {
  final IncomeSource? existingItem;

  const AddIncomeDialog({super.key, this.existingItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameCtrl = useTextEditingController(
      text: existingItem?.name ?? '',
    );
    final amountCtrl = useTextEditingController(
      text: existingItem?.amount.toString() ?? '',
    );
    final interval = useState(existingItem?.interval ?? PaymentInterval.monthly);
    final group = useState(existingItem?.group ?? IncomeGroup.main);

    final isEdit = existingItem != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEdit ? 'Einnahme bearbeiten' : 'Neue Einnahme',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StyledTextField(
                  controller: nameCtrl,
                  label: 'Bezeichnung',
                  icon: Icons.description_outlined,
                ),
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
                StyledDropdown<IncomeGroup>(
                  value: group.value,
                  items: const {
                    IncomeGroup.main: 'Haupteinnahmen',
                    IncomeGroup.additional: 'Zusätzliche Einnahmen',
                  },
                  label: 'Gruppe',
                  icon: Icons.category_outlined,
                  onChanged: (v) => group.value = v!,
                ),
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
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Löschen?"),
                  content: const Text(
                    "Soll diese Einnahme wirklich gelöscht werden?",
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
                    .read(incomeSourceRepositoryProvider)
                    .deleteIncomeSource(existingItem!.id);
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
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final newAmount = double.parse(
                amountCtrl.text.replaceAll(',', '.'),
              );
              final repo = ref.read(incomeSourceRepositoryProvider);
              if (isEdit) {
                final updated = IncomeSource(
                  id: existingItem!.id,
                  name: nameCtrl.text,
                  amount: newAmount,
                  interval: interval.value,
                  group: group.value,
                );
                repo.updateIncomeSource(updated);
              } else {
                final src = IncomeSource(
                  id: const Uuid().v4(),
                  name: nameCtrl.text,
                  amount: newAmount,
                  interval: interval.value,
                  group: group.value,
                );
                repo.addIncomeSource(src);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
