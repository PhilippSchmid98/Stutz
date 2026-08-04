import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class FirestoreTimestampConverter
    implements JsonConverter<DateTime, Timestamp> {
  const FirestoreTimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}
