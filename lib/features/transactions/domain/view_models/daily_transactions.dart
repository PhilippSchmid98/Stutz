import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/features/transactions/domain/view_models/transaction_with_category.dart';

part 'daily_transactions.freezed.dart';

/// All enriched transactions for a single calendar day.
@freezed
abstract class DailyTransactions with _$DailyTransactions {
  const factory DailyTransactions({
    required DateTime date,
    required double totalAmount,
    required List<TransactionWithCategory> transactions,
  }) = _DailyTransactions;
}
