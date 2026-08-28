import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

void main() {
  test('available months reads only indexed months after migration', () async {
    final repository = _FakeTransactionRepository()
      ..indexedMonths = [DateTime(2026, 1), DateTime(2026, 3)]
      ..currentMonth = DateTime(2026, 8);
    final container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    addTearDown(container.dispose);

    final months = await container.read(availableMonthsProvider.future);

    expect(months, [DateTime(2026, 1), DateTime(2026, 3)]);
    expect(repository.oldestTransactionCalls, 0);
  });

  test(
    'available months falls back to the legacy range before migration',
    () async {
      final repository = _FakeTransactionRepository()
        ..indexedMonths = null
        ..currentMonth = DateTime(2026, 8)
        ..oldestTransaction = AppTransaction(
          id: 'oldest',
          expenseNodeId: 'category',
          amount: 10,
          dateTime: DateTime(2026, 6, 2),
        );
      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final months = await container.read(availableMonthsProvider.future);

      expect(months, [DateTime(2026, 6), DateTime(2026, 7), DateTime(2026, 8)]);
      expect(repository.oldestTransactionCalls, 1);
    },
  );
}

class _FakeTransactionRepository implements TransactionRepository {
  @override
  String get userId => 'test-user';

  List<DateTime>? indexedMonths;
  DateTime currentMonth = DateTime(2026, 8);
  AppTransaction? oldestTransaction;
  int oldestTransactionCalls = 0;

  @override
  DateTime get currentTransactionMonth => currentMonth;

  @override
  Future<List<DateTime>?> getIndexedTransactionMonths() async => indexedMonths;

  @override
  Stream<List<TransactionMonthSummary>> watchMonthSummariesForYear(int year) =>
      const Stream.empty();

  @override
  Future<AppTransaction?> getOldestTransaction() async {
    oldestTransactionCalls++;
    return oldestTransaction;
  }

  @override
  Future<List<AppTransaction>> getCategoryTransactionsForPeriod({
    required String categoryId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async => [];

  @override
  Future<void> addTransaction(AppTransaction transaction) async {}

  @override
  Future<void> updateTransaction(AppTransaction transaction) async {}

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getPagedTransactions({
    required int limit,
    QueryDocumentSnapshot<Object?>? startAfter,
  }) async => [];

  @override
  Future<List<AppTransaction>> getTransactionsForMonth(DateTime month) async =>
      [];
}
