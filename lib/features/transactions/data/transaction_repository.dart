import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import '../domain/entities/app_transaction.dart';
import '../domain/entities/transaction_month_summary.dart';
import 'transaction_mapper.dart';
import 'transaction_month.dart';
import 'transaction_month_summary_mapper.dart';

part 'transaction_repository.g.dart';

class TransactionRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  TransactionRepository(this.userId, this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('transactions');

  CollectionReference<Map<String, dynamic>> get _monthCollection => _firestore
      .collection('users')
      .doc(userId)
      .collection('transactionMonths');

  DateTime get currentTransactionMonth => TransactionMonth.current();

  Stream<List<TransactionMonthSummary>> watchMonthSummariesForYear(int year) {
    return _monthCollection.where('year', isEqualTo: year).snapshots().map((
      snapshot,
    ) {
      final summaries = snapshot.docs
          .map(TransactionMonthSummaryMapper.fromDocument)
          .toList();
      summaries.sort((left, right) => left.month.compareTo(right.month));
      return summaries;
    });
  }

  Future<List<DateTime>?> getIndexedTransactionMonths() async {
    final migrationMarker = await _monthCollection.doc('_meta').get();
    if (migrationMarker.data()?['status'] != 'complete') return null;

    final snapshot = await _monthCollection.get();

    final months = <DateTime>[];
    for (final document in snapshot.docs) {
      final count = document.data()['transactionCount'];
      if (count is! num || count <= 0) continue;

      try {
        months.add(TransactionMonth.fromKey(document.id));
      } on FormatException {
        // Ignore malformed metadata rather than breaking transaction history.
      }
    }

    months.sort();
    return months;
  }

  /// Holt eine paginierte Liste von Dokumenten.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getPagedTransactions({
    required int limit,
    QueryDocumentSnapshot? startAfter,
  }) async {
    var query = _collection.orderBy('dateTime', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  /// Loads a calendar month directly so month navigation does not need to
  /// page through every newer transaction first.
  Future<List<AppTransaction>> getTransactionsForMonth(DateTime month) async {
    final start = TransactionMonth.startOfMonth(month);
    final end = TransactionMonth.startOfMonth(
      DateTime(month.year, month.month + 1),
    );
    final snapshot = await _collection
        .where('dateTime', isGreaterThanOrEqualTo: start)
        .where('dateTime', isLessThan: end)
        .orderBy('dateTime', descending: true)
        .get();
    return snapshot.docs.map(TransactionMapper.fromDocument).toList();
  }

  /// Holt die absolut älteste Transaktion, um das Startdatum für die Monatsliste zu kennen.
  Future<AppTransaction?> getOldestTransaction() async {
    final snapshot = await _collection
        .orderBy('dateTime', descending: false)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return TransactionMapper.fromDocument(snapshot.docs.first);
  }

  Future<List<AppTransaction>> getCategoryTransactionsForPeriod({
    required String categoryId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final snapshot = await _collection
        .where('expenseNodeId', isEqualTo: categoryId)
        .where('dateTime', isGreaterThanOrEqualTo: periodStart)
        .where('dateTime', isLessThan: periodEnd)
        .orderBy('dateTime', descending: true)
        .get();
    return snapshot.docs.map(TransactionMapper.fromDocument).toList();
  }

  Future<void> addTransaction(AppTransaction t) async {
    final transactionReference = _collection.doc(t.id);
    final month = TransactionMonth.fromDateTime(t.dateTime);
    final monthReference = _monthCollection.doc(TransactionMonth.key(month));
    final batch = _firestore.batch();

    batch.set(transactionReference, TransactionMapper.toDocument(t));
    batch.set(monthReference, {
      'monthKey': monthReference.id,
      'year': month.year,
      'month': month.month,
      'transactionCount': FieldValue.increment(1),
      'categoryTotals': {t.expenseNodeId: FieldValue.increment(t.amount)},
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> updateTransaction(AppTransaction t) async {
    await _firestore.runTransaction((transaction) async {
      final transactionReference = _collection.doc(t.id);
      final existingSnapshot = await transaction.get(transactionReference);
      if (!existingSnapshot.exists) {
        throw StateError('Transaction ${t.id} does not exist');
      }

      final existing = TransactionMapper.fromDocument(existingSnapshot);
      final oldMonth = TransactionMonth.fromDateTime(existing.dateTime);
      final newMonth = TransactionMonth.fromDateTime(t.dateTime);
      final oldMonthKey = TransactionMonth.key(oldMonth);
      final newMonthKey = TransactionMonth.key(newMonth);
      final oldMonthReference = _monthCollection.doc(oldMonthKey);
      final newMonthReference = _monthCollection.doc(newMonthKey);

      final oldMonthSnapshot = await transaction.get(oldMonthReference);
      final newMonthSnapshot = oldMonthKey == newMonthKey
          ? oldMonthSnapshot
          : await transaction.get(newMonthReference);

      transaction.update(transactionReference, TransactionMapper.toDocument(t));

      if (oldMonthKey == newMonthKey) {
        _setMonthSummary(
          transaction,
          oldMonthReference,
          oldMonthSnapshot,
          month: oldMonth,
          categoryDeltas: categoryDeltasForTransactionUpdate(existing, t),
        );
      } else {
        _setMonthSummary(
          transaction,
          oldMonthReference,
          oldMonthSnapshot,
          month: oldMonth,
          countDelta: -1,
          categoryDeltas: {existing.expenseNodeId: -existing.amount},
        );
        _setMonthSummary(
          transaction,
          newMonthReference,
          newMonthSnapshot,
          month: newMonth,
          countDelta: 1,
          categoryDeltas: {t.expenseNodeId: t.amount},
        );
      }
    });
  }

  Future<void> deleteTransaction(String id) async {
    await _firestore.runTransaction((transaction) async {
      final transactionReference = _collection.doc(id);
      final existingSnapshot = await transaction.get(transactionReference);
      if (!existingSnapshot.exists) return;

      final existing = TransactionMapper.fromDocument(existingSnapshot);
      final month = TransactionMonth.fromDateTime(existing.dateTime);
      final monthReference = _monthCollection.doc(TransactionMonth.key(month));
      final monthSnapshot = await transaction.get(monthReference);

      transaction.delete(transactionReference);
      _setMonthSummary(
        transaction,
        monthReference,
        monthSnapshot,
        month: month,
        countDelta: -1,
        categoryDeltas: {existing.expenseNodeId: -existing.amount},
      );
    });
  }

  int _monthCount(DocumentSnapshot<Map<String, dynamic>>? snapshot) {
    final value = snapshot?.data()?['transactionCount'];
    if (value is! num) return 0;
    return value.toInt().clamp(0, 1 << 31);
  }

  Map<String, double> _categoryTotals(
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
  ) {
    final rawTotals = snapshot?.data()?['categoryTotals'];
    if (rawTotals is! Map) return {};

    return {
      for (final entry in rawTotals.entries)
        if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).toDouble(),
    };
  }

  void _setMonthSummary(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> reference,
    DocumentSnapshot<Map<String, dynamic>>? snapshot, {
    required DateTime month,
    int countDelta = 0,
    required Map<String, double> categoryDeltas,
  }) {
    final categoryTotals = _categoryTotals(snapshot);
    for (final entry in categoryDeltas.entries) {
      categoryTotals.update(
        entry.key,
        (value) => value + entry.value,
        ifAbsent: () => entry.value,
      );
    }
    categoryTotals.removeWhere((_, value) => value <= 0);

    final count = (_monthCount(snapshot) + countDelta).clamp(0, 1 << 31);
    transaction.set(reference, {
      'monthKey': TransactionMonth.key(month),
      'year': month.year,
      'month': month.month,
      'transactionCount': count,
      'categoryTotals': categoryTotals,
    }, SetOptions(merge: true));
  }
}

// Der Provider lebt direkt beim Repository!
// Bridges to the not-yet-migrated Auth feature via the old presentation layer.
@riverpod
TransactionRepository transactionRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception('Not logged in (TransactionRepo)');
  return TransactionRepository(uid, FirebaseFirestore.instance);
}
