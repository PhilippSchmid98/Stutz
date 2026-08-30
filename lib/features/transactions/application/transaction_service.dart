import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/budget/domain/view_models/category_lookup.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';
import '../domain/entities/app_transaction.dart';
import '../domain/services/transaction_grouper.dart';
import '../domain/view_models/daily_transactions.dart';
import '../data/transaction_repository.dart';
import '../data/transaction_mapper.dart';

part 'transaction_service.g.dart';

class PaginatedTransactionsState {
  final List<DailyTransactions> groupedDays;
  final List<AppTransaction> rawTransactions;
  final QueryDocumentSnapshot? newestSnapshot;
  final QueryDocumentSnapshot? oldestSnapshot;
  final bool hasReachedNewest;
  final bool hasReachedOldest;
  final bool isLoadingNewer;
  final bool isLoadingOlder;
  final Object? loadNewerError;
  final Object? loadOlderError;
  final bool isLoadingMonth;
  final Object? loadMonthError;

  PaginatedTransactionsState({
    required this.groupedDays,
    required this.rawTransactions,
    this.newestSnapshot,
    this.oldestSnapshot,
    bool? hasReachedNewest,
    bool? hasReachedOldest,
    bool? hasReachedMax,
    bool? isLoadingNewer,
    bool? isLoadingOlder,
    bool? isLoadingMore,
    this.loadNewerError,
    Object? loadOlderError,
    Object? loadMoreError,
    this.isLoadingMonth = false,
    this.loadMonthError,
  }) : hasReachedNewest = hasReachedNewest ?? false,
       hasReachedOldest = hasReachedOldest ?? hasReachedMax ?? false,
       isLoadingNewer = isLoadingNewer ?? false,
       isLoadingOlder = isLoadingOlder ?? isLoadingMore ?? false,
       loadOlderError = loadOlderError ?? loadMoreError;

  QueryDocumentSnapshot? get lastSnapshot => oldestSnapshot;
  bool get hasReachedMax => hasReachedOldest;
  bool get isLoadingMore => isLoadingOlder;
  Object? get loadMoreError => loadOlderError;

  PaginatedTransactionsState copyWith({
    List<DailyTransactions>? groupedDays,
    List<AppTransaction>? rawTransactions,
    QueryDocumentSnapshot? newestSnapshot,
    QueryDocumentSnapshot? oldestSnapshot,
    bool? hasReachedNewest,
    bool? hasReachedOldest,
    bool? isLoadingNewer,
    bool? isLoadingOlder,
    bool? isLoadingMore,
    Object? loadNewerError,
    bool clearLoadNewerError = false,
    Object? loadOlderError,
    Object? loadMoreError,
    bool clearLoadOlderError = false,
    bool clearLoadMoreError = false,
    bool? isLoadingMonth,
    Object? loadMonthError,
    bool clearLoadMonthError = false,
  }) {
    return PaginatedTransactionsState(
      groupedDays: groupedDays ?? this.groupedDays,
      rawTransactions: rawTransactions ?? this.rawTransactions,
      newestSnapshot: newestSnapshot ?? this.newestSnapshot,
      oldestSnapshot: oldestSnapshot ?? this.oldestSnapshot,
      hasReachedNewest: hasReachedNewest ?? this.hasReachedNewest,
      hasReachedOldest: hasReachedOldest ?? this.hasReachedOldest,
      isLoadingNewer: isLoadingNewer ?? this.isLoadingNewer,
      isLoadingOlder: isLoadingOlder ?? isLoadingMore ?? this.isLoadingOlder,
      loadNewerError: clearLoadNewerError
          ? null
          : loadNewerError ?? this.loadNewerError,
      loadOlderError: clearLoadOlderError || clearLoadMoreError
          ? null
          : loadOlderError ?? loadMoreError ?? this.loadOlderError,
      isLoadingMonth: isLoadingMonth ?? this.isLoadingMonth,
      loadMonthError: clearLoadMonthError
          ? null
          : loadMonthError ?? this.loadMonthError,
    );
  }
}

@riverpod
class PaginatedTransactionList extends _$PaginatedTransactionList {
  static const _pageSize = 20;

