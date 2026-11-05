import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

void main() {
  const userId = 'user-1';

  AppTransaction transaction({int amountMinor = 2500}) {
    return AppTransaction(
      id: 'transaction-1',
      expenseNodeId: 'groceries',
      amountMinor: amountMinor,
      dateTime: DateTime(2026, 10, 13),
      note: 'Weekly groceries',
    );
  }

  Future<Map<String, dynamic>> monthData(FakeFirebaseFirestore firestore) {
    final month = TransactionMonth.key(DateTime(2026, 10));
    return firestore
        .collection('users')
        .doc(userId)
        .collection('transactionMonths')
        .doc(month)
        .get()
        .then((snapshot) => snapshot.data()!);
  }

  test('a replay with the same ID and payload is a no-op', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = TransactionRepository(userId, firestore);
    final value = transaction();

    await repository.addTransaction(value);
    await repository.addTransaction(value);

    final transactions = await firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();
    final summary = await monthData(firestore);

    expect(transactions.docs, hasLength(1));
    expect(summary['transactionCount'], 1);
    expect(summary['categoryTotalsMinor'], {'groceries': 2500});
  });

  test('a replay with a different payload rejects the ID collision', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = TransactionRepository(userId, firestore);

    await repository.addTransaction(transaction());

    await expectLater(
      repository.addTransaction(transaction(amountMinor: 3000)),
      throwsA(isA<StateError>()),
    );

    final stored = await firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc('transaction-1')
        .get();
    final summary = await monthData(firestore);

    expect(stored.data()!['amountMinor'], 2500);
    expect(summary['transactionCount'], 1);
    expect(summary['categoryTotalsMinor'], {'groceries': 2500});
  });

  test(
    'period streams include the cutoff and react to transaction changes',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = TransactionRepository(userId, firestore);
      final start = TransactionMonth.startOfMonth(DateTime(2024, 7));
      final end = TransactionMonth.startOfDay(DateTime(2024, 7, 2));
      final before = AppTransaction(
        id: 'before',
        expenseNodeId: 'groceries',
        amountMinor: 100,
        dateTime: DateTime.utc(2024, 7, 1, 21, 59),
      );
      final after = before.copyWith(
        id: 'after',
        dateTime: DateTime.utc(2024, 7, 1, 22),
      );
      await repository.addTransaction(before);
      await repository.addTransaction(after);
      final iterator = StreamIterator(
        repository.watchTransactionsForPeriod(
          periodStart: start,
          periodEnd: end,
        ),
      );
      addTearDown(iterator.cancel);
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current.map((item) => item.id), ['before']);

      await repository.updateTransaction(before.copyWith(amountMinor: 250));
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current.single.amountMinor, 250);

      final category = await repository
          .watchCategoryTransactionsForPeriod(
            categoryId: 'groceries',
            periodStart: start,
            periodEnd: end,
          )
          .first;
      expect(category.map((item) => item.id), ['before']);
    },
  );
}
