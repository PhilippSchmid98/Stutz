import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import '../domain/entities/app_transaction.dart';

part 'transaction_repository.g.dart';

class TransactionRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  TransactionRepository(this.userId, this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('transactions');

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
    return AppTransaction.fromFirestore(snapshot.docs.first);
  }

  Future<void> addTransaction(AppTransaction t) async =>
      await _collection.doc(t.id).set(t.toFirestore());
  Future<void> updateTransaction(AppTransaction t) async =>
      await _collection.doc(t.id).update(t.toFirestore());
  Future<void> deleteTransaction(String id) async =>
      await _collection.doc(id).delete();
}

// Der Provider lebt direkt beim Repository!
// Bridges to the not-yet-migrated Auth feature via the old presentation layer.
@riverpod
TransactionRepository transactionRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception('Not logged in (TransactionRepo)');
  return TransactionRepository(uid, FirebaseFirestore.instance);
}
