import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

class TransactionMapper {
  const TransactionMapper._();

  static AppTransaction fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw FormatException('Transaction ${document.id} has no data');
    }

    return fromData(document.id, data);
  }

  static AppTransaction fromData(String id, Map<String, dynamic> data) {
    if (id.isEmpty) {
      throw const FormatException('Transaction has an empty ID');
    }

    final dateTime = data['dateTime'];
    final normalizedDateTime = switch (dateTime) {
      Timestamp value => value.toDate(),
      DateTime value => value,
      String value => DateTime.parse(value),
      _ => throw FormatException('Transaction $id has an invalid dateTime'),
    };

    final amount = data['amount'];
    if (amount is! num) {
      throw FormatException('Transaction $id has an invalid amount');
    }

    final expenseNodeId = data['expenseNodeId'];
    if (expenseNodeId is! String || expenseNodeId.isEmpty) {
      throw FormatException('Transaction $id has an invalid expenseNodeId');
    }

    return AppTransaction(
      id: id,
      expenseNodeId: expenseNodeId,
      amount: amount.toDouble(),
      dateTime: normalizedDateTime,
      note: data['note'] as String?,
    );
  }

  static Map<String, dynamic> toDocument(AppTransaction transaction) {
    return {
      'expenseNodeId': transaction.expenseNodeId,
      'amount': transaction.amount,
      'dateTime': Timestamp.fromDate(transaction.dateTime),
      'note': transaction.note,
    };
  }
}
