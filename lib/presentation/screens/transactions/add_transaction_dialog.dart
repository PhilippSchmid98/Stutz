import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/presentation/providers/repository_providers.dart';
import 'package:stutz/presentation/providers/dashboard_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/presentation/providers/transaction_providers.dart';

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
    // Store ID and name separately for autocomplete logic
    final selectedNodeId = useState<String?>(
      existingItem?.transaction.expenseNodeId,
    );
    final selectedNodeName = useState<String>(existingItem?.categoryName ?? '');

    final expenseTreeAsync = ref.watch(expenseTreeProvider);
    final isEdit = existingItem != null;

    // --- HELPERS ---

    InputDecoration inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
      );
    }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bitte Kategorie wählen")),
          );
          return;
        }

        final amount =
            double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
        if (amount <= 0) return;

        final id = isEdit ? existingItem!.transaction.id : const Uuid().v4();

        final txn = AppTransaction(
          id: id,
          expenseNodeId: selectedNodeId.value!,
          amount: amount,
          dateTime: selectedDate.value,
          note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
        );

        final repo = ref.read(transactionRepositoryProvider);
        if (isEdit) {
          await repo.updateTransaction(txn);
        } else {
          await repo.addTransaction(txn);
        }

        ref.invalidate(transactionListProvider);
        ref.invalidate(dashboardMonthlyStatsProvider);
        if (context.mounted) Navigator.pop(context);
      }
    }

    Future<void> deleteTransaction() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Löschen"),
          content: const Text("Wirklich löschen?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                "Abbrechen",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Löschen", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true && existingItem != null) {
        await ref
            .read(transactionRepositoryProvider)
            .deleteTransaction(existingItem!.transaction.id);
        ref.invalidate(transactionListProvider);
        ref.invalidate(dashboardMonthlyStatsProvider);
        if (context.mounted) Navigator.pop(context);
      }
    }

    // --- BUILD ---

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? "Bearbeiten" : "Neue Ausgabe",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
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
            ),

            const SizedBox(height: 16),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // 1. Amount
                      const SizedBox(height: 8),
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          autofocus: !isEdit,
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
                          validator: (v) => v == null || v.isEmpty ? '' : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Category (autocomplete / search)
                      expenseTreeAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox(),
                        data: (roots) {
                          final allNodes = _flattenTreeVariableOnly(roots);

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return RawAutocomplete<ExpenseNode>(
                                initialValue: selectedNodeId.value != null
                                    ? TextEditingValue(
                                        text: selectedNodeName.value,
                                      )
                                    : null,
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return allNodes;
                                      }
                                      return allNodes.where((
                                        ExpenseNode option,
                                      ) {
                                        return option.name
                                            .toLowerCase()
                                            .contains(
                                              textEditingValue.text
                                                  .toLowerCase(),
                                            );
                                      });
                                    },
                                onSelected: (ExpenseNode selection) {
                                  selectedNodeId.value = selection.id;
                                  selectedNodeName.value = selection.name;
                                  FocusScope.of(context).unfocus();
                                },
                                displayStringForOption: (ExpenseNode option) =>
                                    option.name,
                                fieldViewBuilder:
                                    (
                                      context,
                                      textController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      if (selectedNodeId.value != null &&
                                          textController.text.isEmpty) {
                                        textController.text =
                                            selectedNodeName.value;
                                      }

                                      return TextFormField(
                                        controller: textController,
                                        focusNode: focusNode,
                                        decoration:
                                            inputDecoration(
                                              "Kategorie (Suchen...)",
                                              Icons.category_outlined,
                                            ).copyWith(
                                              suffixIcon: const Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        validator: (v) {
                                          if (selectedNodeId.value == null) {
                                            return 'Bitte Kategorie wählen';
                                          }
                                          return null;
                                        },
                                        onChanged: (text) {
                                          if (selectedNodeId.value != null) {
                                            selectedNodeId.value = null;
                                          }
                                        },
                                      );
                                    },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
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
                                              const Divider(
                                                height: 1,
                                                indent: 16,
                                                endIndent: 16,
                                              ),
                                          itemBuilder:
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                final option = options
                                                    .elementAt(index);
                                                return InkWell(
                                                  onTap: () =>
                                                      onSelected(option),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 12,
                                                        ),
                                                    child: Text(
                                                      option.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // 3. Date
                      InkWell(
                        onTap: pickDateTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: inputDecoration(
                            "Datum",
                            Icons.calendar_today_outlined,
                          ),
                          child: Text(
                            DateFormat(
                              'dd.MM.yyyy, HH:mm',
                            ).format(selectedDate.value),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Note
                      TextFormField(
                        controller: noteCtrl,
                        decoration: inputDecoration(
                          "Notiz",
                          Icons.notes_rounded,
                        ),
                        maxLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (isEdit) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: deleteTransaction,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Löschen",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: saveTransaction,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Speichern",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<ExpenseNode> _flattenTreeVariableOnly(List<ExpenseNode> nodes) {
  final List<ExpenseNode> flat = [];
  for (var node in nodes) {
    if (node.type == ExpenseType.variable) flat.add(node);
    if (node.children.isNotEmpty) {
      flat.addAll(_flattenTreeVariableOnly(node.children));
    }
  }
  return flat;
}
