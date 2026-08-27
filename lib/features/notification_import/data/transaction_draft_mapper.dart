import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';

class TransactionDraftMapper {
  const TransactionDraftMapper._();

  static TransactionDraft fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw FormatException('Transaction draft ${document.id} has no data');
    }
    return fromData(document.id, data);
  }

  static TransactionDraft fromData(String id, Map<String, dynamic> data) {
    if (id.isEmpty) {
      throw const FormatException('Transaction draft has an empty ID');
    }

    final amountMinor = data['amountMinor'];
    if (amountMinor is! num || amountMinor <= 0 || amountMinor % 1 != 0) {
      throw FormatException('Transaction draft $id has an invalid amountMinor');
    }

    final parserVersion = data['parserVersion'];
    if (parserVersion is! num || parserVersion <= 0 || parserVersion % 1 != 0) {
      throw FormatException(
        'Transaction draft $id has an invalid parserVersion',
      );
    }

    final status = _statusFromStorageValue(data['status'], id);
    final suggestedExpenseNodeId = _optionalString(
      data['suggestedExpenseNodeId'],
      'suggestedExpenseNodeId',
      id,
    );
    final savedTransactionId = _optionalString(
      data['savedTransactionId'],
      'savedTransactionId',
      id,
    );

    return TransactionDraft(
      id: id,
      sourcePackage: _requiredString(
        data['sourcePackage'],
        'sourcePackage',
        id,
      ),
      sourceDedupeKey: _requiredString(
        data['sourceDedupeKey'],
        'sourceDedupeKey',
        id,
      ),
      capturedAt: _dateTime(data['capturedAt'], 'capturedAt', id),
      occurredAt: _dateTime(data['occurredAt'], 'occurredAt', id),
      merchant: _requiredString(data['merchant'], 'merchant', id),
      normalizedMerchant: _requiredString(
        data['normalizedMerchant'],
        'normalizedMerchant',
        id,
      ),
      amountMinor: amountMinor.toInt(),
      currencyCode: _requiredString(data['currencyCode'], 'currencyCode', id),
      parserVersion: parserVersion.toInt(),
      status: status,
      suggestedExpenseNodeId: suggestedExpenseNodeId,
      savedTransactionId: savedTransactionId,
      reviewedAt: data['reviewedAt'] == null
          ? null
          : _dateTime(data['reviewedAt'], 'reviewedAt', id),
    );
  }

  static TransactionDraft fromPlatformData(
    String id,
    Map<String, dynamic> data,
  ) {
    final normalizedData = Map<String, dynamic>.from(data);
    for (final field in ['capturedAt', 'occurredAt', 'reviewedAt']) {
      final value = normalizedData[field];
      if (value is int) {
        normalizedData[field] = DateTime.fromMillisecondsSinceEpoch(value);
      }
    }
    return fromData(id, normalizedData);
  }

  static Map<String, dynamic> toDocument(TransactionDraft draft) {
    return {
      'sourcePackage': draft.sourcePackage,
      'sourceDedupeKey': draft.sourceDedupeKey,
      'capturedAt': Timestamp.fromDate(draft.capturedAt),
      'occurredAt': Timestamp.fromDate(draft.occurredAt),
      'merchant': draft.merchant,
      'normalizedMerchant': draft.normalizedMerchant,
      'amountMinor': draft.amountMinor,
      'currencyCode': draft.currencyCode,
      'parserVersion': draft.parserVersion,
      'status': draft.status.name,
      'suggestedExpenseNodeId': draft.suggestedExpenseNodeId,
      'savedTransactionId': draft.savedTransactionId,
      'reviewedAt': draft.reviewedAt == null
          ? null
          : Timestamp.fromDate(draft.reviewedAt!),
    };
  }

  static String _requiredString(Object? value, String field, String id) {
    if (value is! String || value.isEmpty) {
      throw FormatException('Transaction draft $id has an invalid $field');
    }
    return value;
  }

  static String? _optionalString(Object? value, String field, String id) {
    if (value == null) return null;
    return _requiredString(value, field, id);
  }

  static DateTime _dateTime(Object? value, String field, String id) {
    return switch (value) {
      Timestamp timestamp => timestamp.toDate(),
      DateTime dateTime => dateTime,
      _ => throw FormatException('Transaction draft $id has an invalid $field'),
    };
  }

  static TransactionDraftStatus _statusFromStorageValue(
    Object? value,
    String id,
  ) {
    return switch (value) {
      'pending' => TransactionDraftStatus.pending,
      'saved' => TransactionDraftStatus.saved,
      'discarded' => TransactionDraftStatus.discarded,
      _ => throw FormatException('Transaction draft $id has an invalid status'),
    };
  }
}
