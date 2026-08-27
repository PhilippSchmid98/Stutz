import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/notification_import/data/transaction_draft_mapper.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';

void main() {
  test(
    'maps parsed draft data without persisting raw notification content',
    () {
      final capturedAt = Timestamp.fromDate(DateTime(2026, 8, 26, 12));
      final occurredAt = Timestamp.fromDate(DateTime(2026, 8, 26, 11, 59));
      final data = <String, dynamic>{
        'sourcePackage': 'com.google.android.apps.walletnfcrel',
        'sourceDedupeKey': 'wallet-notification-1',
        'capturedAt': capturedAt,
        'occurredAt': occurredAt,
        'merchant': 'Coop Pronto',
        'normalizedMerchant': 'coop pronto',
        'amountMinor': 1245,
        'currencyCode': 'CHF',
        'parserVersion': 1,
        'status': 'pending',
      };

      final draft = TransactionDraftMapper.fromData('draft-1', data);

      expect(draft.id, 'draft-1');
      expect(draft.amount, 12.45);
      expect(draft.capturedAt, capturedAt.toDate());
      expect(draft.status, TransactionDraftStatus.pending);
      expect(data.containsKey('id'), isFalse);

      final document = TransactionDraftMapper.toDocument(draft);
      expect(document['occurredAt'], occurredAt);
      expect(document.containsKey('title'), isFalse);
      expect(document.containsKey('body'), isFalse);
    },
  );

  test('rejects malformed required fields and unknown review status', () {
    final validData = <String, dynamic>{
      'sourcePackage': 'com.google.android.apps.walletnfcrel',
      'sourceDedupeKey': 'wallet-notification-1',
      'capturedAt': Timestamp.now(),
      'occurredAt': Timestamp.now(),
      'merchant': 'Coop Pronto',
      'normalizedMerchant': 'coop pronto',
      'amountMinor': 1245,
      'currencyCode': 'CHF',
      'parserVersion': 1,
      'status': 'pending',
    };

    expect(
      () => TransactionDraftMapper.fromData('draft-1', {
        ...validData,
        'amountMinor': 12.45,
      }),
      throwsFormatException,
    );
    expect(
      () => TransactionDraftMapper.fromData('draft-1', {
        ...validData,
        'status': 'reviewing',
      }),
      throwsFormatException,
    );
  });
}
