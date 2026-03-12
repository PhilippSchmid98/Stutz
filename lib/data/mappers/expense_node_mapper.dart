import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';

class ExpenseNodeMapper {
  static ExpenseNode fromFirestore(
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
      // Lazy-migration sentinel: old documents without sortOrder go to end.
      sortOrder: data['sortOrder'] ?? 99999,
      children: [],
    );
  }

  static Map<String, dynamic> toFirestore(ExpenseNode node) {
    return {
      'parentId': node.parentId,
      'name': node.name,
      'plannedAmount': node.plannedAmount,
      'interval':
          node.interval != null ? _serializeInterval(node.interval!) : null,
      'type': node.type != null ? _serializeType(node.type!) : null,
      'sortOrder': node.sortOrder,
    };
  }

  static PaymentInterval? _parseInterval(String? value) {
    switch (value?.toLowerCase()) {
      case 'yearly':
        return PaymentInterval.yearly;
      case 'monthly':
        return PaymentInterval.monthly;
      default:
        return null;
    }
  }

  static ExpenseType? _parseType(String? value) {
    switch (value?.toLowerCase()) {
      case 'fixed':
        return ExpenseType.fixed;
      case 'variable':
        return ExpenseType.variable;
      default:
        return null;
    }
  }

  static String _serializeInterval(PaymentInterval interval) {
    switch (interval) {
      case PaymentInterval.yearly:
        return 'Yearly';
      case PaymentInterval.monthly:
        return 'Monthly';
    }
  }

  static String _serializeType(ExpenseType type) {
    switch (type) {
      case ExpenseType.fixed:
        return 'Fixed';
      case ExpenseType.variable:
        return 'Variable';
    }
  }
}
