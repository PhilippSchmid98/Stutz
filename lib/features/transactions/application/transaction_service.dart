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
  final List<AppTransaction> rawTransactions; // Beibehalten für den Grouper
  final QueryDocumentSnapshot? lastSnapshot;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final Object? loadMoreError;
  final bool isLoadingMonth;
  final Object? loadMonthError;

  PaginatedTransactionsState({
    required this.groupedDays,
    required this.rawTransactions,
    this.lastSnapshot,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.isLoadingMonth = false,
    this.loadMonthError,
  });

  PaginatedTransactionsState copyWith({
    List<DailyTransactions>? groupedDays,
    List<AppTransaction>? rawTransactions,
    QueryDocumentSnapshot? lastSnapshot,
    bool? hasReachedMax,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
    bool? isLoadingMonth,
    Object? loadMonthError,
    bool clearLoadMonthError = false,
  }) {
    return PaginatedTransactionsState(
      groupedDays: groupedDays ?? this.groupedDays,
      rawTransactions: rawTransactions ?? this.rawTransactions,
      lastSnapshot: lastSnapshot ?? this.lastSnapshot,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
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
      lastSnapshot: docs.isNotEmpty ? docs.last : null,
      hasReachedMax: docs.length < _pageSize,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null ||
        current.isLoadingMore ||
        current.isLoadingMonth ||
        current.hasReachedMax) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final categories = await ref.read(categoryLookupsProvider.future);
      final nextState = await _fetchPage(
        repo: repo,
        categories: categories,
        startAfter: current.lastSnapshot,
        currentTransactions: current.rawTransactions,
      );

      state = AsyncData(
        nextState.copyWith(isLoadingMore: false, clearLoadMoreError: true),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: e),
      );
    }
  }

  Future<bool> ensureMonthLoaded(DateTime month) async {
    final current = state.value;
    if (current == null || current.isLoadingMonth) return false;

    final normalizedMonth = DateTime(month.year, month.month);
    final isLoaded = current.groupedDays.any(
      (group) =>
          group.date.year == normalizedMonth.year &&
          group.date.month == normalizedMonth.month,
    );
    if (isLoaded) return true;

    state = AsyncData(
      current.copyWith(isLoadingMonth: true, clearLoadMonthError: true),
    );

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final categories = await ref.read(categoryLookupsProvider.future);
      final monthTransactions = await repo.getTransactionsForMonth(
        normalizedMonth,
      );
      final transactions = _mergeTransactions(
        current.rawTransactions,
        monthTransactions,
      );
      final grouped = const TransactionGrouper().groupByDay(
        transactions,
        categories,
      );

      state = AsyncData(
        current.copyWith(
          rawTransactions: transactions,
          groupedDays: grouped,
          isLoadingMonth: false,
          clearLoadMonthError: true,
        ),
      );
      return grouped.any(
        (group) =>
            group.date.year == normalizedMonth.year &&
            group.date.month == normalizedMonth.month,
      );
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
