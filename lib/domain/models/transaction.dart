import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String expenseNodeId;
  final double amount;
  final DateTime dateTime;
  final String? note;

  Transaction({
    required this.id,
    required this.expenseNodeId,
    required this.amount,
    required this.dateTime,
    this.note,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'expenseNodeId': expenseNodeId,
      'amount': amount,
      'dateTime': Timestamp.fromDate(dateTime),
      'note': note,
    };
  }

  factory Transaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Transaction(
      id: doc.id,
      expenseNodeId: data['expenseNodeId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      note: data['note'],
    );
  }
}
