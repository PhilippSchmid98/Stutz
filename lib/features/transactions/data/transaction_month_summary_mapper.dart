import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

class TransactionMonthSummaryMapper {
  const TransactionMonthSummaryMapper._();

  static TransactionMonthSummary fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw FormatException('Transaction month ${document.id} has no data');
    }
    return fromData(document.id, data);
  }

  static TransactionMonthSummary fromData(
    String monthKey,
    Map<String, dynamic> data,
  ) {
    final transactionCount = data['transactionCount'];
    final categoryTotals = data['categoryTotals'];

    return TransactionMonthSummary(
      month: TransactionMonth.fromKey(monthKey),
      transactionCount: transactionCount is num
          ? transactionCount.toInt().clamp(0, 1 << 31)
          : 0,
      categoryTotals: {
        if (categoryTotals is Map)
          for (final entry in categoryTotals.entries)
            if (entry.key is String &&
                entry.key.isNotEmpty &&
                entry.value is num)
              entry.key as String: (entry.value as num).toDouble(),
      },
    );
  }
}
