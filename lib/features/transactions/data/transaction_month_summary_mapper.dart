import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/core/utils/amount_parser.dart';
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
    return TransactionMonthSummary(
      month: TransactionMonth.fromKey(monthKey),
      transactionCount: transactionCount is num
          ? transactionCount.toInt().clamp(0, 1 << 31)
          : 0,
      categoryTotalsMinor: categoryTotalsMinorFromData(data),
    );
  }

  static Map<String, int> categoryTotalsMinorFromData(
    Map<String, dynamic>? data,
  ) {
    final canonicalTotals = data?['categoryTotalsMinor'];
    final rawTotals = canonicalTotals ?? data?['categoryTotals'];
    if (rawTotals is! Map) return {};

    return {
      for (final entry in rawTotals.entries)
        if (entry.key is String && entry.key.isNotEmpty && entry.value is num)
          entry.key as String: storedMinorUnits(
            minorValue: canonicalTotals == null ? null : entry.value,
            legacyMajorValue: canonicalTotals == null ? entry.value : null,
            allowZero: true,
          )!,
    };
  }
}
