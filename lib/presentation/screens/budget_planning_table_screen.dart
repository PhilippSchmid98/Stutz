import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/logic_extensions.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/providers/budget_providers.dart';
import 'package:stutz/presentation/screens/widgets/cloud_status_icon.dart';
import 'package:uuid/uuid.dart';

// Callback-Definition für bessere Lesbarkeit
typedef OnReorderCallback =
    void Function(ExpenseNode parent, int oldIndex, int newIndex);

class BudgetPlanningTableScreen extends ConsumerStatefulWidget {
  const BudgetPlanningTableScreen({super.key});

  @override
  ConsumerState<BudgetPlanningTableScreen> createState() =>
      _BudgetPlanningTableScreenState();
}

class _BudgetPlanningTableScreenState
    extends ConsumerState<BudgetPlanningTableScreen> {
  bool _isEditMode = false;

  // LOKALER STATE für butterweiche Animationen (Optimistic UI)
  List<ExpenseNode>? _localNodes;

  // Synchronisiert die DB-Daten mit unserem lokalen State
  void _syncLocalState(List<ExpenseNode> nodesFromDb) {
    if (_localNodes == null || !_isEditMode) {
      _localNodes = List.from(nodesFromDb);
    }
  }

  // --- HILFSFUNKTION: Rekursives Update im Baum ---
  // Sucht den Knoten mit der ID von updatedNode und ersetzt ihn durch die neue Version
  List<ExpenseNode> _updateNodeInTree(
    List<ExpenseNode> nodes,
    ExpenseNode updatedNode,
  ) {
    return nodes.map((node) {
      // Treffer: Ersetze diesen Knoten
      if (node.id == updatedNode.id) return updatedNode;

      // Kein Treffer, aber hat Kinder: Suche rekursiv weiter
      if (node.children.isNotEmpty) {
        return ExpenseNode(
          id: node.id,
          parentId: node.parentId,
          name: node.name,
          plannedAmount: node.plannedAmount,
          interval: node.interval,
          type: node.type,
          sortOrder: node.sortOrder,
          children: _updateNodeInTree(node.children, updatedNode),
        );
      }
      // Nichts zu tun
      return node;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final incomeAsync = ref.watch(incomeListProvider);
    final expenseRootsAsync = ref.watch(expenseTreeProvider);

    ref.listen<AsyncValue<List<ExpenseNode>>>(expenseTreeProvider, (
      prev,
      next,
    ) {
      if (next.hasValue && next.value != null) {
        setState(() {
          _syncLocalState(next.value!);
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Budget Planung'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          const CloudStatusIcon(),
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.sort),
            color: _isEditMode ? Colors.teal : Colors.black,
            tooltip: _isEditMode ? "Bearbeiten beenden" : "Reihenfolge ändern",
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
                if (_isEditMode && expenseRootsAsync.hasValue) {
                  _localNodes = List.from(expenseRootsAsync.value!);
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            // ------------------------------------------------------
            // 1. EINNAHMEN
            // ------------------------------------------------------
            incomeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Fehler: $e'),
              data: (incomes) => _buildIncomeSection(context, incomes),
            ),

            const SizedBox(height: 32),
            _buildSeparator("AUSGABEN"),
            const SizedBox(height: 16),

            // ------------------------------------------------------
            // 2. AUSGABEN (Tree View)
            // ------------------------------------------------------
            expenseRootsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Fehler: $e'),
              data: (roots) {
                // Initialer Sync
                if (_localNodes == null) {
                  _localNodes = List.from(roots);
                }

                final displayList = _localNodes ?? roots;

                if (_isEditMode) {
                  // --- EDIT MODE (Reorderable) ---
                  return ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: displayList.length,
                    onReorder: _onReorderMainCategories,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 5,
                        color: Colors.transparent,
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final rootNode = displayList[index];
                      return _buildExpenseCard(
                        context,
                        rootNode,
                        index,
                        isEditMode: true,
                      );
                    },
                  );
                } else {
                  // --- VIEW MODE (Normal) ---
                  return Column(
                    children: displayList.map((rootNode) {
                      return _buildExpenseCard(
                        context,
                        rootNode,
                        -1,
                        isEditMode: false,
                      );
                    }).toList(),
                  );
                }
              },
            ),

            const SizedBox(height: 24),
            if (incomeAsync.hasValue && _localNodes != null)
              _buildOverviewCard(incomeAsync.value!, _localNodes!),

            if (!_isEditMode) const _LegendRow(),
          ],
        ),
      ),
    );
  }

  // --- LOGIK: REORDERING ---

  void _onReorderMainCategories(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    setState(() {
      final item = _localNodes!.removeAt(oldIndex);
      _localNodes!.insert(newIndex, item);
    });

    final sortedList = List<ExpenseNode>.from(_localNodes!);
    ref.read(expenseNodeRepositoryProvider).updateNodeOrder(sortedList);
  }

  // Diese Methode wurde verbessert, um rekursiv zu arbeiten
  void _onReorderSubItems(ExpenseNode parent, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    setState(() {
      // 1. Liste der Kinder kopieren und ändern
      final mutableChildren = List<ExpenseNode>.from(parent.children);
      final item = mutableChildren.removeAt(oldIndex);
      mutableChildren.insert(newIndex, item);

      // 2. Den Eltern-Knoten neu erstellen mit der neuen Kinder-Liste
      final newParent = ExpenseNode(
        id: parent.id,
        parentId: parent.parentId,
        name: parent.name,
        plannedAmount: parent.plannedAmount,
        interval: parent.interval,
        type: parent.type,
        sortOrder: parent.sortOrder,
        children: mutableChildren,
      );

      // 3. Den Baum aktualisieren (rekursives Suchen & Ersetzen)
      _localNodes = _updateNodeInTree(_localNodes!, newParent);

      // 4. DB Update
      ref.read(expenseNodeRepositoryProvider).updateNodeOrder(mutableChildren);
    });
  }

  // --- WIDGET BUILDER ---

  Widget _buildExpenseCard(
    BuildContext context,
    ExpenseNode rootNode,
    int index, {
    required bool isEditMode,
  }) {
    final monthly = rootNode.totalMonthlyCalculated;
    double yearly = 0;

    Widget content;

    if (isEditMode) {
      // --- EDIT MODE: Sortierbare Liste ---
      content = ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: rootNode.children.length,
        // Callback weitergeben
        onReorder: (oldIdx, newIdx) =>
            _onReorderSubItems(rootNode, oldIdx, newIdx),
        itemBuilder: (ctx, childIndex) {
          final child = rootNode.children[childIndex];
          return _ExpenseItemRow(
            key: ValueKey(child.id),
            node: child,
            depth: 0,
            isEditMode: true,
            index: childIndex,
            // Callback weiterreichen für verschachtelte Gruppen!
            onReorder: _onReorderSubItems,
          );
        },
      );
    } else {
      // --- VIEW MODE: Statische Liste ---
      content = Column(
        children: rootNode.children
            .map(
              (child) =>
                  _ExpenseItemRow(node: child, depth: 0, isEditMode: false),
            )
            .toList(),
      );
    }

    return Padding(
      key: ValueKey(rootNode.id),
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _SectionCard(
        title: rootNode.name.toUpperCase(),
        totalMonthly: monthly,
        totalYearly: yearly,
        icon: Icons.folder_open,
        iconColor: Colors.teal,
        backgroundColor: Colors.white,
        onHeaderTap: isEditMode
            ? null
            : () => showDialog(
                context: context,
                builder: (_) => _AddExpenseNodeDialog(
                  parentId: rootNode.parentId,
                  existingNode: rootNode,
                ),
              ),
        trailingHeader: isEditMode
            ? ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.drag_handle, color: Colors.teal),
                ),
              )
            : null,
        children: [
          content,
          if (!isEditMode) ...[
            const SizedBox(height: 12),
            _AddButton(
              label: "Eintrag hinzufügen",
              onTap: () => showDialog(
                context: context,
                builder: (_) => _AddExpenseNodeDialog(parentId: rootNode.id),
              ),
              color: Colors.teal,
            ),
          ],
        ],
      ),
    );
  }

  // --- HELPER SECTIONS (Income, Separator, Overview) ---
  Widget _buildIncomeSection(BuildContext context, List<IncomeSource> incomes) {
    double rawMonthlySum = 0;
    double rawYearlySum = 0;
    for (final item in incomes) {
      if (item.interval == 'Monthly') {
        rawMonthlySum += item.amount;
      } else {
        rawYearlySum += item.amount;
      }
    }

    final mainIncomes = incomes.where((i) => i.group == 'Main').toList();
    final additionalIncomes = incomes
        .where((i) => i.group == 'Additional')
        .toList();

    return _SectionCard(
      title: "EINNAHMEN",
      totalMonthly: rawMonthlySum,
      totalYearly: rawYearlySum,
      icon: Icons.trending_up,
      iconColor: Colors.green,
      backgroundColor: Colors.green.shade50,
      children: [
        if (mainIncomes.isNotEmpty) ...[
          const _SubsectionTitle(title: "Haupteinnahmen"),
          ...mainIncomes.map((i) => _IncomeItemRow(item: i)),
        ],
        if (mainIncomes.isNotEmpty && additionalIncomes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.green.shade200),
          ),
        if (additionalIncomes.isNotEmpty) ...[
          const _SubsectionTitle(title: "Nebeneinnahmen"),
          ...additionalIncomes.map((i) => _IncomeItemRow(item: i)),
        ],
        const SizedBox(height: 16),
        _AddButton(
          label: "Neue Einnahme",
          onTap: () => showDialog(
            context: context,
            builder: (_) => const _AddIncomeDialog(),
          ),
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSeparator(String title) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildOverviewCard(
    List<IncomeSource> incomes,
    List<ExpenseNode> roots,
  ) {
    double totalIncome = 0;
    for (var i in incomes) {
      if (i.interval == 'Monthly') {
        totalIncome += i.amount;
      } else {
        totalIncome += (i.amount / 12);
      }
    }

    double totalFixed = 0;
    double totalVariable = 0;

    void calcByType(List<ExpenseNode> nodes) {
      for (var node in nodes) {
        if (node.plannedAmount != null) {
          double amount = node.plannedAmount!;
          if (node.interval == 'Yearly') {
            amount /= 12;
          }
          if (node.type == 'Fixed') {
            totalFixed += amount;
          } else {
            totalVariable += amount;
          }
        }
        if (node.children.isNotEmpty) calcByType(node.children);
      }
    }

    calcByType(roots);
    double totalExpenses = totalFixed + totalVariable;
    double balance = totalIncome - totalExpenses;

    return _BudgetOverviewCard(
      income: totalIncome,
      expenses: totalExpenses,
      balance: balance,
      fixedExpenses: totalFixed,
      variableExpenses: totalVariable,
    );
  }
}

// -----------------------------------------------------------------------------
// UI WIDGETS
// -----------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final double totalMonthly;
  final double totalYearly;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final List<Widget> children;
  final VoidCallback? onHeaderTap;
  final Widget? trailingHeader;

  const _SectionCard({
    required this.title,
    required this.totalMonthly,
    required this.totalYearly,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.children,
    this.onHeaderTap,
    this.trailingHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: backgroundColor != Colors.white
            ? Border.all(color: iconColor.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        if (totalMonthly > 0)
                          Text(
                            "${totalMonthly.toStringAsFixed(2)} / Monat",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (totalMonthly > 0)
                    Text(
                      "Ø ${totalMonthly.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: iconColor,
                      ),
                    ),
                  if (trailingHeader != null) ...[
                    const SizedBox(width: 16),
                    trailingHeader!,
                  ],
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: iconColor.withValues(alpha: 0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseItemRow extends StatelessWidget {
  final ExpenseNode node;
  final int depth;
  final bool isEditMode;
  final int index;
  final OnReorderCallback? onReorder; // NEU: Callback für Verschachtelung

  const _ExpenseItemRow({
    super.key,
    required this.node,
    required this.depth,
    this.isEditMode = false,
    this.index = 0,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty;
    final isFixed = node.type == 'Fixed';

    // 1. Die Zeile selbst
    Widget rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: depth * 12.0),
          Icon(
            hasChildren
                ? Icons.folder_outlined
                : (isFixed ? Icons.lock_outline : Icons.shopping_bag_outlined),
            size: 18,
            color: hasChildren ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: hasChildren ? FontWeight.w600 : FontWeight.normal,
                color: isFixed ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
          ),
          if (node.plannedAmount != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  node.plannedAmount!.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isFixed ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
                Text(
                  node.interval == 'Monthly' ? "Monatlich" : "Jährlich",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          if (isEditMode) ...[
            const SizedBox(width: 16, height: 48),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ] else if (hasChildren || node.plannedAmount == null) ...[
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                size: 20,
                color: Colors.teal,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _AddExpenseNodeDialog(parentId: node.id),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );

    // Klickverhalten im View Mode
    if (!isEditMode) {
      rowContent = InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (_) => _AddExpenseNodeDialog(
            parentId: node.parentId,
            existingNode: node,
          ),
        ),
        child: rowContent,
      );
    }

    // --- REKURSION: Kinder anzeigen ---
    if (hasChildren) {
      if (isEditMode) {
        // EDIT MODE: Sortierbare Liste anzeigen
        return Column(
          children: [
            rowContent,
            Container(
              margin: const EdgeInsets.only(left: 16), // Einrückung
              // Wir nutzen ReorderableListView für die Verschachtelung
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: node.children.length,
                onReorder: (oldIdx, newIdx) {
                  // Callback aufrufen (node ist hier der Parent)
                  if (onReorder != null) onReorder!(node, oldIdx, newIdx);
                },
                itemBuilder: (ctx, idx) {
                  final child = node.children[idx];
                  return _ExpenseItemRow(
                    key: ValueKey(child.id),
                    node: child,
                    depth: 0, // Reset depth da wir Container margin nutzen
                    isEditMode: true,
                    index: idx,
                    onReorder: onReorder, // Rekursiv weitergeben
                  );
                },
              ),
            ),
          ],
        );
      } else {
        // VIEW MODE: Einfache Liste anzeigen
        return Column(
          children: [
            rowContent,
            ...node.children.map(
              (child) => _ExpenseItemRow(
                node: child,
                depth: depth + 1,
                isEditMode: false,
              ),
            ),
          ],
        );
      }
    }

    return rowContent;
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _AddButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          "+ $label",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Icons.lock_outline, "Fixkosten"),
          const SizedBox(width: 16),
          _legendItem(Icons.shopping_bag_outlined, "Variable Kosten"),
          const SizedBox(width: 16),
          _legendItem(Icons.folder_outlined, "Gruppe"),
        ],
      ),
    );
  }

  Widget _legendItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _IncomeItemRow extends StatelessWidget {
  final IncomeSource item;
  const _IncomeItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isMonthly = item.interval == 'Monthly';
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _AddIncomeDialog(existingItem: item),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 20,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.name, style: const TextStyle(fontSize: 15)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  isMonthly ? "Monatlich" : "Jährlich",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubsectionTitle extends StatelessWidget {
  final String title;
  const _SubsectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _BudgetOverviewCard extends StatelessWidget {
  final double income;
  final double expenses;
  final double balance;
  final double fixedExpenses;
  final double variableExpenses;

  const _BudgetOverviewCard({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.fixedExpenses,
    required this.variableExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final balanceColor = isPositive ? Colors.teal : Colors.red;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: balanceColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "MONATLICHES BUDGET (Ø)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${isPositive ? '+' : ''} ${balance.toStringAsFixed(2)} CHF",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              color: balanceColor,
            ),
          ),
          Text(
            isPositive ? "Verfügbarer Überschuss" : "Budgetdefizit",
            style: TextStyle(
              color: balanceColor.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OverviewItem(
                label: "Einnahmen",
                value: income,
                color: Colors.green,
              ),
              _OverviewItem(
                label: "Ausgaben",
                value: expenses,
                color: Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monatlich fix",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      fixedExpenses.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Monatlich variabel",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      variableExpenses.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _OverviewItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// DIALOGE (Add/Edit)
// -----------------------------------------------------------------------------

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? suffixText;

  const _StyledTextField({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          suffixText: suffixText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null,
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  final String value;
  final Map<String, String> items;
  final String label;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items.entries.map((e) {
          return DropdownMenuItem(value: e.key, child: Text(e.value));
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}

class _AddIncomeDialog extends ConsumerStatefulWidget {
  final IncomeSource? existingItem;
  const _AddIncomeDialog({this.existingItem});
  @override
  ConsumerState<_AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends ConsumerState<_AddIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  String _interval = 'Monthly';
  String _group = 'Main';

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
                _StyledTextField(
                  controller: _nameCtrl,
                  label: 'Bezeichnung',
                  icon: Icons.description_outlined,
                ),
                _StyledTextField(
                  controller: _amountCtrl,
                  label: 'Betrag',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  suffixText: 'CHF',
                ),
                _StyledDropdown(
                  value: _interval,
                  items: const {'Monthly': 'Monatlich', 'Yearly': 'Jährlich'},
                  label: 'Intervall',
                  icon: Icons.calendar_today,
                  onChanged: (v) => setState(() => _interval = v!),
                ),
                _StyledDropdown(
                  value: _group,
                  items: const {
                    'Main': 'Haupteinnahmen',
                    'Additional': 'Zusätzliche Einnahmen',
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

class _AddExpenseNodeDialog extends ConsumerStatefulWidget {
  final String? parentId;
  final ExpenseNode? existingNode;
  const _AddExpenseNodeDialog({this.parentId, this.existingNode});
  @override
  ConsumerState<_AddExpenseNodeDialog> createState() =>
      _AddExpenseNodeDialogState();
}

class _AddExpenseNodeDialogState extends ConsumerState<_AddExpenseNodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;

  bool _isGroup = false;
  String _interval = 'Monthly';
  String _type = 'Fixed';

  @override
  void initState() {
    super.initState();
    if (widget.existingNode != null) {
      final node = widget.existingNode!;
      _nameCtrl = TextEditingController(text: node.name);
      if (node.plannedAmount == null) {
        _isGroup = true;
        _amountCtrl = TextEditingController();
      } else {
        _isGroup = false;
        _amountCtrl = TextEditingController(
          text: node.plannedAmount.toString(),
        );
        if (node.interval != null) _interval = node.interval!;
        if (node.type != null) _type = node.type!;
      }
    } else {
      _nameCtrl = TextEditingController();
      _amountCtrl = TextEditingController();
      _isGroup = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingNode != null;

    String title = "Neuer Eintrag";
    if (isEdit) {
      title = _isGroup ? "Gruppe bearbeiten" : "Eintrag bearbeiten";
    } else if (widget.parentId == null) {
      title = "Hinzufügen";
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit) ...[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TypeSelectorButton(
                            label: "Eintrag",
                            icon: Icons.receipt_long,
                            isSelected: !_isGroup,
                            onTap: () => setState(() => _isGroup = false),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _TypeSelectorButton(
                            label: "Gruppe",
                            icon: Icons.folder_open,
                            isSelected: _isGroup,
                            onTap: () => setState(() => _isGroup = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                _StyledTextField(
                  controller: _nameCtrl,
                  label: 'Bezeichnung',
                  icon: _isGroup ? Icons.folder_outlined : Icons.tag,
                ),

                if (!_isGroup) ...[
                  _StyledTextField(
                    controller: _amountCtrl,
                    label: 'Betrag',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    suffixText: 'CHF',
                  ),
                  _StyledDropdown(
                    value: _interval,
                    items: const {'Monthly': 'Monatlich', 'Yearly': 'Jährlich'},
                    label: 'Intervall',
                    icon: Icons.calendar_today,
                    onChanged: (v) => setState(() => _interval = v!),
                  ),
                  _StyledDropdown(
                    value: _type,
                    items: const {'Fixed': 'Fix', 'Variable': 'Variabel'},
                    label: 'Typ',
                    icon: Icons.tune,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Eine Gruppe enthält Unterkategorien. Sie hat keinen eigenen Betrag.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              final hasChildren = widget.existingNode!.children.isNotEmpty;
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Löschen?"),
                  content: Text(
                    hasChildren
                        ? "ACHTUNG: Gruppe mit Inhalt löschen?"
                        : "Löschen?",
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
                    .read(expenseNodeRepositoryProvider)
                    .deleteExpenseNode(widget.existingNode!.id);
                ref.invalidate(expenseTreeProvider);
                ref.invalidate(totalMonthlyExpensesProvider);
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
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final repo = ref.read(expenseNodeRepositoryProvider);
              final parentId = isEdit
                  ? widget.existingNode!.parentId
                  : widget.parentId;
              final id = isEdit ? widget.existingNode!.id : const Uuid().v4();
              // SortOrder beim Erstellen beibehalten oder default
              final currentSortOrder = isEdit
                  ? widget.existingNode!.sortOrder
                  : 99999;

              final node = ExpenseNode(
                id: id,
                parentId: parentId,
                name: _nameCtrl.text,
                plannedAmount: _isGroup
                    ? null
                    : double.parse(_amountCtrl.text.replaceAll(',', '.')),
                interval: _isGroup ? null : _interval,
                type: _isGroup ? null : _type,
                children: isEdit ? widget.existingNode!.children : [],
                sortOrder: currentSortOrder,
              );
              if (isEdit) {
                await repo.updateExpenseNode(node);
              } else {
                await repo.addExpenseNode(node);
              }
              ref.invalidate(expenseTreeProvider);
              ref.invalidate(totalMonthlyExpensesProvider);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

class _TypeSelectorButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelectorButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.teal : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