  @override
  FutureOr<PaginatedTransactionsState> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    final categories = await ref.watch(categoryLookupsProvider.future);

    return _fetchPage(
      repo: repo,
      categories: categories,
      startAfter: null,
      currentTransactions: [],
    );
  }

  Future<PaginatedTransactionsState> _fetchPage({
    required TransactionRepository repo,
    required List<CategoryLookup> categories,
    required QueryDocumentSnapshot? startAfter,
    required List<AppTransaction> currentTransactions,
  }) async {
    final docs = await repo.getPagedTransactions(
      limit: _pageSize,
      startAfter: startAfter,
    );

    final newTransactions = docs.map(TransactionMapper.fromDocument).toList();
    final allTransactions = _mergeTransactions(
      currentTransactions,
      newTransactions,
    );

    // Nutzen den existierenden puren Domain Service zum Gruppieren
    final grouped = const TransactionGrouper().groupByDay(
      allTransactions,
      categories,
    );

    return PaginatedTransactionsState(
      groupedDays: grouped,
      rawTransactions: allTransactions,
      newestSnapshot: docs.isEmpty ? null : docs.first,
      oldestSnapshot: docs.isEmpty ? null : docs.last,
      hasReachedNewest: true,
      hasReachedOldest: docs.length < _pageSize,
    );
  }

  Future<void> loadOlderPage() async {
    final current = state.value;
    if (current == null ||
        current.isLoadingOlder ||
        current.isLoadingNewer ||
        current.isLoadingMonth ||
        current.hasReachedOldest) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingOlder: true, clearLoadOlderError: true),
    );

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final categories = await ref.read(categoryLookupsProvider.future);
      final docs = await repo.getPagedTransactions(
        limit: _pageSize,
        startAfter: current.lastSnapshot,
      );
      final transactions = _mergeTransactions(
        current.rawTransactions,
        docs.map(TransactionMapper.fromDocument).toList(),
      );

      state = AsyncData(
        current.copyWith(
          rawTransactions: transactions,
          groupedDays: _groupTransactions(transactions, categories),
          oldestSnapshot: docs.isEmpty ? null : docs.last,
          hasReachedOldest: docs.length < _pageSize,
          isLoadingOlder: false,
          clearLoadOlderError: true,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(isLoadingOlder: false, loadOlderError: e),
      );
    }
  }

  Future<void> loadNextPage() => loadOlderPage();

  Future<void> loadNewerPage() async {
    final current = state.value;
    if (current == null ||
        current.isLoadingNewer ||
        current.isLoadingOlder ||
        current.isLoadingMonth ||
        current.hasReachedNewest) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingNewer: true, clearLoadNewerError: true),
    );

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final categories = await ref.read(categoryLookupsProvider.future);
      final docs = await repo.getPagedTransactions(
        limit: _pageSize,
        startAfter: current.newestSnapshot,
        descending: false,
      );
      final transactions = _mergeTransactions(
        current.rawTransactions,
        docs.map(TransactionMapper.fromDocument).toList(),
      );

      state = AsyncData(
        current.copyWith(
          rawTransactions: transactions,
          groupedDays: _groupTransactions(transactions, categories),
          newestSnapshot: docs.isEmpty ? null : docs.last,
          hasReachedNewest: docs.length < _pageSize,
          isLoadingNewer: false,
          clearLoadNewerError: true,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(isLoadingNewer: false, loadNewerError: e),
      );
    }
  }

  Future<bool> ensureMonthLoaded(DateTime month) async {
    return ensureMonthWindowLoaded(month);
  }

  Future<bool> ensureMonthWindowLoaded(
    DateTime month, {
    DateTime? olderMonth,
    DateTime? newerMonth,
  }) async {
    final current = state.value;
    if (current == null || current.isLoadingMonth) return false;

    final normalizedMonth = DateTime(month.year, month.month);
    state = AsyncData(
      current.copyWith(isLoadingMonth: true, clearLoadMonthError: true),
    );

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final categories = await ref.read(categoryLookupsProvider.future);
      final monthsToLoad = <DateTime>{
        normalizedMonth,
        if (olderMonth != null) DateTime(olderMonth.year, olderMonth.month),
        if (newerMonth != null) DateTime(newerMonth.year, newerMonth.month),
      };
      final monthPages = await Future.wait(
        monthsToLoad.map(repo.getTransactionsForMonth),
      );
      final oldestTransaction = await repo.getOldestTransaction();
      final newestTransaction = await repo.getNewestTransaction();
      final transactions = _mergeTransactions(
        const [],
        monthPages.expand((page) => page.transactions).toList(),
      );
      final grouped = _groupTransactions(transactions, categories);
      final hasReachedOldest =
          transactions.isEmpty ||
          oldestTransaction == null ||
          transactions.any(
            (transaction) => transaction.id == oldestTransaction.id,
          );
      final hasReachedNewest =
          transactions.isEmpty ||
          newestTransaction == null ||
          transactions.any(
            (transaction) => transaction.id == newestTransaction.id,
          );
      final newestPage = _findBoundaryPage(monthPages, newest: true);
      final oldestPage = _findBoundaryPage(monthPages, newest: false);

      state = AsyncData(
        PaginatedTransactionsState(
          rawTransactions: transactions,
          groupedDays: grouped,
          newestSnapshot: newestPage?.newestSnapshot,
          oldestSnapshot: oldestPage?.oldestSnapshot,
          hasReachedNewest: hasReachedNewest,
          hasReachedOldest: hasReachedOldest,
          isLoadingMonth: false,
        ),
      );
      return transactions.isNotEmpty;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isLoadingMonth: false, loadMonthError: error),
      );
      return false;
    }
  }

  List<AppTransaction> _mergeTransactions(
    List<AppTransaction> current,
    List<AppTransaction> additional,
  ) {
    final transactionsById = <String, AppTransaction>{
      for (final transaction in current) transaction.id: transaction,
    };
    for (final transaction in additional) {
      transactionsById[transaction.id] = transaction;
    }
    return transactionsById.values.toList();
  }

  List<DailyTransactions> _groupTransactions(
    List<AppTransaction> transactions,
    List<CategoryLookup> categories,
  ) => const TransactionGrouper().groupByDay(transactions, categories);

  TransactionMonthPage? _findBoundaryPage(
    List<TransactionMonthPage> pages, {
    required bool newest,
  }) {
    final populatedPages = pages.where((page) => page.transactions.isNotEmpty);
    if (populatedPages.isEmpty) return null;

    return populatedPages.reduce((current, candidate) {
      final currentDate = newest
          ? current.transactions.first.dateTime
          : current.transactions.last.dateTime;
      final candidateDate = newest
          ? candidate.transactions.first.dateTime
          : candidate.transactions.last.dateTime;
      final isCandidateBoundary = newest
          ? candidateDate.isAfter(currentDate)
          : candidateDate.isBefore(currentDate);
      return isCandidateBoundary ? candidate : current;
    });
  }
}

@riverpod
class TransactionMutations extends _$TransactionMutations {
  @override
  FutureOr<void> build() {}

  Future<void> addTransaction(AppTransaction txn) async {
    state = const AsyncLoading();
    try {
      await ref.read(transactionRepositoryProvider).addTransaction(txn);
      _refreshTransactionData();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateTransaction(AppTransaction txn) async {
    state = const AsyncLoading();
    try {
      await ref.read(transactionRepositoryProvider).updateTransaction(txn);
      _refreshTransactionData();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(transactionRepositoryProvider).deleteTransaction(id);
      _refreshTransactionData();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Hilfsmethode: Invalidiert die Provider, damit die UI die neuesten Daten
  /// von der ersten Seite an neu lädt und auch die Monatsliste aktualisiert wird.
  void _refreshTransactionData() {
    ref.invalidate(paginatedTransactionListProvider);
    // Falls das Auth-Feature oder der availableMonthsProvider gecacht ist,
    // zwingen wir ihn hier ebenfalls zum Neukauf, damit neue Monate direkt auftauchen:
    ref.invalidate(availableMonthsProvider);
  }
}
