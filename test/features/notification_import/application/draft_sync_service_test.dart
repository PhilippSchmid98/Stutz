import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/notification_import/application/draft_sync_service.dart';
import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';
import 'package:stutz/features/notification_import/domain/repositories/transaction_draft_store.dart';

void main() {
  test('uploads every draft before acknowledging the local queue', () async {
    final first = _draft('first');
    final second = _draft('second');
    final gateway = _FakeCaptureGateway([first, second]);
    final store = _FakeDraftStore();
    final service = DraftSyncService(
      captureGateway: gateway,
      draftStore: store,
    );

    await service.synchronize('user-1');

    expect(gateway.activeOwner, 'user-1');
    expect(store.upsertedDraftIds, ['first', 'second']);
    expect(gateway.acknowledgedDraftIds, ['first', 'second']);
  });

  test('leaves the local queue unacknowledged when an upload fails', () async {
    final first = _draft('first');
    final second = _draft('second');
    final gateway = _FakeCaptureGateway([first, second]);
    final store = _FakeDraftStore(failForId: 'second');
    final service = DraftSyncService(
      captureGateway: gateway,
      draftStore: store,
    );

    await expectLater(() => service.synchronize('user-1'), throwsStateError);

    expect(store.upsertedDraftIds, ['first']);
    expect(gateway.acknowledgedDraftIds, isEmpty);
  });
}

TransactionDraft _draft(String id) {
  return TransactionDraft(
    id: id,
    sourcePackage: 'com.google.android.apps.walletnfcrel',
    sourceDedupeKey: 'dedupe-$id',
    capturedAt: DateTime(2026, 8, 26, 12),
    occurredAt: DateTime(2026, 8, 26, 11, 59),
    merchant: 'Coop Pronto',
    normalizedMerchant: 'coop pronto',
    amountMinor: 1245,
    currencyCode: 'CHF',
    parserVersion: 1,
  );
}

class _FakeCaptureGateway implements NotificationCaptureGateway {
  final List<TransactionDraft> drafts;
  String? activeOwner;
  List<String> acknowledgedDraftIds = [];

  _FakeCaptureGateway(this.drafts);

  @override
  bool get isSupported => true;

  @override
  Future<void> acknowledgeSyncedDrafts(List<String> draftIds) async {
    acknowledgedDraftIds = draftIds;
  }

  @override
  Future<void> clearActiveOwner() async {
    activeOwner = null;
  }

  @override
  Future<void> captureActiveNotifications() async {}

  @override
  Future<bool> hasNotificationAccess() async => true;

  @override
  Future<List<TransactionDraft>> listUnsyncedDrafts() async => drafts;

  @override
  Future<void> openNotificationAccessSettings() async {}

  @override
  Future<void> setActiveOwner(String userId) async {
    activeOwner = userId;
  }
}

class _FakeDraftStore implements TransactionDraftStore {
  final String? failForId;
  final List<String> upsertedDraftIds = [];

  _FakeDraftStore({this.failForId});

  @override
  Future<void> upsertCapturedDraft(TransactionDraft draft) async {
    if (draft.id == failForId) throw StateError('Firestore unavailable');
    upsertedDraftIds.add(draft.id);
  }
}
