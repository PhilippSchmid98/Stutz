import 'package:stutz/domain/models/transaction.dart';

/// An [AppTransaction] enriched with its category (expense node) name.
class TransactionWithCategory {
  final AppTransaction transaction;
  final String categoryName;

  /// The parent node's ID, used for grouping by category.
  final String? groupName;

  const TransactionWithCategory({
    required this.transaction,
    required this.categoryName,
    this.groupName,
  });
}
