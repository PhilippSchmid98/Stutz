// Datei: lib/presentation/screens/yearly_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/presentation/providers/yearly_detail_provider.dart';

class YearlyDetailScreen extends ConsumerStatefulWidget {
  const YearlyDetailScreen({super.key});

  @override
  ConsumerState<YearlyDetailScreen> createState() => _YearlyDetailScreenState();
}

class _YearlyDetailScreenState extends ConsumerState<YearlyDetailScreen> {
  int _selectedYear = DateTime.now().year;
  bool _includeOffset = true; // Default: Option B (Virtuell + Echt)

  @override
  Widget build(BuildContext context) {
    final treeAsync = ref.watch(yearlyDetailTreeProvider(_selectedYear));

    // Jahresfortschritt berechnen
    final now = DateTime.now();
    double yearProgress = 0.0;
    if (_selectedYear == now.year) {
      final startOfYear = DateTime(_selectedYear, 1, 1);
      final daysPassed = now.difference(startOfYear).inDays;
      final daysInYear = (_selectedYear % 4 == 0) ? 366 : 365;
      yearProgress = daysPassed / daysInYear;
    } else if (_selectedYear < now.year) {
      yearProgress = 1.0; // Vergangenes Jahr ist 100% vorbei
    } else {
      yearProgress = 0.0; // Zukunft
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _selectedYear--),
            ),
            Text(
              "$_selectedYear (Variabel)",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _selectedYear++),
            ),
          ],
        ),
        actions: [
          // Anzeige Jahresfortschritt oben rechts
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${(yearProgress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.teal,
                    ),
                  ),
                  const Text(
                    "Jahr",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: treeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (roots) {
          if (roots.isEmpty) {
            return const Center(child: Text("Keine Daten für dieses Jahr."));
          }

          // Gesamtsummen für Footer
          double totalPlanned = 0;
          double totalActual = 0;
          double totalOffset = 0;

          for (var node in roots) {
            totalPlanned += node.planned;
            totalActual += node.actual;
            totalOffset += node.offset;
          }

          final hasOffset = totalOffset > 0;
          final displayUsage = _includeOffset
              ? (totalActual + totalOffset)
              : totalActual;
          final totalRemaining = totalPlanned - displayUsage;

          return Column(
            children: [
              // HEADER & TOGGLE
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    if (hasOffset)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Start unterjährig. Werte inkl. ${(totalOffset).toStringAsFixed(0)} CHF Vorlauf.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                            Switch(
                              value: _includeOffset,
                              activeThumbColor: Colors.teal,
                              onChanged: (val) =>
                                  setState(() => _includeOffset = val),
                            ),
                          ],
                        ),
                      ),

                    // Spaltenbeschriftung
                    const Row(
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
                          flex: 3,
                          child: Text(
                            "Verbrauch",
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
                            "%",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // LISTE
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: roots
                      .map(
                        (node) => _YearlyNodeRow(
                          node: node,
                          depth: 0,
                          showOffset: _includeOffset && hasOffset,
                        ),
                      )
                      .toList(),
                ),
              ),

              // FOOTER (TOTAL)
              Container(
                padding: const EdgeInsets.all(24),
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
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Jahresbilanz",
                            style: TextStyle(fontSize: 16),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${displayUsage.toStringAsFixed(0)} / ${totalPlanned.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (_includeOffset && hasOffset)
                                Text(
                                  "(inkl. ${totalOffset.toStringAsFixed(0)} Offset)",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Custom Stacked Progress Bar für Total
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 12,
                          child: _StackedProgressBar(
                            offsetPercent: _includeOffset
                                ? (totalOffset / totalPlanned)
                                : 0,
                            actualPercent: totalActual / totalPlanned,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Verbleibend",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${totalRemaining >= 0 ? '+' : ''}${totalRemaining.toStringAsFixed(0)} CHF",
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

class _YearlyNodeRow extends StatelessWidget {
  final YearlyBudgetNode node;
  final int depth;
  final bool showOffset;

  const _YearlyNodeRow({
    required this.node,
    required this.depth,
    required this.showOffset,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = node.children.isNotEmpty;
    final isRoot = depth == 0;

    // Prozente berechnen
    final percentOffset = showOffset ? node.percentOffset : 0.0;
    final percentActual = node.percentUsedReal;
    final percentTotalDisplay = (percentOffset + percentActual).clamp(
      0.0,
      9.99,
    ); // Cap für Textanzeige

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isRoot ? Colors.white : Colors.transparent,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
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
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // VERBRAUCH (Absolut)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (showOffset ? node.totalUsageWithOffset : node.actual)
                              .toStringAsFixed(0),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          "/ ${node.planned.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PROZENT
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${(percentTotalDisplay * 100).toStringAsFixed(0)}%",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: percentTotalDisplay > 1.0
                            ? Colors.red
                            : Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Progress Bar
              Padding(
                padding: EdgeInsets.only(left: depth * 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 4,
                    child: _StackedProgressBar(
                      offsetPercent: percentOffset,
                      actualPercent: percentActual,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isGroup)
          ...node.children.map(
            (child) => _YearlyNodeRow(
              node: child,
              depth: depth + 1,
              showOffset: showOffset,
            ),
          ),
      ],
    );
  }
}

// Spezial Widget für den gestapelten Balken (Grau + Farbe)
class _StackedProgressBar extends StatelessWidget {
  final double offsetPercent;
  final double actualPercent;
  final Color backgroundColor;

  const _StackedProgressBar({
    required this.offsetPercent,
    required this.actualPercent,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Normalisieren, damit wir nicht über 100% zeichnen (Overflow)
    double pOffset = offsetPercent.clamp(0.0, 1.0);
    double pActual = actualPercent.clamp(
      0.0,
      1.0 - pOffset,
    ); // Restplatz nutzen

    // Farbe Logik: Wenn Gesamt > 100% -> Rot, sonst Teal
    // (Hier vereinfacht: Der Actual Teil wird rot, wenn er das Budget sprengt)
    final total = offsetPercent + actualPercent;
    final color = total > 1.0 ? Colors.red : Colors.teal;
    final offsetColor = Colors.grey.shade400; // Farbe für "Virtuell"

    // Falls total > 1.0, müssen wir die Flex Werte anpassen, sonst crasht Row
    // Wir cappen die Anzeige visuell bei 100%
    if (pOffset + pActual > 1.0) {
      double scale = 1.0 / (pOffset + pActual);
      pOffset *= scale;
      pActual *= scale;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          color: backgroundColor,
          child: Row(
            children: [
              // 1. Offset Teil (Grau / Schraffiert)
              Container(width: width * pOffset, color: offsetColor),
              // 2. Actual Teil (Farbe)
              Container(width: width * pActual, color: color),
            ],
          ),
        );
      },
    );
  }
}
