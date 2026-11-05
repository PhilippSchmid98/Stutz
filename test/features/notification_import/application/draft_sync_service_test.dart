import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/application/notification_draft_sync.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';

void main() {
  test('uploads every draft before acknowledging the local queue', () async {
    final first = _draft('first');
    final second = _draft('second');
    final gateway = _FakeCaptureGateway([first, second]);
    final upsertedDraftIds = <String>[];
    Future<void> upsertCapturedDraft(TransactionDraft draft) async {
      upsertedDraftIds.add(draft.id);
    }

    final synchronizer = NotificationDraftSynchronizer(
      captureGateway: gateway,
      upsertCapturedDraft: upsertCapturedDraft,
      onSynchronized: () {},
    );

    await synchronizer.synchronize('user-1');

    expect(gateway.activeOwner, 'user-1');
    expect(upsertedDraftIds, ['first', 'second']);
    expect(gateway.acknowledgedDraftIds, ['first', 'second']);
  });

  test('leaves the local queue unacknowledged when an upload fails', () async {
    final first = _draft('first');
    final second = _draft('second');
    final gateway = _FakeCaptureGateway([first, second]);
    final upsertedDraftIds = <String>[];
    Future<void> upsertCapturedDraft(TransactionDraft draft) async {
      if (draft.id == 'second') throw StateError('Firestore unavailable');
      upsertedDraftIds.add(draft.id);
    }

    final synchronizer = NotificationDraftSynchronizer(
      captureGateway: gateway,
      upsertCapturedDraft: upsertCapturedDraft,
      onSynchronized: () {},
    );

    await expectLater(
      () => synchronizer.synchronize('user-1'),
      throwsStateError,
    );

    expect(upsertedDraftIds, ['first']);
    expect(gateway.acknowledgedDraftIds, isEmpty);
  });

  test('coalesces a capture event received during synchronization', () async {
    final gateway = _BlockingCaptureGateway();
    var synchronizedCount = 0;
    final synchronizer = NotificationDraftSynchronizer(
      captureGateway: gateway,
      upsertCapturedDraft: (_) async {},
      onSynchronized: () => synchronizedCount += 1,
    );

    final initialSync = synchronizer.synchronize('user-1');
    await gateway.firstCaptureStarted.future;
    final captureEventSync = synchronizer.synchronize('user-1');
    gateway.continueFirstCapture.complete();

    await Future.wait([initialSync, captureEventSync]);

    expect(gateway.captureCallCount, 2);
    expect(synchronizedCount, 2);
  });

  test(
    'canceled sync cannot restore an old owner after an account switch',
    () async {
      final gateway = _BlockingCaptureGateway();
      final oldSynchronizer = NotificationDraftSynchronizer(
        captureGateway: gateway,
        upsertCapturedDraft: (_) async {},
        onSynchronized: () {},
      );
      final newSynchronizer = NotificationDraftSynchronizer(
        captureGateway: gateway,
        upsertCapturedDraft: (_) async {},
        onSynchronized: () {},
      );

      final oldSync = oldSynchronizer.synchronize('owner-a');
      await gateway.firstCaptureStarted.future;
      oldSynchronizer.cancel();
      await newSynchronizer.synchronize('owner-b');
      gateway.continueFirstCapture.complete();
      await oldSync;

      expect(gateway.activeOwner, 'owner-b');
      expect(gateway.listCallCount, 1);
    },
  );
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
  Stream<void> get draftCapturedEvents => const Stream<void>.empty();

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

class _BlockingCaptureGateway extends _FakeCaptureGateway {
  final firstCaptureStarted = Completer<void>();
  final continueFirstCapture = Completer<void>();
  var captureCallCount = 0;
  var listCallCount = 0;

  _BlockingCaptureGateway() : super(const []);

  @override
  Future<void> captureActiveNotifications() async {
    captureCallCount += 1;
    if (captureCallCount == 1) {
      firstCaptureStarted.complete();
      await continueFirstCapture.future;
    }
  }

  @override
  Future<List<TransactionDraft>> listUnsyncedDrafts() async {
    listCallCount += 1;
    return super.listUnsyncedDrafts();
  }
}
