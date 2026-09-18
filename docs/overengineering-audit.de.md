# Stutz Overengineering-Audit

Stand: 17. September 2026

## Kurzurteil

Die Codebase ist **nicht massiv overengineered**. Sie besitzt keine eigene
Base-Class-Hierarchie und nur zwei handgeschriebene Interfaces. Feature-Grenzen,
Firestore-Mapper, Freezed-Modelle und die komplexere Transaktionspagination
lösen überwiegend reale Probleme.

Die vermeidbare Komplexität konzentriert sich auf wenige Stellen:

1. drei Typen für einen kleinen Notification-Sync-Ablauf;
2. mehrere nachweislich ungenutzte Widgets, Domain-Typen und Dependencies;
3. ungenutzte Budget-Provider und Repository-Methoden;
4. ein dupliziertes Kategorie-Lookup-Modell samt Provider-Stufe;
5. alte Kompatibilitätsnamen im Pagination-State.

Das sinnvolle Ziel ist daher kein Architekturabriss. Es ist ein gezieltes
Entfernen ungenutzter Pfade und ein Zusammenziehen lokaler Abläufe. Riverpod,
Freezed und die Feature-Struktur sollten dabei erhalten bleiben.

## Validierungsbaseline

Phase 0 wurde am 17. September 2026 vor Beginn des Refactorings erfolgreich
ausgeführt. Es wurden keine Quelldateien verändert.

| Check | Ergebnis |
| --- | --- |
| `flutter analyze` | Bestanden, keine Diagnosen. |
| `flutter test` | 137 bestanden, 0 fehlgeschlagen. |
| `npm run test:rules` | Bestanden. |
| `npm run test:backup` | 7 bestanden, 0 fehlgeschlagen. |
| `npm run test:migration` | 5 bestanden, 0 fehlgeschlagen. |

Nach Abschluss der Node-/Firestore-Suiten waren keine Emulator- oder
Testprozesse mehr aktiv.

## Umsetzungsstand: Phase 2

Phase 2 wurde am 17. September 2026 vollständig umgesetzt. Entfernt wurden
zwei ungenutzte One-shot-Reads, zwei ungenutzte Summen-Provider, die ungenutzte
`TreeBuilder`-Injektion, die Ein-Konstanten-Datei `firebase_config.dart` und
vier veraltete Architekturkommentare. Riverpod-Code wurde nach den betroffenen
Änderungen neu generiert.

| Check | Ergebnis |
| --- | --- |
| Budget-Mutationstest | 2 bestanden. |
| BudgetCalculator-Test | 7 bestanden. |
| Budget-Widget-Test | 13 bestanden. |
| TreeBuilder-Test | 11 bestanden. |
| Auth-Routing-Test | 9 bestanden. |
| `flutter analyze` | Nach jedem Teilschritt bestanden, keine Diagnosen. |

## Unnötige Abstraktionen

### 1. Notification-Sync: drei Typen für einen linearen Ablauf

Betroffene Dateien:

- [`lib/features/notification_import/application/notification_draft_sync.dart`](../lib/features/notification_import/application/notification_draft_sync.dart)
- [`lib/features/notification_import/application/draft_sync_service.dart`](../lib/features/notification_import/application/draft_sync_service.dart)
- [`lib/features/notification_import/domain/repositories/transaction_draft_store.dart`](../lib/features/notification_import/domain/repositories/transaction_draft_store.dart)
- [`lib/features/notification_import/data/transaction_draft_repository.dart`](../lib/features/notification_import/data/transaction_draft_repository.dart)

`NotificationDraftSynchronizer` besitzt exklusiv einen `DraftSyncService`.
Dieser Service delegiert genau einen Cloud-Schritt an das einmethodige
`TransactionDraftStore`:

```text
NotificationDraftSynchronizer
  -> DraftSyncService
       -> TransactionDraftStore.upsertCapturedDraft
            -> TransactionDraftRepository
```

`TransactionDraftStore` hat genau eine Produktionsimplementierung. Der schmale
Port ist für Tests nützlich, rechtfertigt zusammen mit der zusätzlichen
Service-Klasse aber keine eigene dreistufige Struktur. Die direkte Kopplung des
Synchronizers an `TransactionDraftRepository` wäre ebenfalls keine gute
Vereinfachung: Sie würde Firestore in die Application-Schicht ziehen und die
Tests zu umfangreichen Repository-Fakes zwingen.

**Pragmatische Vereinfachung:** `DraftSyncService` in
`NotificationDraftSynchronizer` integrieren und nur die benötigte Operation als
Callback injizieren:

