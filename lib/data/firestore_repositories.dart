import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/repositories.dart';

part 'firestore_repositories.g.dart';

@riverpod
String? currentUserId(Ref ref) {
  return FirebaseAuth.instance.currentUser?.uid;
}

// -----------------------------------------------------------------------------
// TRANSACTION REPOSITORY
// -----------------------------------------------------------------------------
class FirestoreTransactionRepository implements TransactionRepository {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreTransactionRepository(this.userId);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('transactions');

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final snapshot = await _collection
        .orderBy('dateTime', descending: true)
        .get();
    return snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addTransaction(Transaction t) async {
    // Use .set(t.id) to retain the ID (UUID) generated in the UI
    await _collection.doc(t.id).set(t.toFirestore());
  }

  @override
  Future<void> updateTransaction(Transaction t) async {
    await _collection.doc(t.id).update(t.toFirestore());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<Transaction>> watchAllTransactions() {
    return _collection.orderBy('dateTime', descending: true).snapshots().map((
      s,
    ) {
      return s.docs.map((d) => Transaction.fromFirestore(d)).toList();
    });
  }
}

// -----------------------------------------------------------------------------
// EXPENSE NODE REPOSITORY (Budget Tree)
// -----------------------------------------------------------------------------
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
        .map((doc) => ExpenseNode.fromFirestore(doc))
        .toList();
    // Firestore returns flat data -> Build the tree structure
    return _buildTree(flatNodes);
  }

  @override
  Future<void> addExpenseNode(ExpenseNode node) async {
    await _collection.doc(node.id).set(node.toFirestore());
  }

  @override
  Future<void> updateExpenseNode(ExpenseNode node) async {
    // merge: true prevents deletion of fields not sent here
    await _collection
        .doc(node.id)
        .set(node.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteExpenseNode(String id) async {
    // Perform a "Hard Delete". Note: Children and transactions may reference this node (orphans).
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<ExpenseNode>> watchAllExpenseNodes() {
    return _collection.snapshots().map((snapshot) {
      final flatNodes = snapshot.docs
          .map((doc) => ExpenseNode.fromFirestore(doc))
          .toList();
      return _buildTree(flatNodes);
    });
  }

  // Internal logic: Build tree structure from flat nodes
  List<ExpenseNode> _buildTree(List<ExpenseNode> flatNodes) {
    // 1. Group children by parent ID
    Map<String, List<ExpenseNode>> childrenMap = {};
    for (var node in flatNodes) {
      if (node.parentId != null) {
        childrenMap.putIfAbsent(node.parentId!, () => []).add(node);
      }
    }

    // 2. Recursive function to attach children
    ExpenseNode attachChildren(ExpenseNode parent) {
      final children = childrenMap[parent.id] ?? [];

      return ExpenseNode(
        id: parent.id,
        parentId: parent.parentId,
        name: parent.name,
        plannedAmount: parent.plannedAmount,
        interval: parent.interval,
        type: parent.type,
        // Recursion here:
        children: children.map((c) => attachChildren(c)).toList(),
      );
    }

    // 3. Return only root nodes (those without a parent)
    return flatNodes
        .where((n) => n.parentId == null)
        .map((root) => attachChildren(root))
        .toList();
  }
}

// -----------------------------------------------------------------------------
// INCOME SOURCE REPOSITORY
// -----------------------------------------------------------------------------
class FirestoreIncomeRepository implements IncomeSourceRepository {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreIncomeRepository(this.userId);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('incomes');

  @override
  Future<List<IncomeSource>> getAllIncomeSources() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => IncomeSource.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addIncomeSource(IncomeSource source) async {
    await _collection.doc(source.id).set(source.toFirestore());
  }

  @override
  Future<void> updateIncomeSource(IncomeSource source) async {
    await _collection.doc(source.id).update(source.toFirestore());
  }

  @override
  Future<void> deleteIncomeSource(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<IncomeSource>> watchAllIncomeSources() {
    return _collection.snapshots().map((s) {
      return s.docs.map((d) => IncomeSource.fromFirestore(d)).toList();
    });
  }
}

// -----------------------------------------------------------------------------
// RIVERPOD PROVIDERS
// -----------------------------------------------------------------------------

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception("Not logged in (TransactionRepo)");
  return FirestoreTransactionRepository(uid);
}

@riverpod
ExpenseNodeRepository expenseNodeRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception("Not logged in (ExpenseRepo)");
  return FirestoreExpenseNodeRepository(uid);
}

@riverpod
IncomeSourceRepository incomeSourceRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception("Not logged in (IncomeRepo)");
  return FirestoreIncomeRepository(uid);
}
