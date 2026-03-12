import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';

class IncomeMapper {
  static IncomeSource fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return IncomeSource(
      id: doc.id,
      name: data['name'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      interval: _parseInterval(data['interval']),
      group: _parseGroup(data['group']),
    );
  }

  static Map<String, dynamic> toFirestore(IncomeSource source) {
    return {
      'name': source.name,
      'amount': source.amount,
      'interval': _serializeInterval(source.interval),
      'group': _serializeGroup(source.group),
    };
  }

  static PaymentInterval _parseInterval(String? value) {
    switch (value?.toLowerCase()) {
      case 'yearly':
        return PaymentInterval.yearly;
      default:
        return PaymentInterval.monthly;
    }
  }

  static IncomeGroup _parseGroup(String? value) {
    switch (value?.toLowerCase()) {
      case 'additional':
        return IncomeGroup.additional;
      default:
        return IncomeGroup.main;
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

  static String _serializeGroup(IncomeGroup group) {
    switch (group) {
      case IncomeGroup.additional:
        return 'Additional';
      case IncomeGroup.main:
        return 'Main';
    }
  }
}
