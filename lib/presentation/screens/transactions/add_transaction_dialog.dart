import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/presentation/providers/dashboard_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/presentation/providers/transaction_providers.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final TransactionWithCategory? existingItem;

  const AddTransactionDialog({super.key, this.existingItem});

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;

  late DateTime _selectedDate;

  // Wir speichern ID und Name separat für die Autocomplete-Logik
  String? _selectedNodeId;
  String _selectedNodeName = "";

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;

    if (item != null) {
      _amountCtrl = TextEditingController(
        text: item.transaction.amount.toString(),
      );
      _noteCtrl = TextEditingController(text: item.transaction.note ?? '');
      _selectedDate = item.transaction.dateTime;
      _selectedNodeId = item.transaction.expenseNodeId;
      _selectedNodeName = item.categoryName;
    } else {
      _amountCtrl = TextEditingController();
      _noteCtrl = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedNodeId = null;
      _selectedNodeName = "";
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseTreeAsync = ref.watch(expenseTreeProvider);
    final isEdit = widget.existingItem != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
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

            // SCROLLBARER INHALT
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 1. BETRAG
                      const SizedBox(height: 8),
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          autofocus: !isEdit, // Fokus nur bei neuem Eintrag
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

                      // 2. KATEGORIE (AUTOCOMPLETE / SUCHE)
                      expenseTreeAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox(),
                        data: (roots) {
                          final allNodes = _flattenTreeVariableOnly(roots);

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return RawAutocomplete<ExpenseNode>(
                                // Initialwert setzen (wichtig für Edit Modus)
                                initialValue: _selectedNodeId != null
                                    ? TextEditingValue(text: _selectedNodeName)
                                    : null,

                                // LOGIK: Filtern beim Tippen
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return allNodes; // Alles anzeigen wenn leer
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

                                // LOGIK: Wenn ausgewählt wurde
                                onSelected: (ExpenseNode selection) {
                                  setState(() {
                                    _selectedNodeId = selection.id;
                                    _selectedNodeName = selection.name;
                                  });
                                  // Fokus schließen oder zum nächsten Feld springen
                                  FocusScope.of(context).unfocus();
                                },

                                displayStringForOption: (ExpenseNode option) =>
                                    option.name,

                                // UI: Das Textfeld
                                fieldViewBuilder:
                                    (
                                      context,
                                      textController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      // Fix: Wenn ID gesetzt aber Text leer (z.B. nach Reset), Text wiederherstellen
                                      if (_selectedNodeId != null &&
                                          textController.text.isEmpty) {
                                        textController.text = _selectedNodeName;
                                      }

                                      return TextFormField(
                                        controller: textController,
                                        focusNode: focusNode,
                                        decoration:
                                            _inputDecoration(
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
                                          if (_selectedNodeId == null)
                                            return 'Bitte Kategorie wählen';
                                          return null;
                                        },
                                        onChanged: (text) {
                                          // ID löschen wenn User den Text ändert, damit er neu wählen muss
                                          if (_selectedNodeId != null) {
                                            setState(() {
                                              _selectedNodeId = null;
                                            });
                                          }
                                        },
                                      );
                                    },

                                // UI: Die Ergebnis-Liste (Dropdown)
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 200, // Max Höhe der Liste
                                          maxWidth: constraints
                                              .maxWidth, // Gleiche Breite wie Input
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

                      // 3. DATUM
                      InkWell(
                        onTap: _pickDateTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            "Datum",
                            Icons.calendar_today_outlined,
                          ),
                          child: Text(
                            DateFormat(
                              'dd.MM.yyyy, HH:mm',
                            ).format(_selectedDate),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. NOTIZ
                      TextFormField(
                        controller: _noteCtrl,
                        decoration: _inputDecoration(
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

            // BUTTONS
            Row(
              children: [
                if (isEdit) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: _deleteTransaction,
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
                    onPressed: _saveTransaction,
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

  // --- HELPER ---

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Future<void> _pickDateTime() async {
    FocusScope.of(context).unfocus(); // Tastatur zu

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
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
        setState(
          () => _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ),
        );
      }
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedNodeId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Bitte Kategorie wählen")));
        return;
      }

      final amount =
          double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
      if (amount <= 0) return;

      final isEdit = widget.existingItem != null;
      final id = isEdit
          ? widget.existingItem!.transaction.id
          : const Uuid().v4();

      final txn = Transaction(
        id: id,
        expenseNodeId: _selectedNodeId!,
        amount: amount,
        dateTime: _selectedDate,
        note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
      );

      final repo = ref.read(transactionRepositoryProvider);
      if (isEdit) {
        await repo.updateTransaction(txn);
      } else {
        await repo.addTransaction(txn);
      }

      ref.invalidate(transactionListProvider);
      ref.invalidate(dashboardMonthlyStatsProvider);
      if (mounted) Navigator.pop(context);
    }
  }

  void _deleteTransaction() async {
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

    if (confirm == true && widget.existingItem != null) {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(widget.existingItem!.transaction.id);
      ref.invalidate(transactionListProvider);
      ref.invalidate(dashboardMonthlyStatsProvider);
      if (mounted) Navigator.pop(context);
    }
  }

  List<ExpenseNode> _flattenTreeVariableOnly(List<ExpenseNode> nodes) {
    final List<ExpenseNode> flat = [];
    for (var node in nodes) {
      if (node.type == 'Variable') flat.add(node);
      if (node.children.isNotEmpty)
        flat.addAll(_flattenTreeVariableOnly(node.children));
    }
    return flat;
  }
}
