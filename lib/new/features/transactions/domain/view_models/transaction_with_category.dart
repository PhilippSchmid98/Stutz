import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/domain/models/transaction.dart';

part 'transaction_with_category.freezed.dart';

/// An [AppTransaction] enriched with its category (expense node) name.
@freezed
abstract class TransactionWithCategory with _$TransactionWithCategory {
  const factory TransactionWithCategory({
    required AppTransaction transaction,
    required String categoryName,

    /// The parent node's ID, used for grouping by category.
    String? groupName,
  }) = _TransactionWithCategory;
}
