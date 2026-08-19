import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/features/budget/application/selectable_categories_provider.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:uuid/uuid.dart';

import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/view_models/transaction_with_category.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';
import 'package:stutz/shared/widgets/styled_field_decoration.dart';

class AddTransactionDialog extends HookConsumerWidget {
  final TransactionWithCategory? existingItem;

  const AddTransactionDialog({super.key, this.existingItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final amountCtrl = useTextEditingController(
      text: existingItem?.transaction.amount.toString() ?? '',
    );
    final noteCtrl = useTextEditingController(
      text: existingItem?.transaction.note ?? '',
    );
    final selectedDate = useState<DateTime>(
      existingItem?.transaction.dateTime ?? DateTime.now(),
    );

    final selectedNodeId = useState<String?>(
      existingItem?.transaction.expenseNodeId,
    );
    final selectedNodeName = useState<String>(existingItem?.categoryName ?? '');

    final selectableCategoriesAsync = ref.watch(selectableCategoriesProvider);
    final mutationAsync = ref.watch(transactionMutationsProvider);
    final isSaving = mutationAsync.isLoading;
    final isEdit = existingItem != null;

    Future<void> pickDateTime() async {
      FocusScope.of(context).unfocus(); // Close keyboard

      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: now,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.black),
            ),
            child: child!,
          );
        },
      );
      if (date != null && context.mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDate.value),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(primary: Colors.black),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          selectedDate.value = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        }
      }
    }

    Future<void> saveTransaction() async {
      if (formKey.currentState!.validate()) {
        if (selectedNodeId.value == null) {
          showErrorSnackBar(context, "Bitte Kategorie wählen");
          return;
        }

        final amount = parsePositiveAmount(amountCtrl.text);
        if (amount == null) {
          showErrorSnackBar(context, "Bitte einen gültigen Betrag eingeben");
          return;
        }

        final id = isEdit ? existingItem!.transaction.id : const Uuid().v4();

        final txn = AppTransaction(
          id: id,
          expenseNodeId: selectedNodeId.value!,
          amount: amount,
          dateTime: selectedDate.value,
          note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
        );

        final mutations = ref.read(transactionMutationsProvider.notifier);
        try {
          if (isEdit) {
            await mutations.updateTransaction(txn);
          } else {
            await mutations.addTransaction(txn);
          }
        } catch (_) {
          if (context.mounted) {
            showErrorSnackBar(context, "Speichern fehlgeschlagen");
          }
          return;
        }
        if (context.mounted) Navigator.pop(context);
      }
    }

    Future<void> deleteTransaction() async {
      final confirm = await showConfirmationDialog(
        context: context,
        title: "Löschen",
        content: "Wirklich löschen?",
        cancelColor: Colors.grey,
        confirmLabel: "Löschen",
      );

      if (confirm == true && existingItem != null) {
        try {
          await ref
              .read(transactionMutationsProvider.notifier)
              .deleteTransaction(existingItem!.transaction.id);
        } catch (_) {
          if (context.mounted) {
            showErrorSnackBar(context, "Löschen fehlgeschlagen");
          }
          return;
        }
        if (context.mounted) Navigator.pop(context);
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TransactionDialogHeader(
              isEdit: isEdit,
              isSaving: isSaving,
              onClose: () => Navigator.pop(context),
            ),

            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _TransactionAmountField(
                        controller: amountCtrl,
                        autofocus: !isEdit,
                      ),
                      const SizedBox(height: 24),

                      _TransactionCategoryField(
                        categories: selectableCategoriesAsync,
                        selectedNodeId: selectedNodeId.value,
                        selectedNodeName: selectedNodeName.value,
                        onSelected: (selection) {
                          selectedNodeId.value = selection.id;
                          selectedNodeName.value = selection.name;
                        },
                        onTextChanged: (text) {
                          if (selectedNodeId.value != null) {
                            selectedNodeId.value = null;
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      _TransactionDateField(
                        selectedDate: selectedDate.value,
                        onTap: pickDateTime,
                      ),
                      const SizedBox(height: 16),

                      _TransactionNoteField(controller: noteCtrl),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _TransactionDialogActions(
              isEdit: isEdit,
              isSaving: isSaving,
              onDelete: deleteTransaction,
              onSave: saveTransaction,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionDialogHeader extends StatelessWidget {
  final bool isEdit;
  final bool isSaving;
  final VoidCallback onClose;

  const _TransactionDialogHeader({
    required this.isEdit,
    required this.isSaving,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEdit ? "Bearbeiten" : "Neue Ausgabe",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: isSaving ? null : onClose,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }
}

class _TransactionAmountField extends StatelessWidget {
  final TextEditingController controller;
  final bool autofocus;

  const _TransactionAmountField({
    required this.controller,
    required this.autofocus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: IntrinsicWidth(
        child: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          autofocus: autofocus,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            hintText: '0.00',
            suffixText: ' CHF',
            suffixStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black12),
            contentPadding: EdgeInsets.zero,
          ),
          validator: (value) => value == null || value.isEmpty ? '' : null,
        ),
      ),
    );
  }
}

class _TransactionDateField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const _TransactionDateField({
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: styledFieldDecoration(
          label: "Datum",
          icon: Icons.calendar_today_outlined,
          variant: StyledFieldVariant.transaction,
        ),
        child: Text(
          DateFormat('dd.MM.yyyy, HH:mm').format(selectedDate),
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}

class _TransactionNoteField extends StatelessWidget {
  final TextEditingController controller;

  const _TransactionNoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: styledFieldDecoration(
        label: "Notiz",
        icon: Icons.notes_rounded,
        variant: StyledFieldVariant.transaction,
      ),
      maxLines: 1,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

class _TransactionCategoryField extends StatelessWidget {
  final AsyncValue<List<ExpenseNode>> categories;
  final String? selectedNodeId;
  final String selectedNodeName;
  final ValueChanged<ExpenseNode> onSelected;
  final ValueChanged<String> onTextChanged;

  const _TransactionCategoryField({
    required this.categories,
    required this.selectedNodeId,
    required this.selectedNodeName,
    required this.onSelected,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return categories.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Kategorien konnten nicht geladen werden.'),
        ),
      ),
      data: (allNodes) => LayoutBuilder(
        builder: (context, constraints) => RawAutocomplete<ExpenseNode>(
          initialValue: selectedNodeId != null
              ? TextEditingValue(text: selectedNodeName)
              : null,
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) return allNodes;
            return allNodes.where(
              (option) => option.name.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },
          onSelected: (selection) {
            onSelected(selection);
            FocusScope.of(context).unfocus();
          },
          displayStringForOption: (option) => option.name,
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
                if (selectedNodeId != null && textController.text.isEmpty) {
                  textController.text = selectedNodeName;
                }

                return TextFormField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration:
                      styledFieldDecoration(
                        label: "Kategorie (Suchen...)",
                        icon: Icons.category_outlined,
                        variant: StyledFieldVariant.transaction,
                      ).copyWith(
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey,
                        ),
                      ),
                  validator: (value) =>
                      selectedNodeId == null ? 'Bitte Kategorie wählen' : null,
                  onChanged: onTextChanged,
                );
              },
          optionsViewBuilder: (context, onOptionSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 200,
                  maxWidth: constraints.maxWidth,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onOptionSelected(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          option.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionDialogActions extends StatelessWidget {
  final bool isEdit;
  final bool isSaving;
  final VoidCallback onDelete;
  final VoidCallback onSave;

  const _TransactionDialogActions({
    required this.isEdit,
    required this.isSaving,
    required this.onDelete,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isEdit) ...[
          Expanded(
            child: AppDestructiveButton(
              label: "Löschen",
              filled: true,
              onPressed: isSaving ? null : onDelete,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: AppPrimaryButton(
            label: "Speichern",
            width: null,
            height: null,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            onPressed: isSaving ? null : onSave,
          ),
        ),
      ],
    );
  }
}
