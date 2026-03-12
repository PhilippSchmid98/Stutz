import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stutz/domain/models/models.dart';

class TransactionMapper {
  static AppTransaction fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AppTransaction(
      id: doc.id,
      expenseNodeId: data['expenseNodeId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      note: data['note'],
    );
  }

  static Map<String, dynamic> toFirestore(AppTransaction txn) {
    return {
      'expenseNodeId': txn.expenseNodeId,
      'amount': txn.amount,
      'dateTime': Timestamp.fromDate(txn.dateTime),
      'note': txn.note,
    };
  }
}