```dart
typedef UpsertCapturedDraft = Future<void> Function(TransactionDraft draft);

class NotificationDraftSynchronizer {
  NotificationDraftSynchronizer({
    required NotificationCaptureGateway captureGateway,
    required UpsertCapturedDraft upsertCapturedDraft,
    required void Function() onSynchronized,
  });
}
```

Damit entfallen ein Service, ein Interface und zwei Imports, während Tests eine
kleine Funktion statt eines Fake-Stores übergeben können. Serialisierung,
Cancellation, Upload-vor-Acknowledgement und UI-Verhalten bleiben unverändert.

**Bewertung:** hoher Nutzen, kleines Risiko.

### 2. Ungenutzte Dependency Injection im Expense-Repository

[`lib/features/budget/data/expense_node_repository.dart`](../lib/features/budget/data/expense_node_repository.dart)
verwendet beim Stream-Mapping direkt `const TreeBuilder().buildTree(flatNodes)`.
Die zuvor ungenutzte optionale Konstruktorinjektion wurde in Phase 2 entfernt.

### 3. Ein-Konstanten-Config entfernt

Die einzige Google-Sign-In-Client-ID liegt nun als private
`_googleSignInWebClientId` in
[`lib/features/auth/data/auth_service.dart`](../lib/features/auth/data/auth_service.dart).
Die ungenutzte Hülle `firebase_config.dart` wurde in Phase 2 gelöscht;
[`lib/firebase_options.dart`](../lib/firebase_options.dart) blieb unverändert.

### 4. Keine überflüssigen eigenen Base-Klassen vorhanden

Die Suche im handgeschriebenen Code findet keine anwendungseigene abstrakte
Basisklasse. Die abstrakten Klassen in `*.g.dart` und `*.freezed.dart` werden
von Riverpod beziehungsweise Freezed erzeugt und sind keine manuell gepflegte
Architekturhierarchie.

Die `abstract class`-Deklarationen der Freezed-Modelle, etwa in
[`lib/features/transactions/domain/entities/app_transaction.dart`](../lib/features/transactions/domain/entities/app_transaction.dart)
und
[`lib/features/budget/domain/entities/expense_node.dart`](../lib/features/budget/domain/entities/expense_node.dart),
sind Generator-Syntax. Sie durch manuelle Datenklassen zu ersetzen würde mehr
Boilerplate erzeugen und Robustheit verlieren.

### 5. `NotificationCaptureGateway` ist keine YAGNI-Abstraktion

[`lib/features/notification_import/application/notification_capture_gateway.dart`](../lib/features/notification_import/application/notification_capture_gateway.dart)
hat zwei reale Produktionsimplementierungen:

- `MethodChannelNotificationCaptureGateway` für Android;
- `UnsupportedNotificationCaptureGateway` für nicht unterstützte Plattformen.

Zusätzlich trennt der Vertrag Dart sauber vom MethodChannel und ermöglicht
kleine Tests ohne Flutter-Engine. Dieses Interface sollte bestehen bleiben.

## Architektur-Bloat

### 1. Nachweislich toter Produktionscode

Die folgenden Dateien beziehungsweise Typen haben keinen Produktionsnutzer:

- [`lib/features/budget/presentation/widgets/legend_row.dart`](../lib/features/budget/presentation/widgets/legend_row.dart): `LegendRow` wird nirgends importiert.
- [`lib/shared/widgets/styled_dropdown.dart`](../lib/shared/widgets/styled_dropdown.dart): `StyledDropdown` wird nur in seinem Shared-Widget-Test gebaut.
- [`lib/features/notification_import/domain/entities/merchant_category_rule.dart`](../lib/features/notification_import/domain/entities/merchant_category_rule.dart): nur vom ebenfalls ungenutzten Suggester verwendet.
- [`lib/features/notification_import/domain/services/merchant_normalizer.dart`](../lib/features/notification_import/domain/services/merchant_normalizer.dart): nur vom ungenutzten Suggester und dessen Test verwendet.
- [`lib/features/notification_import/domain/services/merchant_category_suggester.dart`](../lib/features/notification_import/domain/services/merchant_category_suggester.dart): keine Produktionsverwendung.

Der echte Vorschlagspfad läuft über `merchantCategorySuggestionProvider` und
`TransactionDraftRepository.getSuggestedExpenseNodeId()`. Er fragt die bereits
normalisierte Händler-ID direkt in Firestore ab. Das in-memory Regelmodell ist
ein übrig gebliebener alternativer Entwurf und testet nicht den produktiven
Pfad.

