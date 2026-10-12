import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/transactions/data/transaction_mapper.dart';

void main() {
  test('transaction mapper converts timestamp data without mutating input', () {
    final timestamp = Timestamp.fromDate(DateTime(2026, 8, 17, 12));
    final data = <String, dynamic>{
      'expenseNodeId': 'node-1',
      'amount': 42.5,
      'dateTime': timestamp,
      'note': 'Lunch',
    };

    final transaction = TransactionMapper.fromData('transaction-1', data);

    expect(transaction.id, 'transaction-1');
    expect(transaction.expenseNodeId, 'node-1');
    expect(transaction.amountMinor, 4250);
    expect(transaction.dateTime, timestamp.toDate());
    expect(data.containsKey('id'), isFalse);

    final document = TransactionMapper.toDocument(transaction);
    expect(document['dateTime'], timestamp);
    expect(document['amountMinor'], 4250);
    expect(document.containsKey('amount'), isFalse);
    expect(document.containsKey('id'), isFalse);
  });

  test('transaction mapper prefers canonical integer minor units', () {
    final transaction = TransactionMapper.fromData('transaction-1', {
      'expenseNodeId': 'node-1',
      'amountMinor': 1205,
      'amount': 99,
      'dateTime': Timestamp.now(),
    });

    expect(transaction.amountMinor, 1205);
  });

  test('transaction mapper rejects malformed data', () {
    expect(
      () => TransactionMapper.fromData('transaction-1', {
        'expenseNodeId': 'node-1',
        'amount': 10,
        'dateTime': 'invalid-date',
      }),
      throwsFormatException,
    );

    expect(
      () => TransactionMapper.fromData('transaction-1', {
        'expenseNodeId': '',
        'amount': 10,
        'dateTime': Timestamp.now(),
      }),
      throwsFormatException,
    );
  });
}
