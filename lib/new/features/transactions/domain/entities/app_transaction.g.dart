// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppTransaction _$AppTransactionFromJson(Map<String, dynamic> json) =>
    _AppTransaction(
      id: json['id'] as String,
      expenseNodeId: json['expenseNodeId'] as String,
      amount: (json['amount'] as num).toDouble(),
      dateTime: const FirestoreTimestampConverter().fromJson(
        json['dateTime'] as Timestamp,
      ),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$AppTransactionToJson(_AppTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseNodeId': instance.expenseNodeId,
      'amount': instance.amount,
      'dateTime': const FirestoreTimestampConverter().toJson(instance.dateTime),
      'note': instance.note,
    };
