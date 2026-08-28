import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

void main() {
  test('initial empty results reach the end and do not fetch again', () async {
    final repository = _FakeTransactionRepository();
    final container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWith((ref) => repository),
        categoryLookupsProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(paginatedTransactionListProvider.future);
    await container
        .read(paginatedTransactionListProvider.notifier)
        .loadNextPage();

    expect(state.rawTransactions, isEmpty);
    expect(state.groupedDays, isEmpty);
    expect(state.hasReachedMax, isTrue);
    expect(repository.pageRequests, 1);
  });

  test('initial repository failure becomes provider error', () async {
    final repository = _FakeTransactionRepository()
      ..error = StateError('offline');
    final container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWith((ref) => repository),
        categoryLookupsProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(paginatedTransactionListProvider.future),
      throwsA(isA<StateError>()),
    );

    expect(
      container.read(paginatedTransactionListProvider),
      isA<AsyncError<PaginatedTransactionsState>>(),
    );
  });

  test(
    'ensureMonthLoaded returns false when history has no more pages',
    () async {
      final repository = _FakeTransactionRepository();
      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWith((ref) => repository),
          categoryLookupsProvider.overrideWith((ref) async => const []),
        ],
      );
      addTearDown(container.dispose);

      await container.read(paginatedTransactionListProvider.future);
      final loaded = await container
          .read(paginatedTransactionListProvider.notifier)
          .ensureMonthLoaded(DateTime(2024, 1));

      expect(loaded, isFalse);
      expect(repository.pageRequests, 1);
    },
  );

  test('ensureMonthLoaded fetches an unloaded month directly', () async {
    final repository = _FakeTransactionRepository()
      ..monthTransactions = [
        AppTransaction(
          id: 'past-transaction',
          expenseNodeId: 'category',
          amount: 12,
          dateTime: DateTime(2024, 1, 15),
        ),
      ];
    final container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWith((ref) => repository),
        categoryLookupsProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);

    await container.read(paginatedTransactionListProvider.future);
    final loaded = await container
        .read(paginatedTransactionListProvider.notifier)
        .ensureMonthLoaded(DateTime(2024, 1));

    final state = container.read(paginatedTransactionListProvider).value!;
    expect(loaded, isTrue);
    expect(repository.pageRequests, 1);
    expect(repository.monthRequests, 1);
    expect(state.groupedDays.single.date, DateTime(2024, 1, 15));
    expect(state.isLoadingMonth, isFalse);
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

  int pageRequests = 0;
  int monthRequests = 0;
  Object? error;
  List<AppTransaction> monthTransactions = const [];

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getPagedTransactions({
    required int limit,
    QueryDocumentSnapshot<Object?>? startAfter,
  }) async {
    pageRequests++;
    if (error != null) throw error!;
    return [];
  }

  @override
  Future<List<AppTransaction>> getTransactionsForMonth(DateTime month) async {
    monthRequests++;
    return monthTransactions;
  }

  @override
  Future<void> addTransaction(AppTransaction transaction) async {}

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
}
