import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

class ExpenseNodeMapper {
  const ExpenseNodeMapper._();

  static ExpenseNode fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw FormatException('Expense node ${document.id} has no data');
    }

    return fromData(document.id, data);
  }

  static ExpenseNode fromData(String id, Map<String, dynamic> data) {
    if (id.isEmpty) {
      throw const FormatException('Expense node has an empty ID');
    }

    return ExpenseNode(
      id: id,
      parentId: data['parentId'] as String?,
      name: data['name'] as String? ?? 'Unknown',
      plannedAmountMinor: storedMinorUnits(
        minorValue: data['plannedAmountMinor'],
        legacyMajorValue: data['plannedAmount'],
      ),
      interval: _parseInterval(data['interval']),
      type: _parseType(data['type']),
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 99999,
    );
  }

  static Map<String, dynamic> toDocument(ExpenseNode node) {
    return {
      'parentId': node.parentId,
      'name': node.name,
      'plannedAmountMinor': node.plannedAmountMinor,
      'interval': node.interval?.name,
      'type': node.type?.name,
      'sortOrder': node.sortOrder,
    };
  }

  static PaymentInterval? _parseInterval(Object? value) {
    switch (value?.toString().toLowerCase()) {
      case 'yearly':
        return PaymentInterval.yearly;
      case 'monthly':
        return PaymentInterval.monthly;
      default:
        return null;
    }
  }

  static ExpenseType? _parseType(Object? value) {
    switch (value?.toString().toLowerCase()) {
      case 'fixed':
        return ExpenseType.fixed;
      case 'variable':
        return ExpenseType.variable;
      default:
        return null;
    }
  }
}
