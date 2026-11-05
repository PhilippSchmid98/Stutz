import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

void main() {
  test(
    'removes the old category after recategorizing its final monthly transaction',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = TransactionRepository('user-1', firestore);
      final first = AppTransaction(
        id: 'wellness-1',
        expenseNodeId: 'wellness',
        amountMinor: 12000,
        dateTime: DateTime(2026, 6, 10),
      );
      final last = AppTransaction(
        id: 'wellness-2',
        expenseNodeId: 'wellness',
        amountMinor: 28000,
        dateTime: DateTime(2026, 6, 20),
      );

      await repository.addTransaction(first);
      await repository.addTransaction(last);
      await repository.updateTransaction(
        first.copyWith(expenseNodeId: 'leisure'),
      );
      await repository.updateTransaction(
        last.copyWith(expenseNodeId: 'leisure'),
      );

      final summary = await firestore
          .collection('users')
          .doc('user-1')
          .collection('transactionMonths')
          .doc('2026-06')
          .get();
      expect(summary.data()!['categoryTotalsMinor'], {'leisure': 40000});
    },
  );
}
