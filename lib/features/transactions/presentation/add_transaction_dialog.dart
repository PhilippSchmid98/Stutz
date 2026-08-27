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
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';
import 'package:stutz/shared/widgets/styled_field_decoration.dart';
import 'package:stutz/features/transactions/presentation/widgets/category_picker_sheet.dart';

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
      _dateOnly(existingItem?.transaction.dateTime ?? DateTime.now()),
    );

    final selectedNodeId = useState<String?>(
      existingItem?.transaction.expenseNodeId,
    );
    final selectedNodeName = useState<String>(existingItem?.categoryName ?? '');

    final selectableCategoriesAsync = ref.watch(selectableCategoriesProvider);
    final mutationAsync = ref.watch(transactionMutationsProvider);
    final isSaving = mutationAsync.isLoading;
    final isEdit = existingItem != null;

    Future<void> pickDate() async {
      FocusScope.of(context).unfocus(); // Close keyboard

      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: now,
      );
      if (date != null && context.mounted) {
        selectedDate.value = _dateOnly(date);
      }
    }

    Future<void> pickCategory() async {
      FocusScope.of(context).unfocus();
      final selection = await showAppBottomSheet<ExpenseNode>(
        context: context,
        builder: (_) => CategoryPickerSheet(
          categories: selectableCategoriesAsync,
          selectedNodeId: selectedNodeId.value,
        ),
      );
      if (selection != null && context.mounted) {
        selectedNodeId.value = selection.id;
        selectedNodeName.value = selection.name;
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
        cancelColor: Theme.of(context).colorScheme.onSurfaceVariant,
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

    return AppBottomSheet(
      title: isEdit ? 'Ausgabe bearbeiten' : 'Neue Ausgabe',
      onClose: isSaving ? null : () => Navigator.pop(context),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            _TransactionAmountField(controller: amountCtrl, autofocus: !isEdit),
            const SizedBox(height: 24),
            _TransactionCategoryField(
              categories: selectableCategoriesAsync,
              selectedNodeId: selectedNodeId.value,
              selectedNodeName: selectedNodeName.value,
              onTap: pickCategory,
            ),
            const SizedBox(height: 16),
            _TransactionDateField(
              selectedDate: selectedDate.value,
              onTap: pickDate,
            ),
            const SizedBox(height: 16),
            _TransactionNoteField(controller: noteCtrl),
          ],
        ),
      ),
      actions: [
        Expanded(
          child: _TransactionDialogActions(
            isEdit: isEdit,
            isSaving: isSaving,
            onDelete: deleteTransaction,
            onSave: saveTransaction,
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
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            suffixText: ' CHF',
            suffixStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
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
          DateFormat('dd.MM.yyyy').format(selectedDate),
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

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
  final VoidCallback onTap;

  const _TransactionCategoryField({
    required this.categories,
    required this.selectedNodeId,
    required this.selectedNodeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return categories.when(
      loading: () => InputDecorator(
        decoration: styledFieldDecoration(
          label: "Kategorie",
          icon: Icons.category_outlined,
          variant: StyledFieldVariant.transaction,
        ),
        child: const LinearProgressIndicator(),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Kategorien konnten nicht geladen werden.'),
        ),
      ),
      data: (_) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: styledFieldDecoration(
            label: "Kategorie",
            icon: Icons.category_outlined,
            variant: StyledFieldVariant.transaction,
          ).copyWith(suffixIcon: const Icon(Icons.chevron_right)),
          child: Text(
            selectedNodeId == null ? 'Kategorie wählen' : selectedNodeName,
            style: TextStyle(
              color: selectedNodeId == null
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.onSurface,
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
