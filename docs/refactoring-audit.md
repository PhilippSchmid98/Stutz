# Refactoring Audit

Last reviewed: 2026-08-27

## Executive summary

Stutz has a solid feature-first structure, repository-backed data access, pure domain calculators, generated Riverpod providers, immutable Freezed entities, and meaningful automated tests. It is substantially better organized than a typical prototype.

It is not yet finance-grade. The highest risks are floating-point money, client-authoritative aggregates, permissive Firestore schemas, unrecoverable anonymous accounts, plaintext notification data, and incomplete notification synchronization. No confirmed cross-user data leak was found.

The project uses Riverpod 3.0.3, not Riverpod 2.x. Most `ref.watch`, `ref.read`, `ref.listen`, auto-dispose, and family usage follows current Riverpod guidance.

## Dependency audit

| Dependency | Status | Finding |
| --- | --- | --- |
| `flutter_riverpod`, `hooks_riverpod`, `riverpod_annotation` | Good | Reactive `watch` and event-driven `read` are mostly correct. Auth `keepAlive` is justified. Notification synchronization as a write-performing `FutureProvider` is not. |
| `riverpod_generator`, `riverpod_lint` | Good | Generation and linting are configured. Upgrade the Riverpod packages as one coordinated set. |
| `freezed`, `freezed_annotation` | Good | Immutable factories, private constructors, defaults, deep collection equality, and derived getters are implemented correctly. |
| `json_annotation`, `json_serializable` | Remove or adopt | They are effectively unused. Persistence uses explicit Firestore mappers, while models have no generated JSON API. Standardize on one approach. |
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Needs work | SDK usage is reasonable, but dependencies are behind resolvable versions and rules validate ownership rather than ledger schemas. |
| `google_sign_in` | Good | Credential flow is reasonable. Firebase sign-out should not depend on Google sign-out succeeding first. |
| `shared_preferences` | Mixed | Dart stores only onboarding state. Native preferences store the active UID without encryption. |
| `connectivity_plus` | Misused | A network interface is presented as cloud/internet availability. Connectivity does not guarantee reachability. |
| `flutter_hooks` | Good | Used appropriately for controllers and route-local state. |
| `scrollable_positioned_list` | Good | Appropriate for month jumps, although application pagination still recomputes retained history. |
| `timezone`, `intl` | Good | Zurich month boundaries are centralized and tested. |
| `uuid`, `collection` | Good | Small, justified usages. |
| `google_fonts` | Improve | Runtime font retrieval introduces avoidable startup and offline variability. Bundle fonts. |
| `wakelock_plus` | Remove or isolate | Used only for debugging; its unawaited initialization can produce an uncaught plugin error. |

At the review date, `flutter pub outdated` reported 50 locked upgrades and nine constraints behind resolvable versions. Upgrade Firebase independently where compatible; upgrade Riverpod and its generators together.

## Critical and high-priority findings

### [HIGH] Represent money in integer minor units

User-entered CHF values, transactions, planned amounts, category totals, and month aggregates use IEEE-754 `double`. Repeated additions and subtractions can produce fractional-cent drift and unstable aggregate equality.

The notification import feature already uses the correct pattern, `amountMinor`. Extend it across the persisted financial model.

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

A migration must convert existing values with an explicit rounding policy and verify aggregate reconciliation.

### [HIGH] Enforce Firestore schemas, not only ownership

The rules currently allow an authenticated owner to write any payload below their user document. This prevents cross-user access but permits invalid types, negative or non-finite amounts, forged summaries, illegal draft transitions, and dangling category references.

Add collection-specific rules and emulator tests. Example direction:

```javascript
allow create: if request.auth.uid == userId
  && request.resource.data.keys().hasOnly(
    ['expenseNodeId', 'amountMinor', 'dateTime', 'note'])
  && request.resource.data.amountMinor is int
  && request.resource.data.amountMinor > 0
  && exists(/databases/$(database)/documents/users/$(userId)/
            expense_nodes/$(request.resource.data.expenseNodeId));
```

