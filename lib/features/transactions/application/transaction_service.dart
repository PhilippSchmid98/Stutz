import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';
import '../domain/entities/app_transaction.dart';
import '../domain/services/transaction_grouper.dart';
import '../domain/view_models/daily_transactions.dart';
import '../data/transaction_repository.dart';

part 'transaction_service.g.dart';

class PaginatedTransactionsState {
  final List<DailyTransactions> groupedDays;
  final List<AppTransaction> rawTransactions; // Beibehalten für den Grouper
  final QueryDocumentSnapshot? lastSnapshot;
  final bool hasReachedMax;

  PaginatedTransactionsState({
    required this.groupedDays,
    required this.rawTransactions,
    this.lastSnapshot,
    required this.hasReachedMax,
  });
}

@riverpod
class PaginatedTransactionList extends _$PaginatedTransactionList {
  static const _pageSize = 20;

  // Neuer Lock, um paralleles Laden beim wilden Scrollen zu verhindern
  bool _isFetchingNextPage = false;

  @override
  FutureOr<PaginatedTransactionsState> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    final flatNodes = await ref.watch(flatExpenseNodesProvider.future);

    return _fetchPage(
      repo: repo,
      flatNodes: flatNodes,
      startAfter: null,
      currentTransactions: [],
    );
  }

  Future<PaginatedTransactionsState> _fetchPage({
    required TransactionRepository repo,
    required List<ExpenseNode> flatNodes,
    required QueryDocumentSnapshot? startAfter,
    required List<AppTransaction> currentTransactions,
  }) async {
    final docs = await repo.getPagedTransactions(
      limit: _pageSize,
      startAfter: startAfter,
    );

    final newTransactions = docs
        .map((d) => AppTransaction.fromFirestore(d))
        .toList();
    final allTransactions = [...currentTransactions, ...newTransactions];

    // Nutzen den existierenden puren Domain Service zum Gruppieren
    final grouped = const TransactionGrouper().groupByDay(
      allTransactions,
      flatNodes,
    );

    return PaginatedTransactionsState(
      groupedDays: grouped,
      rawTransactions: allTransactions,
      lastSnapshot: docs.isNotEmpty ? docs.last : null,
      hasReachedMax: docs.length < _pageSize,
    );
  }

  Future<void> loadNextPage() async {
    // 1. Wenn wir schon laden oder am Ende sind -> abbrechen
    if (_isFetchingNextPage || state.value?.hasReachedMax == true) return;

    _isFetchingNextPage = true;

    try {
      final current = state.value!;
      final repo = ref.read(transactionRepositoryProvider);
      final flatNodes = await ref.watch(flatExpenseNodesProvider.future);
      final nextState = await _fetchPage(
        repo: repo,
        flatNodes: flatNodes,
        startAfter: current.lastSnapshot,
        currentTransactions: current.rawTransactions,
      );

      // 2. Zustand mit den neuen Daten updaten
      state = AsyncData(nextState);
    } catch (e, st) {
      // Bei einem Fehler werfen wir einen Error-State
      state = AsyncError(e, st);
    } finally {
      // 3. Lock am Ende wieder freigeben
      _isFetchingNextPage = false;
    }
  }
}

@riverpod
class TransactionMutations extends _$TransactionMutations {
  @override
  FutureOr<void> build() {}

  Future<void> addTransaction(AppTransaction txn) async {
    // 1. Verhindert, dass der Provider während des Speicherns abgeräumt wird
    final keepAliveLink = ref.keepAlive();

    try {
      await ref.read(transactionRepositoryProvider).addTransaction(txn);
      _refreshTransactionData();
    } finally {
      keepAliveLink.close();
    }
  }

  Future<void> updateTransaction(AppTransaction txn) async {
    // 1. Verhindert, dass der Provider während des Speicherns abgeräumt wird
    final keepAliveLink = ref.keepAlive();

    try {
      await ref.read(transactionRepositoryProvider).updateTransaction(txn);
      _refreshTransactionData();
    } finally {
      keepAliveLink.close();
    }
  }

  Future<void> deleteTransaction(String id) async {
    // 1. Verhindert, dass der Provider während des Speicherns abgeräumt wird
    final keepAliveLink = ref.keepAlive();

    try {
      await ref.read(transactionRepositoryProvider).deleteTransaction(id);
      _refreshTransactionData();
    } finally {
      keepAliveLink.close();
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
