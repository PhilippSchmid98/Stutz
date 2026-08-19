import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/data/income_source_mapper.dart';

part 'income_source_repository.g.dart';

class IncomeSourceRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  IncomeSourceRepository(this.userId, this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('incomes');

  Future<List<IncomeSource>> getAllIncomeSources() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map(IncomeSourceMapper.fromDocument).toList();
  }

  Stream<List<IncomeSource>> watchAllIncomeSources() {
    return _collection.snapshots().map(
      (s) => s.docs.map(IncomeSourceMapper.fromDocument).toList(),
    );
  }

  Future<void> addIncomeSource(IncomeSource source) async {
    await _collection.doc(source.id).set(IncomeSourceMapper.toDocument(source));
  }

  Future<void> updateIncomeSource(IncomeSource source) async {
    await _collection
        .doc(source.id)
        .update(IncomeSourceMapper.toDocument(source));
  }

  Future<void> deleteIncomeSource(String id) async {
    await _collection.doc(id).delete();
  }
}

/// Bridges to the not-yet-migrated Auth feature via the old presentation layer.
@riverpod
IncomeSourceRepository incomeSourceRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception('Not logged in (IncomeSourceRepo)');
  return IncomeSourceRepository(uid, FirebaseFirestore.instance);
}
