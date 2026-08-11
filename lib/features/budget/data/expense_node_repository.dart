import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/services/tree_builder.dart';

part 'expense_node_repository.g.dart';

class ExpenseNodeRepository {
  final String userId;
  final FirebaseFirestore _firestore;
  final TreeBuilder _treeBuilder;

  ExpenseNodeRepository(
    this.userId,
    this._firestore, {
    TreeBuilder treeBuilder = const TreeBuilder(),
  }) : _treeBuilder = treeBuilder;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('expense_nodes');

  Future<List<ExpenseNode>> getAllExpenseNodes() async {
    final snapshot = await _collection.get();
    final flatNodes = snapshot.docs
        .map((doc) => ExpenseNode.fromFirestore(doc))
        .toList();
    return _treeBuilder.buildTree(flatNodes);
  }

  Stream<List<ExpenseNode>> watchAllExpenseNodes() {
    return _collection.snapshots().map((snapshot) {
      final flatNodes = snapshot.docs
          .map((doc) => ExpenseNode.fromFirestore(doc))
          .toList();
      return _treeBuilder.buildTree(flatNodes);
    });
  }

  Future<void> addExpenseNode(ExpenseNode node) async {
    await _collection.doc(node.id).set(node.toFirestore());
  }

  Future<void> updateExpenseNode(ExpenseNode node) async {
    await _collection
        .doc(node.id)
        .set(node.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteExpenseNode(String id) async {
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

/// Bridges to the not-yet-migrated Auth feature via the old presentation layer.
@riverpod
ExpenseNodeRepository expenseNodeRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception('Not logged in (ExpenseNodeRepo)');
  return ExpenseNodeRepository(uid, FirebaseFirestore.instance);
}
