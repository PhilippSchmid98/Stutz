import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/features/budget/application/budget_mutations.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/choice_group.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';
import 'package:stutz/shared/widgets/styled_text_field.dart';
import 'package:uuid/uuid.dart';

class AddIncomeDialog extends HookConsumerWidget {
  final IncomeSource? existingItem;

  const AddIncomeDialog({super.key, this.existingItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameCtrl = useTextEditingController(text: existingItem?.name ?? '');
    final amountCtrl = useTextEditingController(
      text: existingItem?.amount.toString() ?? '',
    );
    final interval = useState(
      existingItem?.interval ?? PaymentInterval.monthly,
    );
    final group = useState(existingItem?.group ?? IncomeGroup.main);
    final mutationAsync = ref.watch(budgetMutationsProvider);
    final isSaving = mutationAsync.isLoading;

    final isEdit = existingItem != null;

    return AppBottomSheet(
      title: isEdit ? 'Einnahme bearbeiten' : 'Neue Einnahme',
      onClose: isSaving ? null : () => Navigator.pop(context),
      content: Form(
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
            AppChoiceGroup<IncomeGroup>(
              value: group.value,
              items: const {
                IncomeGroup.main: 'Haupteinnahmen',
                IncomeGroup.additional: 'Zusätzliche Einnahmen',
              },
              label: 'Gruppe',
              onChanged: (value) => group.value = value,
            ),
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
                    final confirm = await showConfirmationDialog(
                      context: context,
                      title: 'Löschen?',
                      content: 'Soll diese Einnahme wirklich gelöscht werden?',
                      confirmLabel: 'Löschen',
                    );
                    if (confirm == true) {
                      try {
                        await ref
                            .read(budgetMutationsProvider.notifier)
                            .deleteIncomeSource(existingItem!.id);
                      } catch (_) {
                        if (context.mounted) {
                          showErrorSnackBar(context, 'Löschen fehlgeschlagen');
                        }
                        return;
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
          ),
        if (isEdit) const Spacer(),
        AppTextButton(
          label: 'Abbrechen',
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          onPressed: isSaving ? null : () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
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
                      final newAmount = parsePositiveAmount(amountCtrl.text);
                      if (newAmount == null) {
                        showErrorSnackBar(
                          context,
                          'Bitte einen gültigen Betrag eingeben',
                        );
                        return;
                      }

                      final mutations = ref.read(
                        budgetMutationsProvider.notifier,
                      );
                      if (isEdit) {
                        final updated = IncomeSource(
                          id: existingItem!.id,
                          name: nameCtrl.text.trim(),
                          amount: newAmount,
                          interval: interval.value,
                          group: group.value,
                        );
                        try {
                          await mutations.updateIncomeSource(updated);
                        } catch (_) {
                          if (context.mounted) {
                            showErrorSnackBar(
                              context,
                              'Speichern fehlgeschlagen',
                            );
                          }
                          return;
                        }
                      } else {
                        final src = IncomeSource(
                          id: const Uuid().v4(),
                          name: nameCtrl.text.trim(),
                          amount: newAmount,
                          interval: interval.value,
                          group: group.value,
                        );
                        try {
                          await mutations.addIncomeSource(src);
                        } catch (_) {
                          if (context.mounted) {
                            showErrorSnackBar(
                              context,
                              'Speichern fehlgeschlagen',
                            );
                          }
                          return;
                        }
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
