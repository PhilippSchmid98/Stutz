import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_transaction.freezed.dart';

/// Renamed from Transaction to avoid collision with Firestore transaction APIs.
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
