import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/presentation/providers/category_transactions_provider.dart';

class CategoryTransactionsScreen extends ConsumerWidget {
  final String nodeName;
  final List<String> nodeIds;
  final Map<String, String> nodeNames;
  final int year;
  final int? month; // null = yearly context

  const CategoryTransactionsScreen({
    super.key,
    required this.nodeName,
    required this.nodeIds,
    required this.nodeNames,
    required this.year,
    this.month,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnsAsync = ref.watch(
      categoryTransactionsProvider(nodeIds, year, month),
    );

    final periodLabel = month != null
        ? DateFormat('MMMM yyyy', 'de_DE').format(DateTime(year, month!))
        : year.toString();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nodeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              periodLabel,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      body: txnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (txns) {
          if (txns.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keine Transaktionen vorhanden',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$nodeName · $periodLabel',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          final total = txns.fold<double>(0.0, (sum, t) => sum + t.amount);

          return Column(
            children: [
              // Transaction list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: txns.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final t = txns[index];
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Date block
                          SizedBox(
                            width: 48,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('dd').format(t.dateTime),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM', 'de_DE').format(t.dateTime),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.grey.shade200,
                          ),
                          // Note & node name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.note?.isNotEmpty == true ? t.note! : '—',
                                  style: TextStyle(
                                    color: t.note?.isNotEmpty == true
                                        ? Colors.black87
                                        : Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                                if (nodeNames[t.expenseNodeId] != null)
                                  Text(
                                    nodeNames[t.expenseNodeId]!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Amount
                          Text(
                            '${t.amount.toStringAsFixed(2)} CHF',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Footer: total
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${txns.length} Transaktion${txns.length != 1 ? 'en' : ''}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Total: ${total.toStringAsFixed(2)} CHF',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
