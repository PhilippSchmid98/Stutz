import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

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

  /// Recursively calculates the total monthly cost for this node, including all descendants.
  double get totalMonthlyCalculated {
    if (isGroup) {
      return children.fold<double>(
        0.0,
        (total, child) => total + child.totalMonthlyCalculated,
      );
    }
    final amount = plannedAmount ?? 0.0;
    if (interval == PaymentInterval.yearly) return amount / 12;
    return amount;
  }

  /// Firestore stores flat nodes (no nested children); [parentId] links them — use TreeBuilder to assemble.
  factory ExpenseNode.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ExpenseNode(
      id: doc.id,
      parentId: data['parentId'],
      name: data['name'] ?? 'Unknown',
      plannedAmount: (data['plannedAmount'] as num?)?.toDouble(),
      interval: _parseInterval(data['interval']),
      type: _parseType(data['type']),
      sortOrder: data['sortOrder'] ?? 99999,
    );
  }
}

extension ExpenseNodeFirestoreX on ExpenseNode {
  Map<String, dynamic> toFirestore() {
    return {
      'parentId': parentId,
      'name': name,
      'plannedAmount': plannedAmount,
      'interval': interval?.name,
      'type': type?.name,
      'sortOrder': sortOrder,
    };
  }
}

PaymentInterval? _parseInterval(String? value) {
  switch (value?.toLowerCase()) {
    case 'yearly':
      return PaymentInterval.yearly;
    case 'monthly':
      return PaymentInterval.monthly;
    default:
      return null;
  }
}

ExpenseType? _parseType(String? value) {
  switch (value?.toLowerCase()) {
    case 'fixed':
      return ExpenseType.fixed;
    case 'variable':
      return ExpenseType.variable;
    default:
      return null;
  }
}
