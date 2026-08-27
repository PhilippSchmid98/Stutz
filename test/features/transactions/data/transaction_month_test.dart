import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';

void main() {
  setUpAll(TransactionMonth.initialize);

  test('normalizes timestamps using Europe/Zurich month boundaries', () {
    expect(
      TransactionMonth.keyFromDateTime(DateTime.utc(2026, 1, 31, 23, 30)),
      '2026-02',
    );
    expect(
      TransactionMonth.keyFromDateTime(DateTime.utc(2026, 2, 1, 22, 30)),
      '2026-02',
    );
  });

  test('parses valid month keys and rejects invalid keys', () {
    expect(TransactionMonth.fromKey('2026-08'), DateTime(2026, 8));
    expect(() => TransactionMonth.fromKey('2026-13'), throwsFormatException);
    expect(() => TransactionMonth.fromKey('2026-8'), throwsFormatException);
  });

  test('uses the Zurich start of month for transaction query boundaries', () {
    expect(
      TransactionMonth.startOfMonth(DateTime(2026, 2)).toUtc(),
      DateTime.utc(2026, 1, 31, 23),
    );
  });
}
