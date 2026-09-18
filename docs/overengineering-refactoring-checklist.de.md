# Stutz Refactoring-Checkliste: KISS und YAGNI

Grundlage: [Overengineering-Audit](overengineering-audit.de.md)

Stand: 17. September 2026

## Arbeitsregeln

- Jeden nummerierten Schritt separat umsetzen und validieren.
- Keine UI-Texte, Layouts, Navigation oder Firestore-Feldnamen ändern.
- Generierte `*.g.dart`- und `*.freezed.dart`-Dateien nie manuell bearbeiten.
- Keine neuen Interfaces, Base-Repositories oder Use-Case-Klassen als Ersatz
  für gelöschte Abstraktionen einführen.
- Erst zum nächsten Schritt wechseln, wenn dessen fokussierter Test und
  `flutter analyze` bestehen.

## Phase 0: Ausgangszustand sichern

- [x] **0.1 Baseline ausführen und Ergebnis notieren.**
  - 17.09.2026: `flutter analyze` bestanden, keine Diagnosen.
  - 17.09.2026: `flutter test` bestanden, 137 Tests.
  - 17.09.2026: `npm run test:rules` bestanden.
  - 17.09.2026: `npm run test:backup` bestanden, 7 Tests.
  - 17.09.2026: `npm run test:migration` bestanden, 5 Tests.
  - Nach den Node-/Firestore-Suiten waren keine Emulator- oder Testprozesse
    mehr aktiv.

## Phase 1: Toten Code und ungenutztes Tooling entfernen

- [x] **1.1 Ungenutztes `LegendRow`-Widget löschen.**
  - Löschen:
    `lib/features/budget/presentation/widgets/legend_row.dart`.
  - Vorher und nachher sicherstellen, dass `LegendRow` und `legend_row.dart`
    keine weiteren Treffer haben.
  - Validieren: `flutter analyze`.
  - 18.09.2026: Keine weiteren Treffer; Analyse ohne Diagnosen.

- [x] **1.2 Ungenutztes `StyledDropdown` samt isoliertem Selbsttest löschen.**
  - Löschen: `lib/shared/widgets/styled_dropdown.dart`.
  - Den `StyledDropdown`-Test und dessen Import aus
    `test/shared/widgets/shared_widgets_test.dart` entfernen.
  - `styled_field_decoration.dart` behalten; es wird von produktiven
    Textfeldern und Dropdowns direkt verwendet.
  - Validieren:
    `flutter test test/shared/widgets/shared_widgets_test.dart` und
    `flutter analyze`.
  - 18.09.2026: Shared-Widget-Test bestanden (5 Tests); Analyse ohne
    Diagnosen.

- [x] **1.3 Den toten in-memory Händlerregel-Zweig entfernen.**
  - Löschen:
    `lib/features/notification_import/domain/entities/merchant_category_rule.dart`.
  - Löschen:
    `lib/features/notification_import/domain/services/merchant_normalizer.dart`.
  - Löschen:
    `lib/features/notification_import/domain/services/merchant_category_suggester.dart`.
  - Den weiterhin relevanten Test für `merchantCategoryRuleId()` in eine
    passende Datei wie
    `test/features/notification_import/domain/services/merchant_category_rule_id_test.dart`
    verschieben; den alten Suggester-Test löschen.
  - Den produktiven Firestore-Vorschlagspfad nicht verändern.
  - Validieren: den neuen Rule-ID-Test und `flutter analyze` ausführen.
  - 18.09.2026: Rule-ID-Test bestanden (1 Test); Analyse ohne Diagnosen.

- [x] **1.4 Ungenutzte JSON-Codegen-Packages entfernen.**
  - `json_annotation` und `json_serializable` aus `pubspec.yaml` entfernen.
  - `flutter pub get` ausführen und die Lockfile-Änderung prüfen.
  - `build_runner`, `riverpod_generator`, `freezed` und
    `freezed_annotation` behalten.
  - Validieren: `dart run build_runner build --delete-conflicting-outputs`,
    `flutter analyze` und `flutter test`.
  - 18.09.2026: `flutter pub get` und Codegenerierung bestanden; Analyse ohne
    Diagnosen; vollständige Flutter-Suite bestanden (132 Tests).

## Phase 2: Tote APIs und theoretische Injection entfernen

- [x] **2.1 Ungenutzte One-shot-Budget-Reads löschen.**
  - `ExpenseNodeRepository.getAllExpenseNodes()` entfernen.
  - `IncomeSourceRepository.getAllIncomeSources()` entfernen.
  - Die gleichnamigen leeren Overrides aus den Fakes in
    `test/features/budget/application/budget_mutations_test.dart` entfernen.
  - Die produktiven `watchAll...()`-Streams unverändert lassen.
  - Validieren:
    `flutter test test/features/budget/application/budget_mutations_test.dart`
    und `flutter analyze`.
  - 17.09.2026: Mutationstest bestanden (2 Tests); Analyse ohne Diagnosen.

