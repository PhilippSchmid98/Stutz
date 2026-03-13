import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stutz/data/mappers/transaction_mapper.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/repositories/transaction_repository.dart';

class FirestoreTransactionRepository implements TransactionRepository {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreTransactionRepository(this.userId);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('transactions');

  @override
  Future<List<AppTransaction>> getAllTransactions() async {
    final snapshot = await _collection
        .orderBy('dateTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TransactionMapper.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addTransaction(AppTransaction t) async {
    await _collection.doc(t.id).set(TransactionMapper.toFirestore(t));
  }

  @override
  Future<void> updateTransaction(AppTransaction t) async {
    await _collection.doc(t.id).update(TransactionMapper.toFirestore(t));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<AppTransaction>> watchAllTransactions() {
    return _collection
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => TransactionMapper.fromFirestore(d)).toList(),
        );
  }
}
