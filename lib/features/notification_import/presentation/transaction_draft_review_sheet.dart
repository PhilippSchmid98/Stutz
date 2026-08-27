import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/application/selectable_categories_provider.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/notification_import/application/transaction_draft_providers.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft_confirmation.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';
import 'package:stutz/features/transactions/presentation/widgets/category_picker_sheet.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';
import 'package:stutz/shared/widgets/styled_field_decoration.dart';

Future<void> showTransactionDraftReview(
  BuildContext context,
  TransactionDraft draft,
) {
  return showAppBottomSheet(
    context: context,
    builder: (_) => TransactionDraftReviewSheet(draft: draft),
  );
}

class TransactionDraftReviewSheet extends HookConsumerWidget {
  final TransactionDraft draft;

  const TransactionDraftReviewSheet({super.key, required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final amountController = useTextEditingController(
      text: draft.amount.toStringAsFixed(2),
    );
    final noteController = useTextEditingController(text: draft.merchant);
    final selectedDate = useState(_dateOnly(draft.occurredAt));
    final selectedCategoryId = useState<String?>(draft.suggestedExpenseNodeId);
    final categoriesAsync = ref.watch(selectableCategoriesProvider);
    final suggestionAsync = ref.watch(
      merchantCategorySuggestionProvider(draft.normalizedMerchant),
    );
    final mutationAsync = ref.watch(transactionDraftMutationsProvider);
    final isSaving = mutationAsync.isLoading;
    final suggestedCategoryId = suggestionAsync.asData?.value;
    final categories = categoriesAsync.asData?.value;

    useEffect(() {
      if (selectedCategoryId.value != null) return null;
      if (suggestedCategoryId == null || categories == null) return null;
      if (categories.any((category) => category.id == suggestedCategoryId)) {
        selectedCategoryId.value = suggestedCategoryId;
      }
      return null;
    }, [suggestedCategoryId, categories]);

    Future<void> pickCategory() async {
      FocusScope.of(context).unfocus();
      final category = await showAppBottomSheet<ExpenseNode>(
        context: context,
        builder: (_) => CategoryPickerSheet(
          categories: categoriesAsync,
          selectedNodeId: selectedCategoryId.value,
        ),
      );
      if (category != null && context.mounted) {
        selectedCategoryId.value = category.id;
      }
    }

    Future<void> pickDate() async {
      FocusScope.of(context).unfocus();
      final date = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (date != null && context.mounted) selectedDate.value = _dateOnly(date);
    }

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      final categoryId = selectedCategoryId.value;
      if (categoryId == null) {
        showErrorSnackBar(context, 'Bitte Kategorie wählen');
        return;
      }
      final amount = parsePositiveAmount(amountController.text);
      if (amount == null) {
        showErrorSnackBar(context, 'Bitte einen gültigen Betrag eingeben');
        return;
      }

      try {
        await ref
            .read(transactionDraftMutationsProvider.notifier)
            .confirm(
              draft.id,
              TransactionDraftConfirmation(
                amountMinor: (amount * 100).round(),
                dateTime: selectedDate.value,
                expenseNodeId: categoryId,
                note: noteController.text,
              ),
            );
      } catch (_) {
        if (context.mounted)
          showErrorSnackBar(context, 'Speichern fehlgeschlagen');
        return;
      }
      if (context.mounted) Navigator.pop(context);
    }

    Future<void> discard() async {
      final confirmed = await showConfirmationDialog(
        context: context,
        title: 'Entwurf verwerfen',
        content: 'Diese Ausgabe wird nicht gespeichert.',
        confirmLabel: 'Verwerfen',
      );
      if (confirmed != true) return;

      try {
        await ref
            .read(transactionDraftMutationsProvider.notifier)
            .discard(draft.id);
      } catch (_) {
        if (context.mounted)
          showErrorSnackBar(context, 'Verwerfen fehlgeschlagen');
        return;
      }
      if (context.mounted) Navigator.pop(context);
    }

    final selectedCategoryName = _categoryName(
      categories,
      selectedCategoryId.value,
    );

    return AppBottomSheet(
      title: 'Erfasste Ausgabe prüfen',
      onClose: isSaving ? null : () => Navigator.pop(context),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            Text(
              draft.merchant,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd.MM.yyyy, HH:mm').format(draft.occurredAt),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              decoration: const InputDecoration(
                hintText: '0.00',
                suffixText: ' CHF',
                border: InputBorder.none,
              ),
              validator: (value) => value == null || value.isEmpty ? '' : null,
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: isSaving ? null : pickCategory,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: styledFieldDecoration(
                  label: 'Kategorie',
                  icon: Icons.category_outlined,
                  variant: StyledFieldVariant.transaction,
                ),
                child: Text(selectedCategoryName ?? 'Kategorie wählen'),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: isSaving ? null : pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: styledFieldDecoration(
                  label: 'Datum',
                  icon: Icons.calendar_today_outlined,
                  variant: StyledFieldVariant.transaction,
                ),
                child: Text(
                  DateFormat('dd.MM.yyyy').format(selectedDate.value),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: noteController,
              decoration: styledFieldDecoration(
                label: 'Notiz',
                icon: Icons.notes_outlined,
                variant: StyledFieldVariant.transaction,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        AppDestructiveButton(
          label: 'Verwerfen',
          onPressed: isSaving ? null : discard,
        ),
        const Spacer(),
        AppTextButton(
          label: 'Später',
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
            onPressed: isSaving ? null : save,
          ),
        ),
      ],
    );
  }

  String? _categoryName(List<ExpenseNode>? categories, String? selectedId) {
    if (categories == null || selectedId == null) return null;
    for (final category in categories) {
      if (category.id == selectedId) return category.name;
    }
    return null;
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
