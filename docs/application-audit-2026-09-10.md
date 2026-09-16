# Stutz Application Audit

Last reviewed: 2026-09-10

Implementation status updated: 2026-09-16

## 1. Purpose and scope

This document is a detailed engineering audit of the current Stutz codebase. It
examines the application as an Android-focused Flutter financial application,
not merely as a prototype UI.

The review covers:

1. Architecture and state management.
2. Android platform code and notification capture.
3. Firebase integration and the financial data layer.
4. Performance, UI/UX, and Android accessibility.
5. Automated test coverage and test quality.
6. CI/CD and release engineering.

The findings are based on the current implementation under `lib/`,
`android/app/src/main/`, `test/`, `android/app/src/test/`, Firebase rules and
indexes, package manifests, and GitHub Actions workflows. Generated Dart files
were considered implementation artifacts rather than primary design sources.

This is a point-in-time review. Line references may move as the code changes.

### 1.1 Severity legend

| Marker | Meaning |
| --- | --- |
| 🔥 Critical | A production-blocking risk to financial correctness, privacy, security, or account recovery. |
| ⚠️ Warning | A meaningful reliability, performance, maintainability, or UX defect that should be scheduled. |
| ✅ Good practice | A design or implementation choice worth preserving. |

### 1.2 Review principles

The review applies stricter standards than a normal consumer CRUD application
because Stutz stores financial records and derived budget totals. In this
domain:

- persisted money must have deterministic arithmetic;
- transaction creation must be retry-safe;
- derived aggregates must be reconcilable from source records;
- account transitions must not strand or misattribute data;
- malformed records must not make an entire ledger unreadable;
- sensitive local data requires an explicit backup, encryption, and retention
  policy;
- tests must concentrate on mutation boundaries, not only presentation and
  pure calculations.

## 2. Executive summary

**Overall score: 61/100.**

Stutz is a strong, unusually well-structured prototype. Its feature-first
organization is coherent, Riverpod is generally used correctly, core budget
calculations are pure, Firestore reads are mostly scoped appropriately, the
transaction history is paginated, and the test suite contains substantial
behavioral coverage. The app is not a collection of God widgets or ad hoc
Firebase calls.

It is not yet finance-grade. The primary blockers are:

1. Money is persisted and aggregated as IEEE-754 `double` values.
2. Firestore rules enforce ownership but not ledger schemas or legal state
   transitions.
3. Manual transaction creation is not idempotent and can double-increment a
   month summary when a transaction ID is replayed.
4. Anonymous users can sign out and permanently lose access to their ledger.
5. Captured notification data still has plaintext and retention risks. Owner
  lifecycle, debug logging, and Android backup were addressed on 2026-09-16.

No confirmed cross-user Firestore read vulnerability was found. Every current
wildcard rule still checks that the authenticated UID matches the user path.
The problem is integrity within a user's own namespace: a buggy, outdated, or
modified client can write data that the rest of the app cannot safely process.

### 2.1 Phase scorecard

| Phase | Score | Assessment |
| --- | ---: | --- |
| 1. Architecture and state management | 78/100 | Strong structure with a few incomplete refactors and hidden background failures. |
| 2. Android and notifications | 48/100 | Good parser and event model, but serious owner-lifecycle and local-data protection gaps. |
| 3. Firebase and data layer | 38/100 | Production-blocking money, rules, idempotency, and account-recovery risks. |
| 4. Performance and UI/UX | 67/100 | Good baseline ergonomics, with unbounded detail rendering and several interaction/accessibility defects. |
| 5. Tests | 62/100 | Meaningful suite, but the highest-risk repositories and native boundary are almost untested. |
| 6. CI/CD | 70/100 | Solid Flutter gate and Android builds, but incomplete test gates, weak caching, and moving tool versions. |

### 2.2 Corrections to the older refactoring audit

The implementation has moved since
[refactoring-audit.md](refactoring-audit.md). Two older conclusions should not
be repeated as current defects:

- Notification synchronization is no longer only a watched write-performing
  provider. `_AuthenticatedHome` now triggers synchronization on startup, app
  resume, and native capture events, and `NotificationDraftSynchronizer`
  serializes overlapping requests.
- Imported draft confirmation is idempotent at the draft level. A draft already
  marked `saved` returns its existing transaction ID before changing month
  totals.

The obsolete generated synchronization provider was removed on 2026-09-16.
The manual transaction creation path remains non-idempotent.

## 3. Validation baseline

The following checks were run against the reviewed workspace:

| Check | Result |
| --- | --- |
| `flutter analyze` | Passed with no diagnostics. |
| Flutter tests | 140 passed, 0 failed. |
| `npm run test:rules` | Passed. |
| `npm run test:backup` | 7 passed, 0 failed. |
| `npm run test:migration` | 5 passed, 0 failed. |
| Flutter aggregate line coverage | 2,407 / 3,925 lines, or 61.32%. |
| Android `testDebugUnitTest` | Could not configure locally because plugin build output was on `E:` while the pub cache was on `C:`. Tests did not execute; this was not a parser-test assertion failure. |

### Implementation update: Priority 1 (2026-09-16)

The following audit findings were implemented and locally validated after the
original review:

- Native ownership is cleared before sign-out and when the auth state is
  `null`; the active owner's queue is deleted with it.
- A cancelled synchronizer cannot set, read, write, or acknowledge old-owner
  data after an account switch.
- Raw Google Wallet notification logging was removed.
- Android backups are disabled; dedicated backup and data-extraction rules
  also exclude the queue and owner preferences.
- Queue schema version 3 retains only `UNIQUE(owner_id, source_dedupe_key)`;
  the upgrade path from version 2 is tested.

`flutter analyze`, the focused Dart synchronization suite (4 tests), and
`NotificationCaptureQueueTest` passed. Android backup inspection and a
documented debug-log review remain outstanding. Queue encryption and retention
of acknowledged rows remain follow-up work.

Coverage is discussed in detail in Phase 5. The generated coverage report was
removed after measurement.

---

## 4. Phase 1: Architecture and state management

### 4.1 ✅ Feature-first boundaries are coherent