- [x] **2.2 Ungenutzte Summen-Provider löschen.**
  - `totalMonthlyIncome()` und `totalMonthlyExpenses()` aus
    `lib/features/budget/application/budget_providers.dart` entfernen.
  - Die gleichnamigen Methoden im `BudgetCalculator` behalten; sie werden
    fachlich verwendet und getestet.
  - Riverpod-Code neu generieren.
  - Validieren:
    `flutter test test/features/budget/domain/services/budget_calculator_test.dart`,
    `flutter test test/features/budget/presentation/budget_widgets_test.dart`
    und `flutter analyze`.
  - 17.09.2026: Riverpod neu generiert; Calculator-Tests (7) und
    Widget-Tests (13) bestanden; Analyse ohne Diagnosen.

- [x] **2.3 Ungenutzte `TreeBuilder`-Injektion entfernen.**
  - `_treeBuilder` und den optionalen `treeBuilder`-Konstruktorparameter aus
    `ExpenseNodeRepository` entfernen.
  - In den beiden Read-Pfaden direkt
    `const TreeBuilder().buildTree(flatNodes)` verwenden.
  - Keine globale Singleton- oder Service-Locator-Abstraktion einführen.
  - Validieren:
    `flutter test test/features/budget/domain/services/tree_builder_test.dart`,
    `flutter test test/features/budget/application/budget_mutations_test.dart`
    und `flutter analyze`.
  - 17.09.2026: TreeBuilder-Tests (11) und Mutationstest (2) bestanden;
    Analyse ohne Diagnosen.

- [x] **2.4 Ein-Konstanten-Config in ihren einzigen Nutzer verschieben.**
  - `googleSignInWebClientId` als private Konstante in
    `lib/features/auth/data/auth_service.dart` definieren.
  - `lib/features/auth/data/firebase_config.dart` löschen und den Import
    entfernen.
  - `lib/firebase_options.dart` nicht ändern.
  - Validieren:
    `flutter test test/features/auth/application/auth_routing_test.dart` und
    `flutter analyze`.
  - 17.09.2026: Auth-Routing-Tests (9) bestanden; Analyse ohne Diagnosen.

- [x] **2.5 Veraltete Architekturkommentare entfernen.**
  - Kommentare wie „not-yet-migrated Auth feature“, „old presentation layer“,
    „Der Provider lebt direkt beim Repository“ und „Deine Logik wandert
    einfach hierher“ entfernen oder durch eine knappe aktuelle Aussage
    ersetzen.
  - Keine erklärenden Kommentare ergänzen, die nur den Code paraphrasieren.
  - Riverpod-Code neu generieren, weil Provider-Dokumentation in `.g.dart`
    übernommen wird.
  - Validieren: `flutter analyze`.
  - 17.09.2026: Riverpod neu generiert; Analyse ohne Diagnosen.

## Phase 3: Notification-Sync lokal zusammenziehen

- [x] **3.1 `DraftSyncService` in `NotificationDraftSynchronizer` integrieren.**
  - Den Ablauf Set Owner -> Capture -> List -> Upsert -> Acknowledge unverändert
    in `notification_draft_sync.dart` übernehmen.
  - Cancellation-Prüfungen vor jedem externen Schritt erhalten.
  - `TransactionDraftStore` in diesem Zwischenschritt noch beibehalten, damit
    die Änderung klein und separat testbar bleibt.
  - `draft_sync_service.dart` löschen und Tests auf den Synchronizer richten.
  - Validieren:
    `flutter test test/features/notification_import/application/draft_sync_service_test.dart`
    und `flutter analyze`.
  - 18.09.2026: Synchronisationstest bestanden (4 Tests); Analyse ohne
    Diagnosen.

- [x] **3.2 Einmethodiges `TransactionDraftStore` durch einen Callback ersetzen.**
  - Dem Synchronizer
    `Future<void> Function(TransactionDraft) upsertCapturedDraft` übergeben.
  - In `app_router.dart` die gebundene Methode
    `repository.upsertCapturedDraft` übergeben.
  - Im Test lokale Async-Funktionen statt `_FakeDraftStore` verwenden.
  - `implements TransactionDraftStore`, dessen Import und
    `transaction_draft_store.dart` entfernen.
  - Keine direkte Abhängigkeit des Synchronizers auf Firebase oder
    `TransactionDraftRepository` einführen.
  - Validieren:
    `flutter test test/features/notification_import/application/draft_sync_service_test.dart`
    und `flutter analyze`.
  - 18.09.2026: Synchronisationstest bestanden (4 Tests); Analyse ohne
    Diagnosen.

## Phase 4: Kategorie-Datenfluss vereinfachen

- [ ] **4.1 `selectableCategoriesProvider` auf die bestehende flache Sicht umstellen.**
  - `flatExpenseNodesProvider.future` lesen und nach
    `ExpenseType.variable` filtern.
  - `_flattenTreeVariableOnly()` entfernen.
  - Reihenfolge und Auswahlmenge mit bestehenden Widget-Tests absichern.
  - Validieren:
    `flutter test test/features/transactions/presentation/transaction_widgets_test.dart`,
    `flutter test test/features/notification_import/presentation/transaction_draft_review_sheet_test.dart`
    und `flutter analyze`.

