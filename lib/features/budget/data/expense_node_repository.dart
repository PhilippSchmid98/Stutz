import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/budget/data/expense_node_mapper.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/services/tree_builder.dart';

part 'expense_node_repository.g.dart';

class ExpenseNodeRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  ExpenseNodeRepository(this.userId, this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('expense_nodes');

  Stream<List<ExpenseNode>> watchAllExpenseNodes() {
    return _collection.snapshots().map((snapshot) {
      final flatNodes = snapshot.docs
          .map(ExpenseNodeMapper.fromDocument)
          .toList();
      return const TreeBuilder().buildTree(flatNodes);
    });
  }

  Future<void> addExpenseNode(ExpenseNode node) async {
    await _collection.doc(node.id).set(ExpenseNodeMapper.toDocument(node));
  }

  Future<void> updateExpenseNode(ExpenseNode node) async {
    await _collection
        .doc(node.id)
        .set(ExpenseNodeMapper.toDocument(node), SetOptions(merge: true));
  }

  Future<void> deleteExpenseNode(String id) async {
    final childSnapshot = await _collection
        .where('parentId', isEqualTo: id)
        .limit(1)
        .get();
    if (childSnapshot.docs.isNotEmpty) {
      throw StateError('Cannot delete a category that still has children');
    }

    final transactionSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('expenseNodeId', isEqualTo: id)
        .limit(1)
        .get();
    if (transactionSnapshot.docs.isNotEmpty) {
      throw StateError('Cannot delete a category referenced by transactions');
    }

    await _collection.doc(id).delete();
  }

  Future<void> updateNodeOrder(List<ExpenseNode> sortedNodes) async {
    final batch = _firestore.batch();
    for (int i = 0; i < sortedNodes.length; i++) {
      batch.update(_collection.doc(sortedNodes[i].id), {'sortOrder': i});
    }
    await batch.commit();
  }
}

@riverpod
ExpenseNodeRepository expenseNodeRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception('Not logged in (ExpenseNodeRepo)');
  return ExpenseNodeRepository(uid, FirebaseFirestore.instance);
}
