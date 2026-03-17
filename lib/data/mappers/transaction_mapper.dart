import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stutz/domain/models/models.dart';

class TransactionMapper {
  static AppTransaction fromMap(String id, Map<String, dynamic> data) {
    return AppTransaction(
      id: id,
      expenseNodeId: data['expenseNodeId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      note: data['note'],
    );
  }

  static AppTransaction fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return fromMap(doc.id, doc.data()!);
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
