import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import '../domain/entities/app_transaction.dart';
import 'transaction_mapper.dart';
import 'transaction_month.dart';

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

  /// Holt die absolut älteste Transaktion, um das Startdatum für die Monatsliste zu kennen.
  Future<AppTransaction?> getOldestTransaction() async {
    final snapshot = await _collection
        .orderBy('dateTime', descending: false)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return TransactionMapper.fromDocument(snapshot.docs.first);
  }

  Future<void> addTransaction(AppTransaction t) async {
    final transactionReference = _collection.doc(t.id);
    final monthReference = _monthCollection.doc(
      TransactionMonth.keyFromDateTime(t.dateTime),
    );
    final batch = _firestore.batch();

    batch.set(transactionReference, TransactionMapper.toDocument(t));
    batch.set(monthReference, {
      'monthKey': monthReference.id,
      'transactionCount': FieldValue.increment(1),
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
      final oldMonthKey = TransactionMonth.keyFromDateTime(existing.dateTime);
      final newMonthKey = TransactionMonth.keyFromDateTime(t.dateTime);

      DocumentSnapshot<Map<String, dynamic>>? oldMonthSnapshot;
      DocumentSnapshot<Map<String, dynamic>>? newMonthSnapshot;
      if (oldMonthKey != newMonthKey) {
        oldMonthSnapshot = await transaction.get(
          _monthCollection.doc(oldMonthKey),
        );
        newMonthSnapshot = await transaction.get(
          _monthCollection.doc(newMonthKey),
        );
      }

      transaction.update(transactionReference, TransactionMapper.toDocument(t));

      if (oldMonthKey != newMonthKey) {
        _setMonthCount(
          transaction,
          _monthCollection.doc(oldMonthKey),
          _monthCount(oldMonthSnapshot) - 1,
          oldMonthKey,
        );
        _setMonthCount(
          transaction,
          _monthCollection.doc(newMonthKey),
          _monthCount(newMonthSnapshot) + 1,
          newMonthKey,
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
      final monthKey = TransactionMonth.keyFromDateTime(existing.dateTime);
      final monthReference = _monthCollection.doc(monthKey);
      final monthSnapshot = await transaction.get(monthReference);

      transaction.delete(transactionReference);
      _setMonthCount(
        transaction,
        monthReference,
        _monthCount(monthSnapshot) - 1,
        monthKey,
      );
    });
  }

  int _monthCount(DocumentSnapshot<Map<String, dynamic>>? snapshot) {
    final value = snapshot?.data()?['transactionCount'];
    if (value is! num) return 0;
    return value.toInt().clamp(0, 1 << 31);
  }

  void _setMonthCount(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> reference,
    int count,
    String monthKey,
  ) {
    transaction.set(reference, {
      'monthKey': monthKey,
      'transactionCount': count < 0 ? 0 : count,
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
