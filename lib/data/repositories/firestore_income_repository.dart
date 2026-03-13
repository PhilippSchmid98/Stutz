import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stutz/data/mappers/income_mapper.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/repositories/income_repository.dart';

class FirestoreIncomeRepository implements IncomeSourceRepository {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreIncomeRepository(this.userId);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('incomes');

  @override
  Future<List<IncomeSource>> getAllIncomeSources() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => IncomeMapper.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addIncomeSource(IncomeSource source) async {
    await _collection.doc(source.id).set(IncomeMapper.toFirestore(source));
  }

  @override
  Future<void> updateIncomeSource(IncomeSource source) async {
    await _collection.doc(source.id).update(IncomeMapper.toFirestore(source));
  }

  @override
  Future<void> deleteIncomeSource(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<IncomeSource>> watchAllIncomeSources() {
    return _collection.snapshots().map(
      (s) => s.docs.map((d) => IncomeMapper.fromFirestore(d)).toList(),
    );
  }
}
