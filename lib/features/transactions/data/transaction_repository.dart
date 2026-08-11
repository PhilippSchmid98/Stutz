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

  Future<List<AppTransaction>> getAllTransactions() async {
    final snapshot = await _collection
        .orderBy('dateTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AppTransaction.fromFirestore(doc))
        .toList();
  }

  Stream<List<AppTransaction>> watchAllTransactions() {
    return _collection
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => AppTransaction.fromFirestore(d)).toList(),
        );
  }

  Future<void> addTransaction(AppTransaction t) async {
    await _collection.doc(t.id).set(t.toFirestore());
  }

  Future<void> updateTransaction(AppTransaction t) async {
    await _collection.doc(t.id).update(t.toFirestore());
  }

  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
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
