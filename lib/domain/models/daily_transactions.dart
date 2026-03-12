import 'package:stutz/domain/models/transaction_with_category.dart';

/// All enriched transactions for a single calendar day.
class DailyTransactions {
  final DateTime date;
  final double totalAmount;
  final List<TransactionWithCategory> transactions;

  const DailyTransactions({
    required this.date,
    required this.totalAmount,
    required this.transactions,
  });
}
