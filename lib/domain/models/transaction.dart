import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

/// Renamed from [Transaction] to avoid collision with [cloud_firestore.Transaction].
@freezed
abstract class AppTransaction with _$AppTransaction {
  const factory AppTransaction({
    required String id,
    required String expenseNodeId,
    required double amount,
    required DateTime dateTime,
    String? note,
  }) = _AppTransaction;
}
