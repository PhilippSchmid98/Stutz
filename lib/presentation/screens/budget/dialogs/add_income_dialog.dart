import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';
import 'package:stutz/presentation/screens/shared/styled_dropdown.dart';
import 'package:stutz/presentation/screens/shared/styled_text_field.dart';
import 'package:uuid/uuid.dart';

class AddIncomeDialog extends ConsumerStatefulWidget {
  final IncomeSource? existingItem;

  const AddIncomeDialog({super.key, this.existingItem});

  @override
  ConsumerState<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends ConsumerState<AddIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  PaymentInterval _interval = PaymentInterval.monthly;
  IncomeGroup _group = IncomeGroup.main;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _nameCtrl = TextEditingController(text: widget.existingItem!.name);
      _amountCtrl = TextEditingController(
        text: widget.existingItem!.amount.toString(),
      );
      _interval = widget.existingItem!.interval;
      _group = widget.existingItem!.group;
    } else {
      _nameCtrl = TextEditingController();
      _amountCtrl = TextEditingController();
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
    final isEdit = widget.existingItem != null;

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
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StyledTextField(
                  controller: _nameCtrl,
                  label: 'Bezeichnung',
                  icon: Icons.description_outlined,
                ),
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
                StyledDropdown<IncomeGroup>(
                  value: _group,
                  items: const {
                    IncomeGroup.main: 'Haupteinnahmen',
                    IncomeGroup.additional: 'Zusätzliche Einnahmen',
                  },
                  label: 'Gruppe',
                  icon: Icons.category_outlined,
                  onChanged: (v) => setState(() => _group = v!),
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
                    .deleteIncomeSource(widget.existingItem!.id);
                ref.invalidate(incomeListProvider);
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
            if (_formKey.currentState!.validate()) {
              final newAmount = double.parse(
                _amountCtrl.text.replaceAll(',', '.'),
              );
              final repo = ref.read(incomeSourceRepositoryProvider);
              if (isEdit) {
                final updated = IncomeSource(
                  id: widget.existingItem!.id,
                  name: _nameCtrl.text,
                  amount: newAmount,
                  interval: _interval,
                  group: _group,
                );
                repo.updateIncomeSource(updated);
              } else {
                final src = IncomeSource(
                  id: const Uuid().v4(),
                  name: _nameCtrl.text,
                  amount: newAmount,
                  interval: _interval,
                  group: _group,
                );
                repo.addIncomeSource(src);
              }
              ref.invalidate(incomeListProvider);
              Navigator.pop(context);
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