The major features own their application, data, domain, and presentation code.
For example, budget reads are composed in
[budget_providers.dart](../lib/features/budget/application/budget_providers.dart#L14-L66),
while persistence remains in feature repositories and calculations remain in
pure domain services.

The dependency flow is generally healthy:

```text
presentation -> application providers/controllers -> repositories/services
                                              \-> domain value objects
```

Cross-feature transaction enrichment uses `CategoryLookup` instead of making
the transaction feature depend directly on the entire budget repository. This
is a useful narrow contract.

**Why this is good**

- Firestore concerns do not leak into most widgets.
- Calculators and grouping services can be tested without Firebase.
- Riverpod provider overrides make application-layer tests straightforward.
- Feature ownership is understandable without a large dependency-injection
  framework.

**Recommendation:** Preserve this structure. Do not introduce repository
interfaces everywhere merely for architectural symmetry. Add an interface only
where there is a real alternate implementation, emulator boundary, or test
benefit.

### 4.2 ✅ Riverpod usage is mostly appropriate

Reactive dependencies generally use `ref.watch`, while callbacks and commands
use `ref.read`. Auth routing providers are kept alive because they control the
whole application lifetime. Feature streams are auto-disposed by default.

The dashboard composes independently asynchronous category and summary data in
[dashboard_providers.dart](../lib/features/dashboard/application/dashboard_providers.dart#L29-L58),
and budget streams automatically propagate Firestore changes without manual
invalidation.

No broad stream-subscription leak was found:

- the native capture stream subscription is canceled;
- the manual pending-draft provider subscription is closed;
- the widget binding observer is removed;
- the transaction screen removes its `ItemPositionsListener` callback in its
  hook cleanup.

See [app_router.dart](../lib/app/app_router.dart#L118-L123) and
[transaction_screen.dart](../lib/features/transactions/presentation/transaction_screen.dart#L92-L151).

### 4.3 ✅ Notification synchronization is serialized

`NotificationDraftSynchronizer` holds one active synchronization and records
whether another pass was requested while it was running:

```dart
Future<void> synchronize(String userId) {
  final activeSynchronization = _activeSynchronization;
  if (activeSynchronization != null) {
    _synchronizationRequested = true;
    return activeSynchronization;
  }

  final synchronization = _drain(userId);
  _activeSynchronization = synchronization;
  // ...
}
```

Source:
[notification_draft_sync.dart](../lib/features/notification_import/application/notification_draft_sync.dart#L18-L51).

This prevents startup, resume, and native capture events from executing
overlapping queue uploads. The drain loop also ensures that an event arriving
during a sync causes another pass instead of being lost.

**Recommendation:** Keep this serialization behavior when the owner-lifecycle
fix described in Phase 2 is implemented.

### 4.4 ⚠️ An obsolete write-performing provider remains

The old provider still exists below the explicit synchronizer:

```dart
@riverpod
Future<void> synchronizeNotificationDrafts(Ref ref) async {
  // ...
  await service.synchronize(user.uid);
}
```

Source:
[notification_draft_sync.dart](../lib/features/notification_import/application/notification_draft_sync.dart#L59-L75).

No live code watches or reads its generated provider. This matters because it
creates two apparent owners for synchronization:

- `_AuthenticatedHome` and `NotificationDraftSynchronizer`, which are current;
- `synchronizeNotificationDraftsProvider`, which is stale.

Future maintenance can accidentally reintroduce provider-initialization writes
or assume that the stale provider clears the native owner on sign-out.

**Possible fixes**

1. Retain the provider and deliberately make it the sole coordinator.
2. Remove it and retain the explicit synchronizer owned by authenticated app
   lifecycle code.
3. Replace both with a keep-alive `AsyncNotifier` exposing an explicit `sync()`
   command and sync status.

**Recommended fix**

Use option 3 if sync status and retries are being added soon; otherwise use
option 2 now. Remove the obsolete function, regenerate Riverpod output, and
keep one clearly documented owner for all sync triggers.

**Acceptance criteria**

- Searching for `synchronizeNotificationDraftsProvider` returns no result.
- Startup, resume, native event, and explicit retry tests still pass.
- One synchronization abstraction owns serialization and error state.

### 4.5 ⚠️ Background synchronization errors are intentionally swallowed

The capture event listener has an empty error callback, and background sync
converts every failure into an ignored future:

```dart
_captureEventsSubscription = gateway.draftCapturedEvents.listen(
  (_) => _synchronizeInBackground(),
  onError: (_, __) {},
);

// Later:
_synchronizer.synchronize(userId).catchError((_) {});
```

Source: [app_router.dart](../lib/app/app_router.dart#L96-L100) and
[app_router.dart](../lib/app/app_router.dart#L159-L164).

Startup failures are visible through a retry screen, but later failures have no
status, retry affordance, or redacted diagnostic. The SQLite queue prevents
immediate data loss, which is good, but the user cannot distinguish "nothing
new" from "captured drafts have not synchronized for days."

**Failure scenario**

1. Firestore becomes unavailable after startup.
2. Wallet drafts continue entering SQLite.
3. Every resume sync fails.
4. The app silently keeps stale drafts locally.
5. The user assumes all expenses were imported.

**Recommended fix**

Expose a small sync state such as `idle`, `syncing`, `failed`, and
`lastSuccessfulAt`. Keep errors redacted. Show a retry action near the pending
draft indicator only when a durable queue remains unsynchronized.

Do not include merchant, amount, UID, note, or raw notification data in logs or
telemetry.

### 4.6 ⚠️ `TransactionMonthSummary` exposes mutable state

The class stores the caller-provided map directly:

```dart
class TransactionMonthSummary {
  final DateTime month;
  final int transactionCount;
  final Map<String, double> categoryTotals;
}
```

Source:
[transaction_month_summary.dart](../lib/features/transactions/domain/entities/transaction_month_summary.dart#L3-L12).

`final` prevents replacing the map reference; it does not prevent
`summary.categoryTotals['food'] = 999`. That violates the otherwise immutable
domain model and can create state changes that Riverpod does not observe.

**Possible fixes**

- Wrap input with `Map.unmodifiable`.
- Expose `UnmodifiableMapView`.
- Convert the model to Freezed, which matches the rest of the domain layer and
  provides structural equality and unmodifiable collection views.

**Recommended fix**

Convert the type to Freezed as part of the minor-unit migration. Its map should
become `Map<String, int> categoryTotalsMinor`, avoiding two migrations of the
same model.

### 4.7 ✅ There are no material God classes or const-constructor problems

Large screens are already split into private widgets, shared controls, and pure
services. Some build methods remain substantial, but business calculations do
not generally occur directly in them. Missing `const` instances are not a
meaningful performance concern compared with the data-layer and list issues in
later phases.

**Recommendation:** Do not launch a broad "add const everywhere" refactor. It
would create churn without addressing a measured bottleneck.

### 4.8 ⚠️ Dependency intent is not fully standardized

`json_annotation` and `json_serializable` are declared, but persistence uses
explicit Firestore mappers and domain models expose no generated JSON API.
Maintaining both strategies increases upgrade surface without current value.

**Recommended fix:** Keep the explicit Firestore mappers because they handle
`Timestamp`, migration defaults, and storage-specific validation. Remove unused
JSON dependencies after confirming generated sources do not reference them.

---

## 5. Phase 2: Android platform code and notifications

### 5.1 🔥 The native active owner is not cleared on sign-out

Every synchronization sets the active Firebase UID in native preferences:

```kotlin
fun setActiveOwner(userId: String) {
    preferences.edit().putString(ACTIVE_OWNER_KEY, userId).apply()
}
```

The listener reads that value whenever it queues a payment:

```kotlin
val ownerId = preferences.getString(ACTIVE_OWNER_KEY, null) ?: return false
```

Source:
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L28-L40).

When `_AuthenticatedHome` is disposed, it removes observers and subscriptions
but does not invoke `clearActiveOwner()`:

```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _captureEventsSubscription.cancel();
  _pendingDraftsSubscription.close();
  super.dispose();
}
```

Source: [app_router.dart](../lib/app/app_router.dart#L118-L123).

The only current Dart branch that clears the owner is inside the unused
provider described in Phase 1.

**Impact**

- Wallet notifications received while signed out are still tagged with the
  previous UID.
- An anonymous account that was signed out can accumulate drafts that may never
  be recoverable.
- On a shared device, purchases made by the next device user can be attributed
  locally to the previous Firebase owner.
- An in-flight old-user synchronization can race with a new login because the
  future itself is not canceled when `_AuthenticatedHome` is disposed.

This is not a proven cross-user Firestore read leak. Queue reads are filtered by
the currently active owner. It is still a serious local privacy and attribution
defect.

**Possible fixes**

1. Clear the owner only inside the logout button callback.
2. Clear it inside `AuthController.signOut()` before Firebase sign-out.
3. Add one application-lifetime auth/native coordinator that sets the owner for
   a signed-in UID and clears it whenever resolved auth state becomes null.
4. Combine options 2 and 3 for immediate action plus a defensive fallback.

**Recommended fix**

Use option 4. The auth/native coordinator should be the source of truth, while
`AuthController.signOut()` should clear eagerly to close the window before the
auth stream emits. Cleanup failure must not prevent Firebase sign-out.

The coordinator also needs an owner generation or cancellation token so a sync
started for UID A cannot set UID A again after auth has moved to UID B.

**Required tests**

- Signed-in -> signed-out clears the owner exactly once.
- Google sign-out failure still clears native ownership and attempts Firebase
  sign-out.
- A sync for user A finishing after user B signs in cannot restore user A as
  active owner.
- Notifications received while signed out are not queued.

### 5.2 🔥 Notification-derived financial data is plaintext and backed up

The queue stores these fields in a normal SQLite database:

- Firebase UID;
- source notification key;
- merchant and normalized merchant;
- amount in minor units;
- captured and occurred timestamps;
- synchronization status.

See
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L108-L125).

The active UID is also stored in ordinary `SharedPreferences` at
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L23-L26).

The application manifest does not set `android:allowBackup="false"`,
`android:fullBackupContent`, or `android:dataExtractionRules`:

```xml
<application
    android:label="${appName}"
    android:name="${applicationName}"
    android:icon="@mipmap/launcher_icon">
```

Source: [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L2-L6).

Consequently, the database and preferences participate in Android's default
backup behavior unless platform or device policy prevents it.

**Threat model**

- A device backup can contain merchant and amount history outside Firestore's
  access controls.
- Rooted-device, forensic, or debug-backup access can read the queue directly.
- Synced records remain present, so exposure grows over time.
- Clearing app auth does not delete old owner rows.

**Possible fixes**

1. Disable Android backup for the entire app.
2. Keep backup enabled but exclude the queue database and active-owner
   preferences with backup and data-extraction XML rules.
3. Place queue storage under `noBackupFilesDir`.
4. Encrypt the database using a key protected by Android Keystore.
5. Minimize retained fields and delete acknowledged rows.

**Recommended fix**

Apply defense in depth:

1. Immediately exclude the database and owner preference from both legacy
   `fullBackupContent` and Android 12+ `dataExtractionRules`. Disabling all app
   backup is reasonable because authoritative data already lives in Firestore.
2. Encrypt the queue with a maintained SQLCipher integration and an
   Android-Keystore-protected key.
3. Delete acknowledged rows after a short, documented retry grace period.
4. Clear owner-specific local rows when the product's account-removal policy
   requires it.

**Acceptance criteria**

- Android backup inspection contains neither queue rows nor the active UID.
- Pulling the raw database does not reveal merchant or amount plaintext.
- A retention test proves acknowledged rows are removed on schedule.
- Key invalidation fails closed and presents a recoverable, privacy-safe state.

### 5.3 ⚠️ Debug logging exposes raw payment details

Debuggable builds log the notification key, timestamp, title, text, big text,
subtext, and summary:

```kotlin
if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE == 0) return

Log.d(
    DIAGNOSTIC_TAG,
    """
    key=${notification.key}
    title=${extras.getCharSequence(Notification.EXTRA_TITLE)}
    text=${extras.getCharSequence(Notification.EXTRA_TEXT)}
    bigText=${extras.getCharSequence(Notification.EXTRA_BIG_TEXT)}
    """.trimIndent(),
)
```

Source:
[GoogleWalletNotificationListener.kt](../android/app/src/main/kotlin/ch/stutz/app/GoogleWalletNotificationListener.kt#L56-L73).

The release-build guard is good, but debug builds often run on real devices
with real Wallet notifications. Logcat can be collected by development tools,
bug reports, or shared support logs.

**Recommended fix**

Remove raw logging. If diagnostics are required, log only non-sensitive parser
metadata, for example:

```text
wallet_notification parserVersion=2 parsed=true hasTitle=true
```

Do not log notification keys, merchants, amounts, timestamps, UIDs, or raw
text. Add a test or static check that banned fields do not appear in diagnostic
logging.

### 5.4 ⚠️ Synced rows are marked, not purged

Acknowledgement updates `synced_at`:

```kotlin
database.writableDatabase.update(
    TABLE_DRAFTS,
    values,
    "owner_id = ? AND draft_id IN ($placeholders)",
    arrayOf(ownerId, *draftIds.toTypedArray()),
)
```

Source:
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L89-L103).

No code deletes old synchronized rows. The queue therefore functions as an
undeclared second financial history store.

**Possible policies**

- Delete immediately after Firestore acknowledgement.
- Retain for a short fixed period, such as 24 hours, then purge.
- Retain only opaque deduplication hashes and remove merchant/amount fields.

**Recommended policy**

Delete full rows after acknowledgement. Firestore insertion is already
idempotent and the local queue's purpose is delivery, not archival. If replay
protection requires longer retention, retain only the minimum hash and expiry
time.

### 5.5 ⚠️ A redundant global uniqueness constraint can suppress another owner

The schema declares both:

```sql
source_dedupe_key TEXT NOT NULL UNIQUE,
...
UNIQUE (owner_id, source_dedupe_key)
```

Source:
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L112-L124).

The column-level `UNIQUE` applies globally, making the composite owner-scoped
constraint redundant. If Android reuses the same notification key for a later
owner, `CONFLICT_IGNORE` silently drops that owner's draft.

**Recommended fix**

Create database version 3 that removes the column-level uniqueness and retains
only `UNIQUE(owner_id, source_dedupe_key)`. Add a migration test with two owners
and the same source key.

### 5.6 ⚠️ SQLite work runs synchronously on the platform thread

`MainActivity` calls queue reads and writes directly from the MethodChannel
handler:

```kotlin
"acknowledgeSyncedDrafts" -> {
    captureQueue.acknowledgeSyncedDrafts(draftIds)
    result.success(null)
}

"listUnsyncedDrafts" -> result.success(
    captureQueue.listUnsyncedDrafts().map { draft -> /* ... */ },
)
```

Source: [MainActivity.kt](../android/app/src/main/kotlin/ch/stutz/app/MainActivity.kt#L44-L82).

Small queues will usually be fast, but an indefinitely growing queue can block
the Android main thread. SQLite and mapping exceptions are also not translated
into stable application-specific platform error codes. Flutter's embedding may
surface an uncaught handler exception as a generic `PlatformException`; callers
cannot distinguish corruption, storage exhaustion, and invalid input.

**Recommended fix**

- Execute queue I/O on a single `Dispatchers.IO` coroutine scope or dedicated
  executor.
- Return results on the main thread.
- Catch expected storage exceptions and use stable codes such as
  `queue_read_failed`, `queue_write_failed`, and `queue_corrupt`.
- Keep error details free of payment data.
- Cancel the scope/executor when the activity is destroyed.

### 5.7 ⚠️ Active-notification capture can report success when no listener exists

The static function is a no-op when `activeInstance` is null, while
`MainActivity` still returns success:

```kotlin
fun captureActiveNotifications() {
    activeInstance?.captureActiveNotificationsInternal()
}
```

Source:
[GoogleWalletNotificationListener.kt](../android/app/src/main/kotlin/ch/stutz/app/GoogleWalletNotificationListener.kt#L81-L83).

This can make a requested scan appear successful while the notification
listener service is disconnected.

**Recommended fix:** Return a boolean or structured status from the native call
and expose `listener_unavailable` separately from `permission_denied`. A later
listener connection already triggers a scan, so this is reliability feedback,
not necessarily data loss.

### 5.8 ✅ Listener configuration and parser behavior are sound

The service is protected by
`android.permission.BIND_NOTIFICATION_LISTENER_SERVICE`, filters the Google
Wallet package, rejects group-summary notifications, and performs event-driven
work rather than polling. No custom wake lock is acquired.

The parser correctly uses `BigDecimal`, rejects non-positive values, and
requires exact two-decimal conversion:

```kotlin
val amount = BigDecimal(amountText.replace(',', '.'))
    .setScale(2, RoundingMode.UNNECESSARY)
return amount.movePointRight(2).longValueExact()
```

Source:
[GoogleWalletNotificationListener.kt](../android/app/src/main/kotlin/ch/stutz/app/GoogleWalletNotificationListener.kt#L152-L171).

`EventChannel.onCancel` clears the callback, and `onDestroy` provides a second
cleanup path in [MainActivity.kt](../android/app/src/main/kotlin/ch/stutz/app/MainActivity.kt#L16-L42).

These choices should be preserved.

### 5.9 ⚠️ Debug wakelock activation is unawaited

Startup invokes `WakelockPlus.enable()` without awaiting or handling plugin
errors:

```dart
if (kDebugMode) {
  WakelockPlus.enable();
}
```

Source: [main.dart](../lib/main.dart#L15-L17).

This is debug-only and not a production battery issue. It can still create an
uncaught asynchronous plugin error in development and makes startup behavior
depend on a nonessential plugin.

**Recommended fix:** Remove it and rely on the existing scrcpy development
task, or call it with explicit error handling using `unawaited` and a redacted
debug log.

---

## 6. Phase 3: Firebase integration and data layer

### 6.1 🔥 Persisted money uses binary floating point

Financial values are represented as `double` across the persisted model:

```dart
const factory AppTransaction({
  required String id,
  required String expenseNodeId,
  required double amount,
  required DateTime dateTime,
  String? note,
}) = _AppTransaction;
```

Source:
[app_transaction.dart](../lib/features/transactions/domain/entities/app_transaction.dart#L7-L14).

The same pattern appears in:

- `ExpenseNode.plannedAmount` at
  [expense_node.dart](../lib/features/budget/domain/entities/expense_node.dart#L10-L21);
- `IncomeSource.amount` at
  [income_source.dart](../lib/features/budget/domain/entities/income_source.dart#L9-L17);
- `TransactionMonthSummary.categoryTotals` at
  [transaction_month_summary.dart](../lib/features/transactions/domain/entities/transaction_month_summary.dart#L3-L12).

Month aggregates increment those doubles directly:

```dart
'categoryTotals': {
  t.expenseNodeId: FieldValue.increment(t.amount),
},
```

Source:
[transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L153-L161).

**Why this matters**

Decimal fractions such as CHF 0.10 are not exactly representable as binary
floating point. The familiar example is:

```text
0.1 + 0.2 = 0.30000000000000004
```

Formatting may hide the residual, but persisted category totals, subtraction,
zero-removal logic, equality, backups, and reconciliation still operate on it.
The current `_setMonthSummary` removes entries only when `value <= 0`, so a
small positive residual can survive when a category should return to zero.

This does not imply that every ten transactions visibly lose five cents. The
real defect is that arithmetic correctness depends on binary approximation and
operation order, which is inappropriate for a ledger.

**Recommended target model**

```dart
@freezed
abstract class AppTransaction with _$AppTransaction {
  const factory AppTransaction({
    required String id,
    required String expenseNodeId,
    required int amountMinor,
    required DateTime dateTime,
    String? note,
  }) = _AppTransaction;
}
```

Use integer CHF minor units for:

- transaction amounts;
- income amounts;
- planned expense amounts;
- category totals;
- monthly and yearly summary totals;
- all deltas applied during update/delete.

Convert to `double` only for a visual ratio, never for persisted money.

**Annual proration requires a product decision**

An annual amount may not divide evenly by 12. For example, CHF 100.00 is
10,000 cents, and `10,000 / 12` is not an integer. Choose and document one
policy:

1. Keep annual amounts exact and display a rounded monthly estimate only.
2. Round each monthly equivalent using a named rule such as half-up.
3. Distribute remainder cents across months when creating monthly allocations.

Option 1 best matches the current planning model because annual expenses are
not actual recurring transaction postings.

**Migration plan**

1. Create a verified `scope=all` backup, not only a transaction backup.
2. Scan every monetary field and reject non-finite, negative, or out-of-range
   values before writing anything.
3. Convert source values with an explicit policy such as
   `round(value * 100)` and record every rounded discrepancy.
4. Rebuild `transactionMonths` from migrated transaction source documents;
   do not merely multiply existing derived totals.
5. Produce a per-user reconciliation report comparing transaction-derived
   totals before and after migration.
6. Support a temporary dual-read deployment if old and new app versions can
   overlap.
7. Deploy rules for the new integer schema only after compatible clients are
   available.
8. Remove legacy reads after the migration is verified.

**Acceptance criteria**

- No persisted financial field uses `double`.
- Replaying add/update/delete operations leaves exact integer totals.
- Every month summary equals a fresh reduction of its transaction documents.
- Annual proration tests cover non-divisible cent amounts.

### 6.2 🔥 Firestore rules enforce ownership, not schemas

The entire ruleset is currently:

```javascript
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null
    && request.auth.uid == userId;
}
```

Source: [firestore.rules](../firestore.rules#L1-L9).

This correctly prevents Alice from reading or writing Bob's path. It still
allows Alice's client to write any shape under Alice's path, including:

- negative, fractional, or non-finite amounts;
- missing transaction dates or category IDs;
- arbitrary transaction month counts and totals;
- invalid enum names;
- dangling category references;
- draft state transitions from `discarded` back to `pending`;
- unknown collections and fields;
- invalid merchant rules.

The rules test proves only ownership and writes to a `budgets` collection that
the application does not use:
[firestore.rules.test.js](../test/firestore.rules.test.js#L31-L58).

**Why UI validation is insufficient**

- Old app versions remain able to write old schemas.
- A compromised or modified client bypasses Flutter validation.
- Bugs in repository code run with the same Firebase permissions as valid UI
  operations.
- Derived month summaries are currently client-authoritative.

**Possible architectures**

#### Option A: Trusted ledger mutation backend

Clients call a Cloud Function or another trusted API for add/update/delete and
draft confirmation. The backend writes the source transaction and derived
summary atomically with Admin privileges. Client rules deny writes to
`transactionMonths`.

Advantages:

- strongest aggregate integrity;
- central idempotency keys;
- simpler security rules for derived documents;
- consistent validation across app versions.

Tradeoffs:

- backend deployment and operational cost;
- offline writes require a durable command queue and clear pending state;
- more infrastructure than direct Firestore writes.

#### Option B: Direct client transaction writes, no persisted summaries

Clients write strictly validated source transactions. Dashboard totals are
queried or calculated from source records.

Advantages:

- source of truth is simple;
- no summary corruption.

Tradeoffs:

- more reads and client computation;
- large histories require carefully bounded queries or Firestore aggregation
  features.

#### Option C: Direct client writes plus client-maintained summaries

Rules use strict schemas and `getAfter()` checks to constrain multi-document
writes.

Advantages:

- preserves current offline/client architecture.

Tradeoffs:

- rules become complex and difficult to prove;
- validating arbitrary category-total maps is fragile;
- clients still author both source and derived truth.

**Recommended architecture**

Use option A for transaction and summary mutations if Stutz is intended for
production financial use. If backend infrastructure is currently out of scope,
option B is safer than pretending option C is fully tamper-resistant.

**Illustrative rules direction**

The following is a design sketch, not a drop-in complete ruleset:

```javascript
function owns(userId) {
  return request.auth != null && request.auth.uid == userId;
}

function validTransaction(userId) {
  let data = request.resource.data;
  return data.keys().hasOnly(
      ['expenseNodeId', 'amountMinor', 'dateTime', 'note'])
    && data.keys().hasAll(['expenseNodeId', 'amountMinor', 'dateTime'])
    && data.expenseNodeId is string
    && data.expenseNodeId.size() > 0
    && data.amountMinor is int
    && data.amountMinor > 0
    && data.dateTime is timestamp
    && (!('note' in data) || data.note == null || data.note is string)
    && exists(/databases/$(database)/documents/users/$(userId)/expense_nodes/$(data.expenseNodeId));
}

match /users/{userId}/transactions/{transactionId} {
  allow read: if owns(userId);
  allow create, update: if owns(userId) && validTransaction(userId);
  allow delete: if owns(userId);
}

match /users/{userId}/transactionMonths/{monthId} {
  allow read: if owns(userId);
  allow write: if false; // Trusted backend only.
}
```

Equivalent schemas and transition checks are needed for expense nodes, incomes,
drafts, and merchant rules. A final catch-all should deny unknown paths.

**Required emulator test matrix**

- own read succeeds; cross-user and unauthenticated access fail;
- missing, extra, and incorrectly typed fields fail;
- zero and negative amounts fail;
- fractional minor-unit amounts fail;
- nonexistent and non-variable category references fail;
- illegal draft state transitions fail;
- clients cannot forge summary documents;
- valid create/update/delete flows still succeed.

### 6.3 🔥 Manual transaction creation is not idempotent

The repository uses a batch that overwrites the transaction document and
always increments the month summary:

```dart
Future<void> addTransaction(AppTransaction t) async {
  final transactionReference = _collection.doc(t.id);
  // ...
  batch.set(transactionReference, TransactionMapper.toDocument(t));
  batch.set(monthReference, {
    'transactionCount': FieldValue.increment(1),
    'categoryTotals': {
      t.expenseNodeId: FieldValue.increment(t.amount),
    },
  }, SetOptions(merge: true));
  await batch.commit();
}
```

Source:
[transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L147-L162).

**Concrete failure example**

Initial state:

```text
transaction tx-1: absent
month count: 0
food total: CHF 0.00
```

First request adds `tx-1` for CHF 20.00:

```text
transaction tx-1: CHF 20.00
month count: 1
food total: CHF 20.00
```

The same ID is replayed:

```text
transaction tx-1: CHF 20.00
month count: 2
food total: CHF 40.00
```

Only one source transaction exists, but the derived ledger reports two.

UUID generation makes accidental collisions unlikely. It does not solve retry
semantics after an uncertain network result, duplicate UI commands, tests,
imports, or future integrations that supply IDs.

**Recommended behavior**

A create command must distinguish:

1. document absent: create and increment once;
2. document present with identical payload: treat as successful replay;
3. document present with different payload: reject as an ID collision;
4. intentional replacement: require the explicit update path, which reconciles
   old and new month/category deltas.

**Implementation direction**

Use a Firestore transaction that reads the transaction document before any
writes. For an absent document, read the month summary, create the source, and
apply the exact delta. For an existing document, compare canonical fields and
return or throw without touching the summary.

After the minor-unit migration, all comparisons and deltas should be integer
based.

**Required tests**

- first create increments once;
- exact replay is a no-op and succeeds;
- conflicting replay throws and preserves both source and summary;
- concurrent creates with one ID produce one source and one increment;
- retry after an ambiguous transport failure reconciles correctly.

### 6.4 ✅ Imported draft confirmation is already idempotent

The draft repository checks status before writing:

```dart
if (draft.status == TransactionDraftStatus.saved) {
  final savedTransactionId = draft.savedTransactionId;
  if (savedTransactionId == null) {
    throw StateError(/* ... */);
  }
  return savedTransactionId;
}
```

Source:
[transaction_draft_repository.dart](../lib/features/notification_import/data/transaction_draft_repository.dart#L91-L103).

Because the draft status, imported transaction, summary, and merchant rule are
written in one Firestore transaction, a normal retry sees `saved` and returns
without incrementing again.

**Remaining defense-in-depth gap:** If permissive rules allow another client to
create `import_<draftId>` while the draft remains pending, confirmation can
overwrite that document. Strict rules and a transaction-document collision
read should protect against this malformed state.

### 6.5 🔥 Anonymous users can permanently lose their ledger

The budget screen's logout icon calls sign-out immediately:

```dart
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await ref.read(authControllerProvider.notifier).signOut();
  },
)
```

Source:
[budget_planning_screen.dart](../lib/features/budget/presentation/budget_planning_screen.dart#L54-L62).

Firebase anonymous accounts have no user-known credential. Once the local auth
session is removed, the user generally cannot recover that UID or its nested
Firestore ledger. Reinstallation has the same recovery problem.

**Recommended product flow**

When `FirebaseAuth.currentUser.isAnonymous` is true:

1. Explain that the current data belongs to a temporary account.
2. Offer "Link Google account" as the primary action.
3. Use `linkWithCredential`, not `signInWithCredential`, so the UID and existing
   Firestore data remain attached to the account.
4. Offer a tested export before any destructive sign-out if account linking is
   declined.
5. Require explicit confirmation that access may be permanent lost.

Handle `credential-already-in-use` as a deliberate account-merge problem; do
not silently switch UIDs and strand either ledger.

### 6.6 🔥 Google sign-out failure prevents Firebase sign-out

Current ordering is:

```dart
Future<void> signOut() async {
  await _googleSignIn.signOut();
  await _auth.signOut();
}
```

Source: [auth_service.dart](../lib/features/auth/data/auth_service.dart#L65-L68).

If Google cleanup throws, Firebase sign-out is never attempted. The UI reports
an error, but the user remains authenticated in the application whose data they
intended to close.

**Recommended policy**

Firebase session termination is authoritative. Attempt Google cleanup, capture
and redact any error, then always attempt Firebase sign-out. Only a Firebase
sign-out failure should mean the application session remains active.

Native owner clearing must be part of the same application command, as
described in Phase 2.

**Required test:** Configure Google sign-out to throw and verify that Firebase
sign-out and native owner cleanup still execute.

### 6.7 ⚠️ Runtime validation stops at inconsistent boundaries

`ExpenseNode` has a useful `validateForWrite()` method, and budget mutations
call it. Other financial entities do not have equivalent write validation.

`TransactionDraftConfirmation` relies only on assertions:

```dart
const TransactionDraftConfirmation({
  required this.amountMinor,
  required this.dateTime,
  required this.expenseNodeId,
  this.note,
}) : assert(amountMinor > 0),
     assert(expenseNodeId != '');
```

Source:
[transaction_draft_confirmation.dart](../lib/features/notification_import/domain/entities/transaction_draft_confirmation.dart#L1-L15).

Assertions are disabled in release builds. `AppTransaction` and `IncomeSource`
also permit invalid values when constructed outside current UI forms.

**Recommended fix**

- Add runtime validation at the application/domain mutation boundary.
- Reject empty IDs, invalid dates, non-positive amounts, overlong notes, and
  unsupported category relationships.
- Throw typed validation exceptions that presentation code can translate into
  safe messages.
- Repeat all security-relevant checks in Firestore rules or the trusted
  backend.

Validation should be layered:

```text
input formatter -> form feedback -> domain command validation
                -> backend/rules validation -> resilient read mapping
```

### 6.8 ⚠️ One malformed document can fail a complete stream or query

Repositories map document lists directly. Examples include:

- expense streams in
  [expense_node_repository.dart](../lib/features/budget/data/expense_node_repository.dart#L31-L38);
- income streams in
  [income_source_repository.dart](../lib/features/budget/data/income_source_repository.dart#L23-L26);
- transaction month summary streams in
  [transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L40-L49).

The transaction mapper also performs an unchecked note cast:

```dart
note: data['note'] as String?,
```

Source: [transaction_mapper.dart](../lib/features/transactions/data/transaction_mapper.dart#L40-L47).

One invalid note type can throw while mapping and put an entire transaction
load into an error state.

**Do not simply discard malformed financial records.** Silent filtering would
make totals look valid while hiding source data.

**Recommended approach**

Return a reconciliation-aware result:

```text
LedgerReadResult<T>
  validRecords
  malformedDocumentIds
  redactedIssueTypes
```

The UI can show valid records plus a prominent warning that some data requires
repair. Send redacted diagnostics, and provide an administrative repair path.
Strict rules should prevent new malformed records while legacy data is cleaned.

### 6.9 ⚠️ Category deletion uses a race-prone check-then-delete sequence

The repository checks for children, checks for referencing transactions, and
then performs a separate delete:

```dart
final childSnapshot = await _collection
    .where('parentId', isEqualTo: id)
    .limit(1)
    .get();

final transactionSnapshot = await _firestore
    // ...
    .where('expenseNodeId', isEqualTo: id)
    .limit(1)
    .get();

await _collection.doc(id).delete();
```

Source:
[expense_node_repository.dart](../lib/features/budget/data/expense_node_repository.dart#L50-L70).

Another client can create a child or transaction after the checks and before
the delete. Firestore client transactions do not make arbitrary collection
queries a convenient invariant boundary.

**Possible fixes**

1. Trusted backend transaction with controlled reference/index records.
2. Maintain explicit reference-count documents transactionally.
3. Archive categories instead of deleting them.
4. Snapshot category names into transactions and permit deletion.

**Recommended fix**

Archive categories with fields such as `archivedAt` and `isSelectable`. Keep
historical IDs resolvable, exclude archived categories from new transaction
pickers, and preserve reporting labels. This is usually a better financial
history model than hard deletion.

### 6.10 ⚠️ Derived month summaries are client-authoritative

The client writes both source transactions and summary documents. Although
normal add/update/delete code uses batches or Firestore transactions, the rules
allow any owner client to write arbitrary totals. Bugs, old versions, and
modified clients can therefore desynchronize summaries from source records.

`_monthCount` and `_setMonthSummary` clamp invalid values rather than proving
that a summary equals its sources:
[transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L240-L290).

**Recommended fix:** Treat transaction documents as the source of truth. Move
summary maintenance to trusted code and retain the existing migration/rebuild
script as a reconciliation tool. Schedule or expose a verification job that
compares every summary with a fresh source reduction.

### 6.11 ✅ Query scoping and update/delete atomicity are generally good

Positive data-layer choices include:

- transaction history uses cursor pagination;
- direct month navigation queries a bounded date interval;
- dashboard summaries query one selected year;
- category detail queries combine category and date bounds;
- transaction update and delete read the old source and reconcile affected
  month/category summaries in Firestore transactions;
- Zurich month boundaries are centralized;
- a composite category/date index is declared;
- notification upload acknowledges SQLite only after all Firestore upserts
  succeed.

These behaviors should be retained while changing the money representation and
write authority.

---

## 7. Phase 4: Performance, UI/UX, and Android accessibility

### 7.1 ⚠️ Category drill-down fetches and renders an unbounded period

The repository executes an unbounded category/date query:

```dart
final snapshot = await _collection
    .where('expenseNodeId', isEqualTo: categoryId)
    .where('dateTime', isGreaterThanOrEqualTo: periodStart)
    .where('dateTime', isLessThan: periodEnd)
    .orderBy('dateTime', descending: true)
    .get();
```

Source:
[transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L132-L145).

The detail view then eagerly inserts every row into a `Column`:

```dart
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // ...
    ...transactions.map(_TransactionRow.new),
  ],
);
```

Source:
[dashboard_category_detail_screen.dart](../lib/features/dashboard/presentation/dashboard_category_detail_screen.dart#L445-L507).

Monthly datasets may be modest, but a heavily used annual category can grow
without a bound. Every record is fetched, mapped, retained, and built at once.

**Recommended fix**

1. Add a repository cursor API with a fixed page size.
2. Store the page cursor and loading/error footer in an `AsyncNotifier.family`.
3. Render transactions with `ListView.builder`, `SliverList`, or the containing
   page's sliver structure.
4. Preserve date/category ordering in the query.
5. Add a retryable load-more state and a test with several pages.

### 7.2 ⚠️ Every history page reprocesses all retained transactions

After each page, the notifier merges all loaded records and calls
`TransactionGrouper.groupByDay` over the complete retained list:

```dart
final transactions = _mergeTransactions(
  current.rawTransactions,
  docs.map(TransactionMapper.fromDocument).toList(),
);

state = AsyncData(
  current.copyWith(
    rawTransactions: transactions,
    groupedDays: _groupTransactions(transactions, categories),
    // ...
  ),
);
```

Source:
[transaction_service.dart](../lib/features/transactions/application/transaction_service.dart#L148-L188).

The grouper sorts before grouping, so each page performs work proportional to
all records loaded so far rather than only the new page. Across many pages, the
cumulative work grows substantially faster than a single linear pass.

**Possible fixes**

- Incrementally merge page groups into the oldest/newest boundary day.
- Keep transactions in an ordered map keyed by local calendar date.
- Query and cache one selected month at a time instead of retaining an
  arbitrarily large history window.

**Recommended fix**

Given that month jumping is a primary interaction, use month-window queries as
the application cache unit. Maintain the selected month and immediate
neighbors, and page within an unusually large month only when necessary. This
reduces memory and makes direct month navigation the natural data model.

If retaining global pagination, add an incremental grouping method with tests
for a page that shares its first/last day with an existing group.

### 7.3 ⚠️ The budget tree is eagerly rendered

`BudgetPlanningScreen` wraps all sections in a `SingleChildScrollView`, and the
expense tree recursively creates nested columns:
[budget_planning_screen.dart](../lib/features/budget/presentation/budget_planning_screen.dart#L27-L49)
and
[expense_item_row.dart](../lib/features/budget/presentation/widgets/expense_item_row.dart#L128-L160).

This is acceptable for small personal budgets, but an arbitrarily deep or wide
tree creates every expanded descendant widget at once.

**Recommended fix:** Profile before refactoring. If real datasets show frame or
memory pressure, flatten visible expanded nodes into a list and render with a
`SliverList`. Preserve expansion state by node ID. This is lower priority than
the unbounded transaction detail because personal category trees are normally
much smaller than transaction histories.

### 7.4 ⚠️ Sheets remain dismissible during mutations

Callers attempt to disable closing while saving:

```dart
onClose: isSaving ? null : () => Navigator.pop(context),
```

Source:
[add_transaction_dialog.dart](../lib/features/transactions/presentation/add_transaction_dialog.dart#L140-L146)
and
[transaction_draft_review_sheet.dart](../lib/features/notification_import/presentation/transaction_draft_review_sheet.dart#L227-L233).

However, `AppBottomSheet` interprets null as "use the default pop":

```dart
onPressed: onClose ?? () => Navigator.pop(context),
```

Source: [app_bottom_sheet.dart](../lib/shared/widgets/app_bottom_sheet.dart#L71-L78).

Barrier taps, swipe-down dismissal, and Android back are also not disabled by
mutation state.

**Failure scenario**

1. User taps Save.
2. Firestore write begins.
3. User closes or swipes down the sheet.
4. The write later succeeds.
5. The UI looked canceled, but the financial record was created.

**Recommended fix**

- Replace ambiguous nullable `onClose` semantics with an explicit `canClose`.
- Wrap transactional sheet content in `PopScope(canPop: !isSaving)`.
- Disable the close button during saving.
- For form sheets, set `isDismissible: false` and `enableDrag: false`, or expose
  dynamic route dismissal state through a controller.
- Keep picker/informational sheets dismissible.

Default Navigator back behavior is otherwise appropriate; the absence of a
global `PopScope` is not itself a defect.

### 7.5 ⚠️ The pending-draft touch target is 28 px high

The indicator's actual `InkWell` contains a 28-by-28 visual target:

```dart
child: SizedBox(
  width: count < 10 ? 28 : null,
  height: 28,
  // ...
),
```

Source:
[pending_transaction_drafts_indicator.dart](../lib/features/notification_import/presentation/pending_transaction_drafts_indicator.dart#L16-L49).

Its outer padding is horizontal only, so the tappable region does not meet the
48-by-48 Material accessibility target.

**Recommended fix:** Keep the 28 px visual badge, but center it inside a
48-by-48 `SizedBox` that owns the `InkWell` and semantics. Add a widget test
that inspects the hit-test size.

### 7.6 ⚠️ Some controls need stronger semantics and feedback

The pending indicator has a useful `Semantics` label and many icon buttons have
tooltips. Gaps remain:

- the logout icon has no tooltip at
  [budget_planning_screen.dart](../lib/features/budget/presentation/budget_planning_screen.dart#L54-L62);
- financial progress is primarily communicated through color and compact text;
- abbreviated CHF values may not be pronounced naturally by screen readers;
- the global theme removes splash and highlight feedback:

```dart
splashFactory: NoSplash.splashFactory,
highlightColor: Colors.transparent,
```

Source: [app_theme.dart](../lib/core/theme/app_theme.dart#L91-L95).

Removing all pressed-state feedback weakens Android affordance and can make a
slow action appear unresponsive.

**Recommended fix**

- Restore Material's default interaction feedback or use a subtle themed
  `overlayColor`.
- Add tooltips to every icon-only command.
- Add semantic labels such as "20 Franken 50 ausgegeben, 40 Prozent des
  Budgets" around progress summaries.
- Verify TalkBack traversal, large text at 200%, and contrast in both normal and
  over-budget states.

### 7.7 ⚠️ The cloud indicator reports network interface state as sync state

`connectivity_plus` is used as follows:

```dart
return Connectivity().onConnectivityChanged;
// ...
return results.contains(ConnectivityResult.none);
```

Source:
[connectivity_provider.dart](../lib/core/connectivity/connectivity_provider.dart#L6-L23).

The UI then says:

```text
Du bist offline. Daten werden lokal gespeichert.
```

Source: [cloud_status_icon.dart](../lib/shared/widgets/cloud_status_icon.dart#L10-L18).

Wi-Fi or cellular availability does not prove that Firestore is reachable or
that writes are synchronized. A captive portal, DNS failure, blocked endpoint,
expired auth state, or backend outage can all appear "online."

**Recommended state model**

Represent backend state rather than only interface state:

```text
synced
pendingWrites
fromCache
operationFailed
unknown
```

Use Firestore snapshot metadata (`hasPendingWrites`, `isFromCache`) and mutation
results. Connectivity can remain a secondary hint, not the source of truth.
Change copy so it never promises that data is safely stored or synchronized
without backend evidence.

### 7.8 ⚠️ Amount input accepts more than two decimals

`parsePositiveAmount` accepts any finite positive `double`, and the transaction
and draft fields use only a decimal keyboard. For draft confirmation, the UI
then performs:

```dart
amountMinor: (amount * 100).round(),
```

Source:
[transaction_draft_review_sheet.dart](../lib/features/notification_import/presentation/transaction_draft_review_sheet.dart#L174-L191).

Input such as `1.999` is accepted and silently rounded to CHF 2.00 for a draft;
manual transactions currently persist `1.999` as a double. A decimal keyboard
is not an input constraint.

**Recommended fix**

Parse currency text directly into minor units without first converting to
`double`:

```dart
int? parsePositiveMinorUnits(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(normalized);
  if (match == null) return null;

  final major = int.tryParse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  final minor = int.tryParse(fraction);
  if (major == null || minor == null) return null;

  final value = major * 100 + minor;
  return value > 0 ? value : null;
}
```

Add overflow limits appropriate to Firestore integers and the product. Use the
same parser in all income, expense, transaction, and draft forms.

### 7.9 ⚠️ Fonts are fetched at runtime unless cached

The theme constructs Manrope and Inter through `google_fonts` in
[app_theme.dart](../lib/core/theme/app_theme.dart#L50-L89), but `pubspec.yaml`
does not bundle font assets.

This creates startup and offline variability: first render can use fallback
metrics, network retrieval may fail, and text layout can differ between runs.

**Recommended fix:** Bundle the exact font files, declare them in
`pubspec.yaml`, and disable runtime fetching. Test the welcome, dashboard, and
form screens in airplane mode after clearing app data.

### 7.10 ✅ Core Android UI patterns are generally sound

Positive implementation details include:

- transaction history uses a lazily built positioned list;
- main tabs remain mounted in an `IndexedStack`, preserving scroll and
  expansion state;
- forms use decimal keyboards and positive-value checks;
- modal content responds to keyboard insets;
- most standard buttons use Material components with suitable default sizes;
- date input is constrained to a defined range;
- month navigation provides tooltips and explicit loading/error states;
- form controllers are managed by hooks or disposed state objects.

These are worth preserving while the specific defects above are corrected.

---

## 8. Phase 5: Test coverage and quality

### 8.1 ✅ The tests are behavior-oriented

The suite is not dominated by trivial assertions. It covers:

- budget calculations and annual/monthly conversion;
- tree construction, sorting, missing parents, duplicates, and cycles;
- amount parsing, including zero, negative, invalid, and non-finite values;
- Firestore mapper conversion and malformed fields;
- transaction grouping and Zurich month boundaries;
- transaction pagination and direct month-window loading;
- Riverpod mutation success and failure state;
- auth routing and onboarding persistence;
- notification upload-before-acknowledgement ordering;
- synchronization coalescing;
- merchant category suggestions;
- draft review and shared widget behavior;
- backup encoding, manifests, checksums, and migration calculations;
- observed Wallet notification parsing formats.

The current Flutter test run passed 140 tests. Backup and migration unit suites
also passed.

### 8.2 🔥 Risk-weighted coverage is inadequate

Aggregate line coverage is 61.32%, but overall percentage hides the important
gap:

| Production file | Measured line coverage |
| --- | ---: |
| `transaction_repository.dart` | 0.67% |
| `transaction_draft_repository.dart` | 2.63% |
| `auth_service.dart` | 8.00% |
| `notification_capture_method_channel.dart` | 13.16% |
| `app_router.dart` | 23.89% |

These files own transaction/source-summary atomicity, draft confirmation,
sign-out, native protocol mapping, and owner lifecycle. Pure calculators are
well tested while the financial mutation boundary is almost untested.

**Recommendation:** Use risk-based coverage goals. An 80% global threshold is
less valuable than requiring near-complete branch coverage for ledger mutation
and auth/native lifecycle code.

### 8.3 ⚠️ Repository tests replace the concrete repositories with fakes

Application notifier tests use handwritten fake repositories, for example in
[transaction_mutations_test.dart](../test/features/transactions/application/transaction_mutations_test.dart#L70-L113).

That is appropriate for verifying notifier state and invalidation. It cannot
verify the actual Firestore batch/transaction implementation, field paths,
merge behavior, retries, or aggregate deltas.

**Recommended test layers**

1. Pure unit tests for calculators, mappers, and delta functions.
2. Provider tests with small fakes for application state behavior.
3. Firestore emulator integration tests for concrete repositories and rules.
4. Kotlin JVM/Robolectric or instrumentation tests for the queue and channel.
5. A small end-to-end Android flow for capture -> queue -> Dart -> Firestore
   draft -> confirmation.

Mockito or Mocktail is optional. Handwritten fakes are often clearer for the
small interfaces in this repository. The missing element is concrete boundary
testing, not a particular mocking package.

### 8.4 ⚠️ Rules tests validate only isolation

The rules test creates `users/alice/budgets/main`, verifies Alice can access it,
and verifies Bob/unauthenticated contexts cannot. This is useful but no longer
sufficient once collection schemas are introduced.

Source: [firestore.rules.test.js](../test/firestore.rules.test.js#L24-L58).

Add table-driven tests for every collection and operation. Every allow test
should have nearby deny cases for:

- wrong type;
- missing field;
- extra field;
- invalid enum;
- zero/negative amount;
- nonexistent category;
- immutable field mutation;
- illegal status transition;
- direct month-summary write.

### 8.5 ⚠️ Native queue behavior has no automated coverage

The Kotlin suite tests only `GoogleWalletNotificationParser`. It does not test:

- queue behavior with no active owner;
- owner isolation;
- duplicate notification keys across owners;
- acknowledgement and retention;
- schema migration from database version 1 to 2;
- database corruption/error mapping;
- MethodChannel argument and exception behavior;
- EventChannel listener replacement and cancellation.

The attempted local Gradle run did not execute because task configuration
failed on a cross-drive Flutter plugin path. This environment issue should be
fixed locally, but CI on Linux should also run the native suite independently
so workstation layout cannot hide regressions.

### 8.6 Recommended high-risk test matrix

#### Transaction repository

| Scenario | Expected result |
| --- | --- |
| New ID | One transaction, count +1, exact category delta. |
| Exact replay | Success with no additional summary change. |
| Conflicting ID | Typed collision error; no writes. |
| Update in same category/month | Count unchanged; total changes by exact delta. |
| Update to another category | Old total decreases, new total increases. |
| Update to another month | Old count -1, new count +1, both totals reconciled. |
| Delete existing | Source removed and summary decremented once. |
| Delete missing | Idempotent no-op. |
| Concurrent creates | Exactly one accepted create. |

#### Draft repository

| Scenario | Expected result |
| --- | --- |
| Pending confirmation | Draft saved, one imported source, one summary delta, one rule update. |
| Saved replay | Returns saved ID without writes. |
| Discarded confirmation | Rejected. |
| Missing saved ID | Reconciliation error surfaced. |
| Existing conflicting imported source | Rejected without aggregate mutation. |
| Invalid release-mode confirmation | Rejected by runtime validation. |

#### Auth and native owner

| Scenario | Expected result |
| --- | --- |
| Normal sign-out | Native owner cleared, Firebase signed out, Google cleaned up. |
| Google cleanup fails | Native owner cleared and Firebase still signed out. |
| Firebase sign-out fails | UI remains authenticated and shows retryable error. |
| Anonymous sign-out request | Linking/export warning shown before destructive action. |
| User switch during sync | Old sync cannot restore old owner. |

#### UI and accessibility

| Scenario | Expected result |
| --- | --- |
| Save in progress | Close, swipe, barrier, and back cannot dismiss. |
| Draft badge | Hit target is at least 48 by 48 logical pixels. |
| Amount with 3 decimals | Inline validation rejects it. |
| TalkBack | Amount/progress semantics are meaningful and ordered. |
| 200% text scale | No clipped amount, action, or navigation labels. |

---

## 9. Phase 6: CI/CD and release engineering

### 9.1 ✅ The main Flutter quality gate is solid

The test job runs on pushes and pull requests to `main` and performs:

- dependency resolution;
- formatting verification;
- static analysis;
- Riverpod/Freezed generation;
- generated-file diff verification;
- Flutter tests;
- npm installation;
- Firestore rules tests.

Source: [deploy_android.yml](../.github/workflows/deploy_android.yml#L18-L43).

APK and AAB builds both depend on this test job, and pull requests do not create
release binaries. Release signing, shrinking, GitHub release upload, and Play
internal-track upload are configured.

### 9.2 ⚠️ Existing test suites are not CI gates

The repository defines:

```json
"test:backup": "node --test test/firestore-backup.test.js",
"test:backup:emulator": "...",
"test:migration": "node --test test/migrate-transaction-months.test.js"
```

Source: [package.json](../package.json#L5-L12).

The workflow runs only `test:rules`. It omits:

- backup unit tests;
- backup emulator integration tests;
- transaction-month migration tests;
- Android/Kotlin unit tests.

This allows a release to pass CI even if backup/restore safety or Wallet parsing
is broken.

**Recommended fix:** Add all fast unit suites to every PR. Run emulator backup
integration on PRs when runtime remains acceptable, or at minimum on `main` and
release tags. Run `./android/gradlew testDebugUnitTest` on every PR.

### 9.3 ⚠️ There is no coverage threshold

CI runs `flutter test`, not `flutter test --coverage`, and does not inspect
critical-file coverage. The current 61.32% aggregate and near-zero repository
coverage therefore produce a green build.

**Recommended fix**

- Generate LCOV in CI.
- Enforce a reasonable global floor to prevent regression.
- More importantly, enforce explicit floors for ledger repositories, auth, and
  the native gateway.
- Treat branch/scenario coverage as the goal; do not add meaningless lines only
  to satisfy a percentage.

### 9.4 ⚠️ Flutter and Gradle dependencies are not effectively cached

The workflow caches npm through `actions/setup-node`, but Java setup has no
Gradle cache and `subosito/flutter-action` does not enable its cache option:
[deploy_android.yml](../.github/workflows/deploy_android.yml#L20-L34).

Build jobs repeat setup and dependency downloads independently.

**Recommended fix**

```yaml
- uses: actions/setup-java@v4
  with:
    distribution: zulu
    java-version: '17'
    cache: gradle

- uses: subosito/flutter-action@v2
  with:
    flutter-version: '<pinned-version>'
    cache: true
```

Also add workflow concurrency so a newer commit cancels an obsolete in-progress
run on the same branch.

### 9.5 ⚠️ The workflow follows a moving Flutter stable channel

Every job specifies only `channel: 'stable'`. A new stable Flutter release can
therefore change the compiler, Android tooling, generated output, or defaults
without a repository commit.

**Recommended fix:** Pin Flutter through a repository-owned version file or an
exact `flutter-version`. Upgrade deliberately in a dedicated pull request and
run generation plus the complete validation matrix.

### 9.6 ⚠️ Tagged releases can become partially published

`release_github` depends only on `build_apk`, while Play upload depends only on
`build_aab`. If AAB construction fails but APK construction succeeds, a GitHub
release can still be published for the tag.

Source:
[deploy_android.yml](../.github/workflows/deploy_android.yml#L132-L176).

**Recommended fix:** Add a promotion gate that depends on both signed builds.
Both release destinations should consume artifacts only after APK and AAB have
passed. This creates one coherent release decision.

### 9.7 ⚠️ Signing material handling can be hardened

The build jobs decode the keystore, Google services file, and key properties to
the runner filesystem. A file-based keystore is required by Gradle, and GitHub
hosted runners are ephemeral, so this is not automatically a vulnerability.
Hardening opportunities remain:

- pass secrets into the shell through `env` rather than direct expression
  interpolation;
- use `printf` instead of `echo` for exact content;
- restrict workflow permissions to `contents: read` by default and elevate only
  the GitHub release job;
- delete signing files in an `always()` cleanup step;
- ensure artifacts upload only APK/AAB paths;
- pin third-party actions to reviewed commit SHAs for stronger supply-chain
  control.

### 9.8 ⚠️ Native and script linting are absent

Flutter formatting and analysis do not check Kotlin or Node scripts. There is
no ktlint/detekt or JavaScript lint step.

**Recommended fix:** Add a minimal deterministic Kotlin formatting/lint task
and a Node lint configuration for administrative scripts. Keep this behind the
financial correctness work; stylistic CI should not delay critical integrity
fixes.

### 9.9 ⚠️ Direct dependencies have available updates

The following direct production packages were observed as outdated:

| Package | Current | Resolvable | Latest | Constraint blocks resolvable? |
| --- | ---: | ---: | ---: | --- |
| `cloud_firestore` | 6.1.2 | 6.9.0 | 6.9.0 | No |
| `connectivity_plus` | 7.0.0 | 7.3.1 | 7.3.1 | No |
| `firebase_auth` | 6.1.4 | 6.6.1 | 6.6.1 | No |
| `firebase_core` | 4.4.0 | 4.14.0 | 4.14.0 | No |
| `flutter_riverpod` | 3.0.3 | 3.3.2 | 3.4.3 | Yes |
| `google_fonts` | 8.0.2 | 8.2.1 | 8.2.1 | No |
| `hooks_riverpod` | 3.0.3 | 3.3.2 | 3.4.3 | Yes |
| `intl` | 0.20.2 | 0.20.2 | 0.20.3 | No |
| `json_annotation` | 4.9.0 | 4.12.0 | 4.12.0 | No |
| `riverpod_annotation` | 3.0.3 | 4.0.3 | 4.0.7 | Yes |
| `shared_preferences` | 2.5.4 | 2.5.5 | 2.5.5 | No |
| `uuid` | 4.5.2 | 4.6.0 | 4.6.0 | No |
| `wakelock_plus` | 1.4.0 | 1.6.1 | 1.8.0 | No |

**Recommended upgrade strategy**

1. Remove unused dependencies first.
2. Upgrade Firebase packages as one tested compatibility group.
3. Upgrade Riverpod annotations, runtime packages, generator, and lint plugin
   together.
4. Regenerate code and require a clean generated diff.
5. Avoid combining dependency upgrades with the money-schema migration.

---

## 10. Prioritized action plan

### Priority 1: Contain account-transition and notification privacy risk

This is the smallest high-impact change and should happen immediately.

Deliverables:

1. Clear native ownership before sign-out and whenever auth resolves to null.
2. Prevent an old synchronization from restoring a stale owner.
3. Remove raw notification logging.
4. Exclude queue data and active-owner preferences from Android backup.
5. Remove the redundant global deduplication constraint.
6. Add owner-switch and signed-out capture tests.

Definition of done:

- no notification queues while signed out;
- no owner A draft can be read or uploaded under owner B;
- backup inspection contains no queue/owner data;
- debug logs contain no payment content.

### Priority 2: Define and migrate the integer money schema

Deliverables:

1. Document CHF minor-unit and annual-proration rules.
2. Change all persisted/source/aggregate financial fields to integers.
3. Add strict direct-to-minor-unit input parsing.
4. Build a dry-run migration with validation and discrepancy reporting.
5. Rebuild summaries from source transactions.
6. Reconcile every user's pre/post totals from a verified backup.

Definition of done:

- persisted money contains no double values;
- every month summary exactly equals its source reduction;
- migration is repeatable and produces a signed-off reconciliation report.

### Priority 3: Establish a trustworthy transaction write boundary

Deliverables:

1. Choose trusted backend summaries or source-only client writes.
2. Make manual creation idempotent.
3. Reject ID collisions and illegal replacements.
4. Deploy collection-specific rules.
5. Archive categories instead of race-prone hard deletion.
6. Add emulator tests for every mutation and denial case.

Definition of done:

- retries cannot change totals twice;
- clients cannot write arbitrary summaries;
- malformed or unauthorized ledger writes are rejected;
- all source/summary mutations are reproducibly tested.

### Priority 4: Protect anonymous accounts and correct sign-out

Deliverables:

1. Detect anonymous users before logout.
2. Implement Google credential linking that preserves the UID.
3. Provide explicit permanent-loss warning and export/recovery policy.
4. Guarantee Firebase sign-out even if Google cleanup fails.
5. Add account-collision and failure-path tests.

Definition of done:

- a user cannot accidentally abandon an anonymous ledger;
- sign-out always closes the Firebase session when Firebase is available;
- native owner cleanup is part of the same user-visible operation.

### Priority 5: Make high-risk tests and release gates authoritative

Deliverables:

1. Add concrete Firestore repository emulator tests.
2. Add SQLite queue and MethodChannel tests.
3. Gate Kotlin, backup, migration, rules, Flutter, and generation checks in CI.
4. Add risk-weighted coverage thresholds.
5. Pin Flutter and enable Flutter/Gradle caches.
6. Require both signed artifacts before publishing a tag.

Definition of done:

- a defect in transaction reconciliation, backup, migration, Wallet parsing,
  or rules makes CI fail;
- critical mutation files have meaningful branch coverage;
- tagged releases are promoted as one coherent APK/AAB unit.

## 11. Secondary improvement backlog

After the five production blockers are underway, address these in order:

1. Paginate category detail transactions.
2. Prevent sheet dismissal during financial mutations.
3. Replace interface connectivity with Firestore synchronization state.
4. Increase the pending-draft hit target and complete TalkBack semantics.
5. Bundle fonts and restore visible Material interaction feedback.
6. Incrementally group history pages or move to month-window caching.
7. Add resilient malformed-record reporting and repair tooling.
8. Purge synchronized notification rows and encrypt the remaining queue.
9. Remove stale synchronization and JSON-generation code.
10. Profile large category trees before implementing a sliver rewrite.

## 12. Finance-grade readiness checklist

Stutz should not be considered finance-grade until all of the following are
true:

- [ ] All persisted money uses integer minor units with documented rounding.
- [ ] Every transaction command is idempotent.
- [ ] Derived aggregates are backend-owned or mechanically reconciled.
- [ ] Firestore rules validate every collection schema and transition.
- [ ] Anonymous users have a tested linking/export/recovery path.
- [ ] Sign-out clears Firebase and native ownership under failure conditions.
- [ ] Notification data is backup-excluded, encrypted, redacted, and expired.
- [ ] Malformed records produce a visible reconciliation warning rather than a
      blank or failed ledger.
- [ ] Critical repositories and native boundaries have integration tests.
- [ ] CI runs every financial, Firebase, native, backup, and migration suite.
- [ ] Release artifacts are built with pinned tooling and promoted together.
- [ ] Accessibility tests cover touch targets, TalkBack, and large text.

## 13. Final assessment

The application has a good foundation and does not require an architectural
rewrite. The right strategy is to preserve its feature boundaries and pure
domain services while strengthening the financial and platform boundaries.

The most important shift is conceptual: transaction documents must be treated
as an auditable source of truth, and every summary, retry, account transition,
and local notification record must have an explicit integrity lifecycle. Once
integer money, idempotent trusted writes, strict rules, protected account
transitions, and risk-focused tests are in place, the remaining performance and
UX work is incremental rather than structural.