Prefer trusted backend maintenance for derived month summaries. If summaries remain client-written, validate every permitted transition and delta.

### [HIGH] Make transaction creation and aggregates idempotent

Creating a transaction currently writes the document and always increments its month summary. Reusing an ID overwrites the transaction while incrementing the summary again.

Read the transaction in a Firestore transaction and distinguish create, exact replay, and replacement. Reconcile old and new category/month deltas atomically. Add tests for retries and ID collisions.

### [HIGH] Protect anonymous users from permanent data loss

Anonymous users can sign out without linking credentials or receiving a warning that the account and ledger may become unrecoverable. Reinstallation can have the same result.

Provide at least one of:

1. Account linking before sign-out.
2. Explicit destructive confirmation explaining permanent loss.
3. A tested export and recovery mechanism.

### [HIGH] Replace synchronization-as-provider-initialization

Notification synchronization is a write operation performed by a watched `FutureProvider`. Riverpod recommends providers represent reads and explicit methods/mutations perform writes. The provider also recomputes primarily on auth changes, so notifications captured later may remain queued until restart or re-authentication.

Replace it with an `AsyncNotifier` command such as `sync()`. Trigger synchronization on:

- successful authentication;
- app resume;
- native notification capture events;
- explicit user retry.

Serialize concurrent sync calls and preserve the existing upload-before-acknowledge guarantee.

### [HIGH] Protect local notification-derived financial data

The Android queue stores Firebase UID, merchant, amount, and timestamps in plaintext SQLite and SharedPreferences. Android backups are not explicitly disabled or scoped, and debug builds log raw Wallet notification fields.

Actions:

1. Store the queue under `noBackupFilesDir` or define strict backup exclusions.
2. Encrypt the database using a key protected by Android Keystore.
3. Remove raw notification content from logs or redact it aggressively.
4. Define retention and deletion behavior for synced/discarded rows.
5. Clear or rotate owner-specific state safely during account transitions.

### [HIGH] Replace release-disabled assertions with runtime validation

`TransactionDraftConfirmation` relies on `assert` for positive amounts and non-empty category IDs. Assertions are disabled in release builds.

Validate at the application/domain boundary and throw typed validation exceptions before repository calls. Firestore rules must repeat security-critical validation.

## Data integrity and error handling

### [MEDIUM] Isolate malformed documents

Several repository streams map all documents directly. One malformed document can throw and put an entire feature stream into an error state. Some casts, such as an invalid transaction note, can fail at runtime.

Prevent malformed writes through rules, use strict typed mappers, report redacted diagnostics, and expose a recoverable UI state. Do not silently discard financial records without surfacing a reconciliation warning.

### [MEDIUM] Remove category deletion races

Category deletion checks children and transaction references, then deletes in a separate operation. A concurrent write can create a reference between the checks and deletion.

Move the invariant to trusted backend logic or redesign category deletion as archival. Historical transaction categories should generally be immutable snapshots or retain archived category records.

### [MEDIUM] Add global redacted error reporting

Firebase initialization errors have a recovery screen and most UI mutations show generic messages, but there is no application-wide uncaught-error strategy.

Configure `FlutterError.onError` and `PlatformDispatcher.instance.onError`, then send structured reports to the chosen crash service. Never include amounts, merchants, notification text, UIDs, or notes in telemetry.

### [MEDIUM] Correct sign-out ordering

Google sign-out currently runs before Firebase sign-out. If Google sign-out throws, the Firebase session remains active despite the user requesting sign-out.

Use a `try/finally` policy that guarantees Firebase sign-out, then report partial Google cleanup separately.

## Architecture and state management

### Strengths

- Feature-first organization with application, data, domain, and presentation layers.
- Repositories own Firestore access.
- Pure calculators and tree/grouping services are independently testable.
- Cross-feature category enrichment uses a narrow `CategoryLookup` contract.
- Generated providers default to auto-dispose where appropriate.
- Auth and routing streams have justified `keepAlive` behavior.
- Callback-time mutations generally use `ref.read`; reactive dependencies use `ref.watch`.
- Build-time `ref.listen` and `listenManual` usage follow Riverpod lifecycle guidance.
- Riverpod family arguments used for category periods implement stable equality and hash codes.

