import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeSource {
  final String id;
  final String name;
  final double amount;
  final String interval; // 'Monthly' or 'Yearly'
  final String group; // 'Main' or 'Additional'

  IncomeSource({
    required this.id,
    required this.name,
    required this.amount,
    required this.interval,
    required this.group,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'interval': interval,
      'group': group,
    };
  }

  factory IncomeSource.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return IncomeSource(
      id: doc.id,
      name: data['name'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      interval: data['interval'] ?? 'Monthly',
      group: data['group'] ?? 'Main',
    );
  }
}