**Pragmatische Vereinfachung:** Die fünf toten Produktionsdateien löschen, den
reinen `StyledDropdown`-Test entfernen und aus
`merchant_category_suggester_test.dart` nur den weiterhin relevanten Test für
`merchantCategoryRuleId()` in eine passend benannte Testdatei übernehmen.

### 2. Zwei ungenutzte Budget-Provider entfernt

In
[`lib/features/budget/application/budget_providers.dart`](../lib/features/budget/application/budget_providers.dart)
waren diese Provider definiert:

- `totalMonthlyIncomeProvider`;
- `totalMonthlyExpensesProvider`.

Außer den generierten Deklarationen in `budget_providers.g.dart` existieren
keine Produktions- oder Testnutzer. Die Präsentation berechnet benötigte
Intervallwerte direkt über `BudgetCalculator`, und
`budgetSummaryProvider` berechnet die vollständige Zusammenfassung selbst.

Beide Provider wurden in Phase 2 gelöscht und Riverpod-Code neu generiert. Die
Methoden des `BudgetCalculator` bleiben erhalten, weil sie an anderen Stellen
verwendet und getestet werden.

**Bewertung:** sehr hoher Nutzen pro Aufwand, sehr kleines Risiko.

### 3. Zwei ungenutzte One-shot-Repository-Reads entfernt

Diese Methoden hatten keine Produktionsaufrufer:

- `ExpenseNodeRepository.getAllExpenseNodes()` in
  [`lib/features/budget/data/expense_node_repository.dart`](../lib/features/budget/data/expense_node_repository.dart);
- `IncomeSourceRepository.getAllIncomeSources()` in
  [`lib/features/budget/data/income_source_repository.dart`](../lib/features/budget/data/income_source_repository.dart).

Ihre einzigen weiteren Vorkommen sind leere Pflichtimplementierungen in
`budget_mutations_test.dart`, weil die Fakes die konkreten Repository-Klassen
implementieren. Die Anwendung verwendet ausschließlich die jeweiligen
Firestore-Streams.

Methoden und Test-Stubs wurden in Phase 2 gelöscht. Die Firestore-Streams
bleiben unverändert; es wurde keine Repository-Basisklasse eingeführt.

### 4. Dupliziertes Kategorie-Lookup-Modell und Provider-Stufe

Aktuell besteht in
[`lib/features/budget/application/budget_providers.dart`](../lib/features/budget/application/budget_providers.dart)
diese Kette:

```text
expenseTreeProvider
  -> flatExpenseNodesProvider
       -> categoryLookupsProvider
            -> PaginatedTransactionList
```

`flatExpenseNodesProvider` wird im handgeschriebenen Produktionscode nur von
`categoryLookupsProvider` gelesen. `CategoryLookup` aus
[`lib/features/budget/domain/view_models/category_lookup.dart`](../lib/features/budget/domain/view_models/category_lookup.dart)
kopiert wiederum nur `id`, `name` und `parentId` aus `ExpenseNode`. Die
Transaktions-Domain hängt damit bereits vom Budget-Feature ab, nur über einen
kleineren Typ. Es gibt keine zweite Quelle oder Implementierung, die diesen
Adaptervertrag benötigt.

**Pragmatische Vereinfachung:** `flatExpenseNodesProvider` als einzige
wiederverwendete Baumtransformation behalten. `TransactionGrouper` und
`PaginatedTransactionList` verwenden direkt `List<ExpenseNode>`;
`selectableCategoriesProvider` filtert dieselbe flache Liste. Danach
`CategoryLookup` und `categoryLookupsProvider` löschen.

```dart
@riverpod
Future<List<ExpenseNode>> flatExpenseNodes(Ref ref) async {
  final roots = await ref.watch(expenseTreeProvider.future);
  return const TreeBuilder().flattenTree(roots);
}
```

Der Trade-off ist eine breitere Typabhängigkeit auf `ExpenseNode`. In dieser
Codebase ist sie pragmatisch: Das Transaction-Feature importiert bereits das
Budget-Domain-Paket, und der dreifeldrige Adapter besitzt keine unabhängige
Semantik.

**Bewertung:** guter Quick Win, kleines bis mittleres Risiko.

### 5. Alte Pagination-Aliase verdoppeln das Vokabular

[`lib/features/transactions/application/transaction_service.dart`](../lib/features/transactions/application/transaction_service.dart)
modelliert inzwischen getrenntes Laden nach neuer und älter. Parallel dazu
existieren alte Einrichtungs- und API-Namen:

