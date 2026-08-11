import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

part 'income_source.freezed.dart';

@freezed
abstract class IncomeSource with _$IncomeSource {
  const IncomeSource._();

  const factory IncomeSource({
    required String id,
    required String name,
    required double amount,
    @Default(PaymentInterval.monthly) PaymentInterval interval,
    @Default(IncomeGroup.main) IncomeGroup group,
  }) = _IncomeSource;

  /// Monthly-equivalent amount — yearly incomes are divided by 12.
  double get monthlyAmount =>
      interval == PaymentInterval.yearly ? amount / 12 : amount;

  factory IncomeSource.fromFirestore(
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
}

extension IncomeSourceFirestoreX on IncomeSource {
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'interval': interval.name,
      'group': group.name,
    };
  }
}

PaymentInterval _parseInterval(String? value) {
  switch (value?.toLowerCase()) {
    case 'yearly':
      return PaymentInterval.yearly;
    default:
      return PaymentInterval.monthly;
  }
}

IncomeGroup _parseGroup(String? value) {
  switch (value?.toLowerCase()) {
    case 'additional':
      return IncomeGroup.additional;
    default:
      return IncomeGroup.main;
  }
}