### Improvements

- Split broad screen consumers where independent sections can rebuild separately.
- Use `select` only after profiling identifies meaningful rebuild cost.
- Replace write-performing initialization providers with explicit controllers.
- Keep ephemeral form/controller state in hooks/widgets, as currently done.
- Remove stale comments claiming repositories bridge to an old presentation layer.
- Introduce repository interfaces only where they improve testing or permit a genuine alternate implementation; avoid ceremonial abstractions.

## Freezed and serialization

Freezed usage is correct for the existing immutable entities. Collections generated by Freezed are unmodifiable, equality is structural, and private constructors correctly enable domain getters and methods. Union types are not required for the current simple entities; `AsyncValue` already represents provider loading/error/data state.

Remaining work:

- Convert mutable collection-bearing value objects such as transaction month summaries to immutable/Freezed types or expose unmodifiable maps.
- Decide on one persistence convention:
  - retain explicit Firestore mappers and remove `json_annotation`/`json_serializable`; or
  - add generated `fromJson`/`toJson` with explicit converters for Firestore `Timestamp` and other storage-specific values.
- Keep storage schema migration separate from domain object construction.

## Performance and UX

### [MEDIUM] Incremental transaction grouping

Each loaded page causes all retained transactions to be copied, sorted, enriched, and grouped again. Work and memory grow with history size.

Append or merge newly loaded days incrementally, or query transactions by selected month. Preserve deterministic ordering and category enrichment.

### [MEDIUM] Paginate category drill-down

Category details execute an unbounded Firestore query and eagerly render all transactions in a `Column`. Use cursor pagination and `ListView.builder`/slivers.

### [MEDIUM] Lazily render large budget trees

Budget planning uses a `SingleChildScrollView` with eager nested columns. Use slivers or lazy expansion for large category trees.

### [MEDIUM] Report backend state instead of network-interface state

`connectivity_plus` can say Wi-Fi is available while Firestore is unreachable. Drive the cloud indicator from pending writes/cache metadata and operation failures, optionally supplemented by reachability checks.

### [LOW] Startup and dependency cleanup

- Bundle Google fonts.
- Load only required timezone data if startup profiling justifies it.
- Remove or safely await debug-only wakelock behavior.
- Do not spend significant effort adding `const`; current widget extraction and const usage are already reasonable.

## Ordered action plan

1. Migrate every persisted monetary value and aggregate to integer minor units, backed by a verified backup and reconciliation report.
2. Add strict per-collection Firestore rules and emulator tests for malformed, negative, forged, and dangling-reference writes.
3. Make transaction creation idempotent and redesign month summaries so clients cannot silently corrupt them.
4. Protect anonymous users with account linking, export/recovery, and explicit data-loss confirmation.
5. Encrypt or backup-exclude the notification queue and remove raw financial logging.
6. Replace synchronization `FutureProvider` with an explicit controller plus native-event and app-resume triggers.
7. Add runtime domain validation and resilient mapper/error reporting.
8. Eliminate category deletion races, preferably through archival or trusted backend enforcement.
9. Paginate category details and incrementally group transaction pages.
10. Standardize serialization and remove unused JSON tooling if explicit mappers remain.
11. Upgrade dependencies in tested compatibility groups.
12. Add global, redacted crash reporting.

## Validation baseline

At the review date:

- 132 Flutter tests passed.
- Firestore rules tests passed.
- Firestore backup tests passed.
- Transaction-month migration tests passed.
- `flutter analyze` reported only a duplicated curly-braces style diagnostic in `transaction_draft_repository.dart`.
- Signing credentials, keystores, service account patterns, backups, and Wallet notification reports were ignored by Git.
- `lib/firebase_options.dart` was tracked; it contains public Firebase client configuration, not an Admin credential.

Re-run this baseline after each high-priority migration, and add focused tests before changing the next invariant.
