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
    expect(summary.categoryTotalsMinor, {'groceries': 12550, 'tech': 100000});
  });

  test('ignores malformed count and category total values', () {
    final summary = TransactionMonthSummaryMapper.fromData('2026-06', {
      'transactionCount': 'three',
      'categoryTotals': {'valid': 20, 'invalid': '20', 1: 30},
    });

    expect(summary.transactionCount, 0);
    expect(summary.categoryTotalsMinor, {'valid': 2000});
  });

  test('prefers canonical integer category totals', () {
    final summary = TransactionMonthSummaryMapper.fromData('2026-06', {
      'transactionCount': 1,
      'categoryTotalsMinor': {'groceries': 1205},
      'categoryTotals': {'groceries': 99},
    });

    expect(summary.categoryTotalsMinor, {'groceries': 1205});
    expect(
      () => summary.categoryTotalsMinor['groceries'] = 1,
      throwsUnsupportedError,
    );
  });
}
