import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

class TransactionMonthSummary {
  final DateTime month;
  final int transactionCount;
  final Map<String, double> categoryTotals;

  const TransactionMonthSummary({
    required this.month,
    required this.transactionCount,
    required this.categoryTotals,
  });
}

Map<String, double> categoryDeltasForTransactionUpdate(
  AppTransaction existing,
  AppTransaction updated,
) {
  final deltas = <String, double>{};

  void addDelta(String categoryId, double amount) {
    deltas.update(
      categoryId,
      (current) => current + amount,
      ifAbsent: () => amount,
    );
  }

  addDelta(existing.expenseNodeId, -existing.amount);
  addDelta(updated.expenseNodeId, updated.amount);
  return deltas;
}
