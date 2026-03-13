import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stutz/data/mappers/expense_node_mapper.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/repositories/expense_repository.dart';
import 'package:stutz/domain/services/tree_builder.dart';

class FirestoreExpenseNodeRepository implements ExpenseNodeRepository {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreExpenseNodeRepository(this.userId);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('expense_nodes');

  @override
  Future<List<ExpenseNode>> getAllExpenseNodes() async {
    final snapshot = await _collection.get();
    final flatNodes = snapshot.docs
        .map((doc) => ExpenseNodeMapper.fromFirestore(doc))
        .toList();
    return _treeBuilder.buildTree(flatNodes);
  }

  @override
  Future<void> addExpenseNode(ExpenseNode node) async {
    await _collection.doc(node.id).set(ExpenseNodeMapper.toFirestore(node));
  }

  @override
  Future<void> updateExpenseNode(ExpenseNode node) async {
    await _collection
        .doc(node.id)
        .set(ExpenseNodeMapper.toFirestore(node), SetOptions(merge: true));
  }

  @override
  Future<void> deleteExpenseNode(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> updateNodeOrder(List<ExpenseNode> sortedNodes) async {
    final batch = _firestore.batch();
    for (int i = 0; i < sortedNodes.length; i++) {
      final node = sortedNodes[i];
      batch.update(_collection.doc(node.id), {'sortOrder': i});
    }
    await batch.commit();
  }

  @override
  Stream<List<ExpenseNode>> watchAllExpenseNodes() {
    return _collection.snapshots().map((snapshot) {
      final flatNodes = snapshot.docs
          .map((doc) => ExpenseNodeMapper.fromFirestore(doc))
          .toList();
      return _treeBuilder.buildTree(flatNodes);
    });
  }

  static const _treeBuilder = TreeBuilder();
}
