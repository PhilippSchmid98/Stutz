import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

class IncomeSourceMapper {
  const IncomeSourceMapper._();

  static IncomeSource fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw FormatException('Income source ${document.id} has no data');
    }

    return fromData(document.id, data);
  }

  static IncomeSource fromData(String id, Map<String, dynamic> data) {
    if (id.isEmpty) {
      throw const FormatException('Income source has an empty ID');
    }

    final amount = data['amount'];
    if (amount is! num) {
      throw FormatException('Income source $id has an invalid amount');
    }

    return IncomeSource(
      id: id,
      name: data['name'] as String? ?? '',
      amount: amount.toDouble(),
      interval: _parseInterval(data['interval']),
      group: _parseGroup(data['group']),
    );
  }

  static Map<String, dynamic> toDocument(IncomeSource source) {
    return {
      'name': source.name,
      'amount': source.amount,
      'interval': source.interval.name,
      'group': source.group.name,
    };
  }

  static PaymentInterval _parseInterval(Object? value) {
    switch (value?.toString().toLowerCase()) {
      case 'yearly':
        return PaymentInterval.yearly;
      default:
        return PaymentInterval.monthly;
    }
  }

  static IncomeGroup _parseGroup(Object? value) {
    switch (value?.toString().toLowerCase()) {
      case 'additional':
        return IncomeGroup.additional;
      default:
        return IncomeGroup.main;
    }
  }
}