- `lastSnapshot` als Alias für `oldestSnapshot`;
- `hasReachedMax` als Alias für `hasReachedOldest`;
- `isLoadingMore` als Alias für `isLoadingOlder`;
- `loadMoreError` als Alias für `loadOlderError`;
- entsprechende Fallback-Parameter und `clearLoadMoreError` in `copyWith`;
- `loadNextPage()` als Alias für `loadOlderPage()`;
- `ensureMonthLoaded()` als Alias für `ensureMonthWindowLoaded()`.

Produktionscode verwendet von den alten State-Namen nur noch `lastSnapshot`;
die übrigen Nutzer sind Tests. Die beiden Method-Aliase werden in Produktion
gar nicht aufgerufen.

**Pragmatische Vereinfachung:** Zuerst Tests auf die aktuellen Older/Newer-
Namen umstellen, intern `oldestSnapshot` verwenden und anschließend alle
Aliase sowie Fallback-Parameter entfernen. Der eigentliche Pagination-
Algorithmus bleibt unverändert.

### 6. Ungenutzte JSON-Generator-Abhängigkeiten

[`pubspec.yaml`](../pubspec.yaml) deklariert `json_annotation` und
`json_serializable`. Im gesamten Produktions- und Testcode gibt es weder
`@JsonSerializable` noch generierte JSON-Mapper. Die vorhandenen `.g.dart`-
Dateien stammen von Riverpod; die Persistenz nutzt explizite Firestore-Mapper.

**Pragmatische Vereinfachung:** Beide Packages entfernen und `flutter pub get`
ausführen. `build_runner`, `riverpod_generator`, `freezed` und
`freezed_annotation` bleiben erforderlich.

### 7. Firestore-Mapper sind keine unnötige DTO-Schicht

Betroffene Dateien:

- [`lib/features/budget/data/expense_node_mapper.dart`](../lib/features/budget/data/expense_node_mapper.dart)
- [`lib/features/budget/data/income_source_mapper.dart`](../lib/features/budget/data/income_source_mapper.dart)
- [`lib/features/transactions/data/transaction_mapper.dart`](../lib/features/transactions/data/transaction_mapper.dart)
- [`lib/features/transactions/data/transaction_month_summary_mapper.dart`](../lib/features/transactions/data/transaction_month_summary_mapper.dart)
- [`lib/features/notification_import/data/transaction_draft_mapper.dart`](../lib/features/notification_import/data/transaction_draft_mapper.dart)

Diese Klassen bilden keine parallelen DTO-Objekte. Sie kapseln die tatsächliche
Storage-Grenze: Firestore-`Timestamp`, Enum-Namen, Legacy-Defaults,
Plattformdaten und Validierung fehlerhafter Felder. Mapping direkt in Widgets,
Providern oder Entities zu verschieben würde die Schichten nicht reduzieren,
sondern Persistenzdetails verteilen.

Ein Wechsel von statischen Mapper-Klassen zu Extensions oder Top-Level-Funktionen
wäre überwiegend Syntax-Churn. Die Dateien sollten bis zur geplanten
Minor-Unit-Migration bestehen bleiben.

### 8. Generierter Code ist kein sinnvoller Komplexitätsindikator

`*.g.dart` und `*.freezed.dart` sind Build-Artefakte. Ihre Zeilenzahl erhöht
weder die Anzahl der fachlichen Konzepte noch die manuell zu wartende
Codefläche. Riverpod liefert reaktive Lebenszyklen, Provider-Overrides und
typisierte Notifier; Freezed liefert unveränderliche Modelle, Equality und
`copyWith`.

Ein Ersatz durch manuelle Provider und Datenklassen würde den Quellcode eher
verlängern. Reduziert werden sollten die **Eingaben** der Generatoren, wenn ein
Provider oder Modell ungenutzt ist, nicht die Generatoren selbst.

### 9. Repository-Provider sind pragmatische Dependency Injection

Die Provider am Ende von
[`lib/features/budget/data/expense_node_repository.dart`](../lib/features/budget/data/expense_node_repository.dart),
[`lib/features/budget/data/income_source_repository.dart`](../lib/features/budget/data/income_source_repository.dart),
[`lib/features/transactions/data/transaction_repository.dart`](../lib/features/transactions/data/transaction_repository.dart)
und
[`lib/features/notification_import/data/transaction_draft_repository.dart`](../lib/features/notification_import/data/transaction_draft_repository.dart)
sind kurz, owner-spezifisch und in Tests überschreibbar.

