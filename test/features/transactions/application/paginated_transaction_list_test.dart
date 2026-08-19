import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

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
}

class _FakeTransactionRepository implements TransactionRepository {
  @override
  String get userId => 'test-user';

  int pageRequests = 0;
  Object? error;

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
  Future<void> addTransaction(AppTransaction transaction) async {}

  @override
  Future<void> updateTransaction(AppTransaction transaction) async {}

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<AppTransaction?> getOldestTransaction() async => null;
}
