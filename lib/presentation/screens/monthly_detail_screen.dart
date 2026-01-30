import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/presentation/providers/monthly_detail_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MonthlyDetailScreen extends ConsumerWidget {
  final DateTime month;

  const MonthlyDetailScreen({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Der Provider lädt die Daten spezifisch für das übergebene Monat-Datum
    final treeAsync = ref.watch(monthlyDetailTreeProvider(month));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${DateFormat('MMMM yyyy', 'de_DE').format(month)} (Variabel)",
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: treeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (roots) {
          if (roots.isEmpty) {
            return const Center(
              child: Text("Keine variablen Kosten für diesen Monat gefunden."),
            );
          }

          // Gesamtsummen berechnen
          double totalPlanned = 0;
          double totalActual = 0;
          for (var root in roots) {
            totalPlanned += root.planned;
            totalActual += root.actual;
          }

          final totalRemaining = totalPlanned - totalActual;
          final percent = totalPlanned == 0
              ? 0.0
              : (totalActual / totalPlanned).clamp(0.0, 1.0);

          return Column(
            children: [
              // HEADER ZEILE
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                color: Colors.grey.shade200,
                child: const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Kategorie",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Ist",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Budget",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // LISTE
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: roots
                      .map((node) => _ComparisonNodeRow(node: node, depth: 0))
                      .toList(),
                ),
              ),

              // FOOTER (TOTAL & DIFFERENZ)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zeile 1: Ist vs Budget
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Gesamtausgaben",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${totalActual.toStringAsFixed(2)} / ${totalPlanned.toStringAsFixed(2)} CHF",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Zeile 2: Progress Bar
                      LinearPercentIndicator(
                        lineHeight: 12.0,
                        percent: percent,
                        backgroundColor: Colors.grey.shade200,
                        progressColor: totalActual > totalPlanned
                            ? Colors.red
                            : Colors.teal,
                        barRadius: const Radius.circular(6),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 20),

                      // Zeile 3: Grosse Differenz Anzeige
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Verbleibend",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            "${totalRemaining >= 0 ? '+' : ''}${totalRemaining.toStringAsFixed(2)} CHF",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: totalRemaining >= 0
                                  ? Colors.teal
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ComparisonNodeRow extends StatelessWidget {
  final BudgetVsActualNode node;
  final int depth;

  const _ComparisonNodeRow({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    final isGroup = node.children.isNotEmpty;
    final isRoot = depth == 0;

    final isOverBudget = node.actual > node.planned;
    final percent = node.percentUsed.clamp(0.0, 1.0);

    Color barColor = Colors.teal;
    if (percent > 1.0) {
      barColor = Colors.red;
    } else if (percent > 0.85) {
      barColor = Colors.orange;
    }

    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isRoot ? Colors.white : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // NAME
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    SizedBox(width: depth * 16.0),
                    if (depth > 0)
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    if (depth > 0) const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        node.node.name,
                        style: TextStyle(
                          fontWeight: isGroup || isRoot
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: isRoot ? 16 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // IST
              Expanded(
                flex: 2,
                child: Text(
                  node.actual.toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOverBudget && node.planned > 0
                        ? Colors.red
                        : Colors.black87,
                  ),
                ),
              ),

              // SOLL
              Expanded(
                flex: 2,
                child: Text(
                  node.planned.toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),

          // Bar
          if (node.planned > 0 || node.actual > 0) ...[
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.only(left: depth * 16.0),
              child: LinearPercentIndicator(
                lineHeight: 4.0,
                percent: percent,
                backgroundColor: Colors.grey.shade200,
                progressColor: barColor,
                barRadius: const Radius.circular(2),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );

    if (isGroup) {
      return Column(
        children: [
          content,
          ...node.children.map(
            (child) => _ComparisonNodeRow(node: child, depth: depth + 1),
          ),
        ],
      );
    }

    return content;
  }
}
