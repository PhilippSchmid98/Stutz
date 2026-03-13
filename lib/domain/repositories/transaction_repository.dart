import 'package:stutz/domain/models/models.dart';

abstract class TransactionRepository {
  Future<List<AppTransaction>> getAllTransactions();
  Stream<List<AppTransaction>> watchAllTransactions();

  Future<void> addTransaction(AppTransaction transaction);
  Future<void> updateTransaction(AppTransaction transaction);
  Future<void> deleteTransaction(String id);
}
