import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

class TransactionMonthSummary {
  final DateTime month;
  final int transactionCount;
  final Map<String, int> categoryTotalsMinor;

  TransactionMonthSummary({
    required this.month,
    required this.transactionCount,
    required Map<String, int> categoryTotalsMinor,
  }) : categoryTotalsMinor = Map.unmodifiable(categoryTotalsMinor);
}

Map<String, int> categoryDeltasForTransactionUpdate(
  AppTransaction existing,
  AppTransaction updated,
) {
  final deltas = <String, int>{};

  void addDelta(String categoryId, int amountMinor) {
    deltas.update(
      categoryId,
      (current) => current + amountMinor,
      ifAbsent: () => amountMinor,
    );
  }

  addDelta(existing.expenseNodeId, -existing.amountMinor);
  addDelta(updated.expenseNodeId, updated.amountMinor);
  return deltas;
}
