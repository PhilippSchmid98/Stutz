import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/domain/repositories.dart';

part 'firestore_repositories.g.dart';

// Hilfs-Provider für die UserID
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

  // --- STANDARD METHODEN (Kompatibel mit deinem alten Code) ---

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final snapshot = await _collection
        .orderBy('dateTime', descending: true)
        .get();
    return snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addTransaction(Transaction t) async {
    // Wir nutzen .set(t.id), damit wir die ID (UUID) behalten, die wir im UI generiert haben
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

  // --- NEUE FEATURES (Live Updates) ---

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
// EXPENSE NODE REPOSITORY (Budget-Baum)
// -----------------------------------------------------------------------------
class FirestoreExpenseNodeRepository implements ExpenseNodeRepository {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreExpenseNodeRepository(this.userId);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('expense_nodes');

  // --- STANDARD METHODEN ---

  @override
  Future<List<ExpenseNode>> getAllExpenseNodes() async {
    final snapshot = await _collection.get();
    final flatNodes = snapshot.docs
        .map((doc) => ExpenseNode.fromFirestore(doc))
        .toList();
    // Wichtig: Firestore liefert flach -> Wir müssen den Baum bauen
    return _buildTree(flatNodes);
  }

  @override
  Future<void> addExpenseNode(ExpenseNode node) async {
    await _collection.doc(node.id).set(node.toFirestore());
  }

  @override
  Future<void> updateExpenseNode(ExpenseNode node) async {
    // merge: true verhindert, dass Felder gelöscht werden, die wir hier nicht senden
    await _collection
        .doc(node.id)
        .set(node.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteExpenseNode(String id) async {
    // Wir machen hier für den Start einen "Hard Delete".
    // Achtung: Kinder und Transaktionen könnten verweisen (Orphans).
    await _collection.doc(id).delete();
  }

  // --- NEUE FEATURES ---

  @override
  Stream<List<ExpenseNode>> watchAllExpenseNodes() {
    return _collection.snapshots().map((snapshot) {
      final flatNodes = snapshot.docs
          .map((doc) => ExpenseNode.fromFirestore(doc))
          .toList();
      return _buildTree(flatNodes);
    });
  }

  // --- INTERNE LOGIK: Baum bauen (Rekonstruktion) ---
  List<ExpenseNode> _buildTree(List<ExpenseNode> flatNodes) {
    // 1. Gruppiere Kinder nach Parent-ID
    Map<String, List<ExpenseNode>> childrenMap = {};
    for (var node in flatNodes) {
      if (node.parentId != null) {
        childrenMap.putIfAbsent(node.parentId!, () => []).add(node);
      }
    }

    // 2. Rekursive Funktion zum Zusammenbauen
    ExpenseNode attachChildren(ExpenseNode parent) {
      final children = childrenMap[parent.id] ?? [];

      return ExpenseNode(
        id: parent.id,
        parentId: parent.parentId,
        name: parent.name,
        plannedAmount: parent.plannedAmount,
        interval: parent.interval,
        type: parent.type,
        // Rekursion hier:
        children: children.map((c) => attachChildren(c)).toList(),
      );
    }

    // 3. Nur Root-Knoten zurückgeben (die keinen Parent haben)
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
// RIVERPOD PROVIDERS (Ersatz für die alten Provider)
// -----------------------------------------------------------------------------

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception("Nicht eingeloggt (TransactionRepo)");
  return FirestoreTransactionRepository(uid);
}

@riverpod
ExpenseNodeRepository expenseNodeRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception("Nicht eingeloggt (ExpenseRepo)");
  return FirestoreExpenseNodeRepository(uid);
}

@riverpod
IncomeSourceRepository incomeSourceRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception("Nicht eingeloggt (IncomeRepo)");
  return FirestoreIncomeRepository(uid);
}
