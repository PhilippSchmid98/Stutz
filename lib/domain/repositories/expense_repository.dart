import 'package:stutz/domain/models/models.dart';

abstract class ExpenseNodeRepository {
  Future<List<ExpenseNode>> getAllExpenseNodes();
  Stream<List<ExpenseNode>> watchAllExpenseNodes();

  Future<void> addExpenseNode(ExpenseNode node);
  Future<void> updateExpenseNode(ExpenseNode node);
  Future<void> deleteExpenseNode(String id);
  Future<void> updateNodeOrder(List<ExpenseNode> sortedNodes);
}