- [ ] **4.2 Transaction-Gruppierung direkt mit `ExpenseNode` betreiben.**
  - `TransactionGrouper.groupByDay()` von `List<CategoryLookup>` auf
    `List<ExpenseNode>` umstellen.
  - `PaginatedTransactionList` auf `flatExpenseNodesProvider.future`
    umstellen.
  - Provider-Overrides und Testdaten in den Pagination- und Grouper-Tests
    entsprechend anpassen.
  - Sortierung, Unknown-Fallback und `parentId` unverändert testen.
  - Validieren:
    `flutter test test/features/transactions/domain/services/transaction_grouper_test.dart`,
    `flutter test test/features/transactions/application/paginated_transaction_list_test.dart`
    und `flutter analyze`.

- [ ] **4.3 Den nun ungenutzten Lookup-Adapter entfernen.**
  - `categoryLookups()` aus `budget_providers.dart` entfernen.
  - `lib/features/budget/domain/view_models/category_lookup.dart` löschen.
  - Riverpod-Code neu generieren und nach verbliebenen Treffern für
    `CategoryLookup` sowie `categoryLookupsProvider` suchen.
  - Validieren: die vollständige Flutter-Test-Suite und `flutter analyze`.

## Phase 5: Pagination-Vokabular bereinigen

- [ ] **5.1 Produktionscode und Tests auf die aktuellen Older/Newer-Namen umstellen.**
  - Intern `oldestSnapshot` statt `lastSnapshot` verwenden.
  - Tests von `hasReachedMax`, `isLoadingMore` und `loadMoreError` auf
    `hasReachedOldest`, `isLoadingOlder` und `loadOlderError` umstellen.
  - Tests direkt `loadOlderPage()` und `ensureMonthWindowLoaded()` aufrufen
    lassen.
  - In diesem Schritt die Aliase noch nicht löschen.
  - Validieren:
    `flutter test test/features/transactions/application/transaction_service_test.dart`,
    `flutter test test/features/transactions/application/paginated_transaction_list_test.dart`
    und
    `flutter test test/features/transactions/presentation/transaction_widgets_test.dart`.

- [ ] **5.2 Alte Pagination-Aliase und Fallback-Parameter löschen.**
  - Getter `lastSnapshot`, `hasReachedMax`, `isLoadingMore` und
    `loadMoreError` entfernen.
  - Konstruktor-/`copyWith`-Parameter `hasReachedMax`, `isLoadingMore`,
    `loadMoreError` und `clearLoadMoreError` entfernen.
  - Methoden `loadNextPage()` und `ensureMonthLoaded()` entfernen.
  - Den eigentlichen Older/Newer-/Monats-Ladealgorithmus nicht verändern.
  - Validieren: dieselben drei fokussierten Tests und `flutter analyze`.

- [ ] **5.3 Erst danach über Freezed für `PaginatedTransactionsState` entscheiden.**
  - Nur umstellen, wenn der verbleibende manuelle `copyWith` weiterhin
    nachweislich fehleranfällig oder schwer lesbar ist.
  - Bei Umstellung vorhandenes Freezed verwenden; keine neue Dependency und
    keine zusätzliche State-Hierarchie einführen.
  - Nullable Fehler müssen weiterhin explizit auf `null` gesetzt werden können.
  - Dies ist optional: Wenn die bereinigte Klasse klar ist, nach YAGNI nichts
    weiter ändern.
  - Validieren: alle Transaction-Application- und Presentation-Tests sowie
    `flutter analyze`.

## Phase 6: Abschluss-Gate

- [ ] **6.1 Generierung und statische Prüfung vollständig ausführen.**
  - `dart format lib test`.
  - `dart run build_runner build --delete-conflicting-outputs`.
  - Prüfen, dass eine zweite Generierung keinen weiteren Diff erzeugt.
  - `flutter analyze`.

- [ ] **6.2 Gesamte Regression-Suite ausführen.**
  - `flutter test`.
  - `npm run test:rules`.
  - `npm run test:backup`.
  - `npm run test:migration`.
  - Android: `android\gradlew.bat testDebugUnitTest`, sofern die lokale
    Cross-Drive-Gradle-Konfiguration den Lauf zulässt.

- [ ] **6.3 Funktionale Smoke-Tests ohne UI-Änderung durchführen.**
  - Anmelden und zwischen den drei Haupttabs wechseln.
  - Budgetdaten laden sowie Einkommen und Kategorie anlegen/bearbeiten.
  - Transaktion anlegen, bearbeiten, löschen, ältere Seite laden und zu einem
    Monat springen.
  - Notification-Draft synchronisieren, bestätigen und verwerfen.
  - Prüfen, dass Layout, Texte, Navigation und Interaktionsabläufe unverändert
    sind.

- [ ] **6.4 Abschluss-Suche durchführen.**
  - Keine Treffer mehr für gelöschte Typen, Provider und Legacy-Aliase.
  - Keine neuen Interfaces, Base-Klassen oder generischen Repository-Wrapper.
  - Dokumentation nur dort aktualisieren, wo sie gelöschte Dateien oder
    Provider noch als aktuellen Bestandteil beschreibt.
