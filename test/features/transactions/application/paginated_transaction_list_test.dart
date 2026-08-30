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
    expect(state.rawTransactions.single.id, 'past-transaction');
    expect(state.hasReachedMax, isTrue);
    expect(state.isLoadingMonth, isFalse);
  });

  test('a selected middle month loads history in both directions', () async {
    final repository = _FakeTransactionRepository()
      ..monthTransactions = [
        AppTransaction(
          id: 'april-transaction',
          expenseNodeId: 'category',
          amount: 12,
          dateTime: DateTime(2026, 4, 15),
        ),
      ]
      ..oldestTransaction = AppTransaction(
        id: 'march-transaction',
        expenseNodeId: 'category',
        amount: 8,
        dateTime: DateTime(2026, 3, 31),
      )
      ..newestTransaction = AppTransaction(
        id: 'may-transaction',
        expenseNodeId: 'category',
        amount: 10,
        dateTime: DateTime(2026, 5, 1),
      );
    final container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWith((ref) => repository),
        categoryLookupsProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);

    await container.read(paginatedTransactionListProvider.future);
    await container
        .read(paginatedTransactionListProvider.notifier)
        .ensureMonthLoaded(DateTime(2026, 4));

    var state = container.read(paginatedTransactionListProvider).value!;
    expect(state.hasReachedNewest, isFalse);
    expect(state.hasReachedOldest, isFalse);

    await container
        .read(paginatedTransactionListProvider.notifier)
        .loadNewerPage();
    await container
        .read(paginatedTransactionListProvider.notifier)
        .loadOlderPage();

    state = container.read(paginatedTransactionListProvider).value!;
    expect(repository.pageDirections, [true, false, true]);
    expect(state.hasReachedNewest, isTrue);
    expect(state.hasReachedOldest, isTrue);
  });

  test('a month jump preloads its immediate transaction neighbors', () async {
    final repository = _FakeTransactionRepository()
      ..monthTransactionsByMonth = {
        DateTime(2026, 3): [_transaction('march', DateTime(2026, 3, 15))],
        DateTime(2026, 4): [_transaction('april', DateTime(2026, 4, 15))],
        DateTime(2026, 5): [_transaction('may', DateTime(2026, 5, 15))],
      }
      ..oldestTransaction = _transaction('march', DateTime(2026, 3, 15))
      ..newestTransaction = _transaction('may', DateTime(2026, 5, 15));
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
        .ensureMonthWindowLoaded(
          DateTime(2026, 4),
          olderMonth: DateTime(2026, 3),
          newerMonth: DateTime(2026, 5),
        );

    final state = container.read(paginatedTransactionListProvider).value!;
    expect(loaded, isTrue);
    expect(
      state.rawTransactions.map((transaction) => transaction.id),
      containsAll(['march', 'april', 'may']),
    );
    expect(state.hasReachedNewest, isTrue);
    expect(state.hasReachedOldest, isTrue);
  });
}

AppTransaction _transaction(String id, DateTime dateTime) => AppTransaction(
  id: id,
  expenseNodeId: 'category',
  amount: 1,
  dateTime: dateTime,
);

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
  final pageDirections = <bool>[];
  Object? error;
  List<AppTransaction> monthTransactions = const [];
  Map<DateTime, List<AppTransaction>> monthTransactionsByMonth = const {};
  AppTransaction? oldestTransaction;
  AppTransaction? newestTransaction;

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getPagedTransactions({
    required int limit,
    QueryDocumentSnapshot<Object?>? startAfter,
    bool descending = true,
  }) async {
    pageRequests++;
    pageDirections.add(descending);
    if (error != null) throw error!;
    return [];
  }

  @override
  Future<TransactionMonthPage> getTransactionsForMonth(DateTime month) async {
    monthRequests++;
    return TransactionMonthPage(
      transactions:
          monthTransactionsByMonth[DateTime(month.year, month.month)] ??
          monthTransactions,
    );
  }

  @override
  Future<void> addTransaction(AppTransaction transaction) async {}

  @override
  Future<void> updateTransaction(AppTransaction transaction) async {}

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<AppTransaction?> getOldestTransaction() async => oldestTransaction;

  @override
  Future<AppTransaction?> getNewestTransaction() async => newestTransaction;

  @override
  Future<List<AppTransaction>> getCategoryTransactionsForPeriod({
    required String categoryId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async => [];
}