Direkte `FirebaseFirestore.instance`-Erzeugung in Notifiern würde zwar Provider
löschen, aber Auth-Scoping und Tests verschlechtern. Keine zusätzlichen
Repository-Interfaces ergänzen; die bestehenden konkreten Klassen und
Provider-Overrides sind für diese App einfacher.

## Pragmatische Alternativen

### Beispiel A: Sync-Port durch einen Callback ersetzen

Komplex:

```dart
abstract interface class TransactionDraftStore {
  Future<void> upsertCapturedDraft(TransactionDraft draft);
}

class DraftSyncService {
  final TransactionDraftStore _draftStore;
}

class NotificationDraftSynchronizer {
  final DraftSyncService _service;
}
```

Direkt:

```dart
class NotificationDraftSynchronizer {
  final Future<void> Function(TransactionDraft) _upsertDraft;

  NotificationDraftSynchronizer({
    required Future<void> Function(TransactionDraft) upsertDraft,
  }) : _upsertDraft = upsertDraft;
}
```

Der Produktionsaufrufer übergibt `repository.upsertCapturedDraft`; der Test
eine lokale Async-Funktion. Ein Callback reicht, weil nur eine Fähigkeit und
kein austauschbares Subsystem benötigt wird.

### Beispiel B: Nur einen abgeleiteten Kategorie-Provider behalten

Komplex:

```dart
final roots = await ref.watch(expenseTreeProvider.future);
final flat = await ref.watch(flatExpenseNodesProvider.future);
final lookups = await ref.watch(categoryLookupsProvider.future);
```

Direkt:

```dart
final categories = await ref.watch(flatExpenseNodesProvider.future);
final grouped = const TransactionGrouper().groupByDay(transactions, categories);
```

Die reaktive Firestore-Quelle und genau eine flache Sicht bleiben bestehen;
eine reine Feldkopie erhält weder eigenen Typ noch eigenen Lifecycle.

## Nicht vereinfachen

Folgende Strukturen wirken auf den ersten Blick umfangreich, tragen aber reale
Komplexität und sollten nicht pauschal zusammengelegt werden:

- `PaginatedTransactionList` und `PaginatedTransactionsState`: Cursor,
  beidseitiges Nachladen, Monatsnavigation und getrennte Fehlerzustände sind
  echte Anforderungen.
- `NotificationDraftSynchronizer`: Koaleszenz und Cancellation verhindern
  Owner-Races; nur seine innere Service-Schicht sollte schrumpfen.
- `TransactionRepository`: Source-Dokument und Monatssummen müssen atomar
  koordiniert werden. Eine Aufteilung in zusätzliche Use-Case-Klassen wäre
  mehr, nicht weniger Architektur.
- `BudgetCalculator`, `TreeBuilder`, `TransactionGrouper` und
  `DashboardCalculator`: Die Algorithmen sind fachlich zusammenhängend,
  zustandslos und direkt getestet. Ein Wechsel zu Top-Level-Funktionen ist
  optionaler Stil ohne nennenswerten Wartbarkeitsgewinn.
- gemeinsame UI-Widgets unter `lib/shared/widgets/`: Sie stabilisieren das
  bestehende UI. Eine Zusammenlegung in Screens würde Duplikation erzeugen und
  das geforderte unveränderte UI unnötig riskieren.
- die Trennung von Domain-Entities und Firestore-Mapping: Sie hält
  Storage-Migrationen aus UI und Berechnungen heraus.

Ebenfalls nicht zusammenlegen: `seenOnboardingProvider` und
`OnboardingController`. Read-State und einmaliger Persistenzbefehl sind klein,
und eine gemeinsame generierte AsyncNotifier-Klasse würde die zahlreichen
einfachen Routing-Test-Overrides komplizierter machen, als sie Quellcode spart.

## Zielbild

Nach dem sinnvollen Refactoring bleibt die Feature-first-Struktur bestehen:

```text
Presentation -> Riverpod Application State -> konkrete Repositories
                         |                    -> Firestore-Mapper
                         -> reine Domain-Berechnungen
                         -> Plattform-Gateway
```

Es werden keine neuen Interfaces, Use-Case-Klassen, DTOs oder generischen
Repository-Basen eingeführt. Eine Abstraktion bleibt nur dann bestehen, wenn
mindestens einer dieser Gründe konkret gilt:

1. mehrere Produktionsimplementierungen;
2. echte Plattform- oder I/O-Grenze;
3. eigener Lifecycle oder nebenläufiger Zustand;
4. fachlicher Algorithmus mit unabhängigen Tests;
5. deutlich kleinerer Testvertrag als die konkrete Implementierung.
