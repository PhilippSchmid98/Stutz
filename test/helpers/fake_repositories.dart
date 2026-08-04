// // test/helpers/fake_repositories.dart
// //
// // In-memory fake implementations of domain repository interfaces.
// // Use these in provider tests to avoid any Firebase dependency.

// import 'package:stutz/domain/models/models.dart';
// import 'package:stutz/domain/repositories/expense_repository.dart';
// import 'package:stutz/domain/repositories/income_repository.dart';
// import 'package:stutz/domain/repositories/transaction_repository.dart';

// class FakeIncomeRepository implements IncomeSourceRepository {
//   List<IncomeSource> items;

//   FakeIncomeRepository([this.items = const []]);

//   @override
//   Future<List<IncomeSource>> getAllIncomeSources() async => items;

//   @override
//   Stream<List<IncomeSource>> watchAllIncomeSources() => Stream.value(items);

//   @override
//   Future<void> addIncomeSource(IncomeSource source) async {
//     items = [...items, source];
//   }

//   @override
//   Future<void> updateIncomeSource(IncomeSource source) async {
//     items = items.map((s) => s.id == source.id ? source : s).toList();
//   }

//   @override
//   Future<void> deleteIncomeSource(String id) async {
//     items = items.where((s) => s.id != id).toList();
//   }
// }

// class FakeExpenseNodeRepository implements ExpenseNodeRepository {
//   List<ExpenseNode> items;

//   FakeExpenseNodeRepository([this.items = const []]);

//   @override
//   Future<List<ExpenseNode>> getAllExpenseNodes() async => items;

//   @override
//   Stream<List<ExpenseNode>> watchAllExpenseNodes() => Stream.value(items);

//   @override
//   Future<void> addExpenseNode(ExpenseNode node) async {
//     items = [...items, node];
//   }

//   @override
//   Future<void> updateExpenseNode(ExpenseNode node) async {
//     items = items.map((n) => n.id == node.id ? node : n).toList();
//   }

//   @override
//   Future<void> deleteExpenseNode(String id) async {
//     items = items.where((n) => n.id != id).toList();
//   }

//   @override
//   Future<void> updateNodeOrder(List<ExpenseNode> sortedNodes) async {
//     items = sortedNodes;
//   }
// }

// class FakeTransactionRepository implements TransactionRepository {
//   List<AppTransaction> items;

//   FakeTransactionRepository([this.items = const []]);

//   @override
//   Future<List<AppTransaction>> getAllTransactions() async => items;

//   @override
//   Stream<List<AppTransaction>> watchAllTransactions() => Stream.value(items);

//   @override
//   Future<void> addTransaction(AppTransaction transaction) async {
//     items = [...items, transaction];
//   }

//   @override
//   Future<void> updateTransaction(AppTransaction transaction) async {
//     items = items.map((t) => t.id == transaction.id ? transaction : t).toList();
//   }

//   @override
//   Future<void> deleteTransaction(String id) async {
//     items = items.where((t) => t.id != id).toList();
//   }
// }
