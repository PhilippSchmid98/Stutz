import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/transactions/data/transaction_month_summary_mapper.dart';

void main() {
  test('maps indexed category totals into a typed month summary', () {
    final summary = TransactionMonthSummaryMapper.fromData('2026-06', {
      'transactionCount': 3,
      'categoryTotals': {'groceries': 125.5, 'tech': 1000},
    });

    expect(summary.month, DateTime(2026, 6));
    expect(summary.transactionCount, 3);
    expect(summary.categoryTotals, {'groceries': 125.5, 'tech': 1000.0});
  });

  test('ignores malformed count and category total values', () {
    final summary = TransactionMonthSummaryMapper.fromData('2026-06', {
      'transactionCount': 'three',
      'categoryTotals': {'valid': 20, 'invalid': '20', 1: 30},
    });

    expect(summary.transactionCount, 0);
    expect(summary.categoryTotals, {'valid': 20.0});
  });
}
