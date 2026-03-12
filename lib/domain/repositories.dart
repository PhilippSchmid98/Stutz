import 'package:stutz/domain/models/models.dart';

abstract class IncomeSourceRepository {
  Future<List<IncomeSource>> getAllIncomeSources();
  Stream<List<IncomeSource>> watchAllIncomeSources();

  Future<void> addIncomeSource(IncomeSource source);
  Future<void> updateIncomeSource(IncomeSource source);
  Future<void> deleteIncomeSource(String id);
}

abstract class ExpenseNodeRepository {
  Future<void> updateNodeOrder(List<ExpenseNode> sortedNodes);

  Future<List<ExpenseNode>> getAllExpenseNodes();
  Stream<List<ExpenseNode>> watchAllExpenseNodes();

  Future<void> addExpenseNode(ExpenseNode node);
  Future<void> updateExpenseNode(ExpenseNode node);
  Future<void> deleteExpenseNode(String id);
}

abstract class TransactionRepository {
  Future<List<AppTransaction>> getAllTransactions();
  Stream<List<AppTransaction>> watchAllTransactions();

  Future<void> addTransaction(AppTransaction transaction);
  Future<void> updateTransaction(AppTransaction transaction);
  Future<void> deleteTransaction(String id);
}
