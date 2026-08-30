import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

void main() {
  test(
    'add transaction reports success after awaiting the repository',
    () async {
      final repository = _FakeTransactionRepository();
      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final transaction = AppTransaction(
        id: 'transaction-1',
        expenseNodeId: 'expense-1',
        amount: 25,
        dateTime: DateTime(2026, 8, 18),
      );

      await container
          .read(transactionMutationsProvider.notifier)
          .addTransaction(transaction);

      expect(repository.added, [transaction]);
      expect(
        container.read(transactionMutationsProvider),
        const AsyncData<void>(null),
      );
    },
  );

  test('failed transaction writes report AsyncError and rethrow', () async {
    final repository = _FakeTransactionRepository()
      ..error = StateError('offline');
    final container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    addTearDown(container.dispose);

    final transaction = AppTransaction(
      id: 'transaction-1',
      expenseNodeId: 'expense-1',
      amount: 25,
      dateTime: DateTime(2026, 8, 18),
    );

    await expectLater(
      container
          .read(transactionMutationsProvider.notifier)
          .addTransaction(transaction),
      throwsA(isA<StateError>()),
    );

    final state = container.read(transactionMutationsProvider);
    expect(state, isA<AsyncError<void>>());
    expect(state.error, isA<StateError>());
  });
}

class _FakeTransactionRepository implements TransactionRepository {
  @override
  String get userId => 'test-user';

  @override
  DateTime get currentTransactionMonth => DateTime(2026, 8);

  @override
  Future<List<DateTime>?> getIndexedTransactionMonths() async => null;

  @override
  Stream<List<TransactionMonthSummary>> watchMonthSummariesForYear(int year) =>
      const Stream.empty();

  final added = <AppTransaction>[];
  Object? error;

  @override
  Future<void> addTransaction(AppTransaction transaction) async {
    if (error != null) throw error!;
    added.add(transaction);
  }

  @override
  Future<void> updateTransaction(AppTransaction transaction) async {}

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<AppTransaction?> getOldestTransaction() async => null;

  @override
  Future<List<AppTransaction>> getCategoryTransactionsForPeriod({
    required String categoryId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async => [];

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getPagedTransactions({
    required int limit,
    QueryDocumentSnapshot<Object?>? startAfter,
    bool descending = true,
  }) async => [];

  @override
  Future<AppTransaction?> getNewestTransaction() async => null;

  @override
  Future<TransactionMonthPage> getTransactionsForMonth(DateTime month) async =>
      const TransactionMonthPage(transactions: []);
}
