import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/core/enums/enums.dart';

part 'expense_node.freezed.dart';

@freezed
abstract class ExpenseNode with _$ExpenseNode {
  const ExpenseNode._();

  const factory ExpenseNode({
    required String id,
    String? parentId,
    required String name,
    double? plannedAmount,
    /// Calculated field — not persisted in DB.
    double? actualAmount,
    ExpenseType? type,
    PaymentInterval? interval,
    @Default([]) List<ExpenseNode> children,
    /// [sortOrder] 99999 is a lazy-migration sentinel for old documents without sorting.
    @Default(99999) int sortOrder,
  }) = _ExpenseNode;

  bool get isGroup => children.isNotEmpty;
}
