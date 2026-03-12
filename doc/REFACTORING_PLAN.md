# REFACTORING_PLAN.md — Stutz Expense Tracker

> **Erstellt:** 11. März 2026  
> **Autor:** Principal Software Architect  
> **Version:** 1.0  
> **Status:** Entwurf — Bereit zur Umsetzung

---

## Inhaltsverzeichnis

1. [Analyse der Dependencies](#1-analyse-der-dependencies)
   - 1.1 [Verfügbare Packages & Code-Generatoren](#11-verfügbare-packages--code-generatoren)
   - 1.2 [Architektur- und Refactoring-Empfehlungen](#12-architektur--und-refactoring-empfehlungen)
2. [Analyse des Ist-Zustands](#2-analyse-des-ist-zustands)
   - 2.1 [Aktuelle Ordnerstruktur](#21-aktuelle-ordnerstruktur)
   - 2.2 [Bewertung der Schichtentrennung](#22-bewertung-der-schichtentrennung)
   - 2.3 [Identifizierte Architekturverletzungen](#23-identifizierte-architekturverletzungen)
   - 2.4 [Code-Smells & Technische Schulden](#24-code-smells--technische-schulden)
3. [Refactoring-Konzept](#3-refactoring-konzept)
   - 3.1 [Neue Ziel-Ordnerstruktur](#31-neue-ziel-ordnerstruktur)
   - 3.2 [Schicht-für-Schicht-Strategie](#32-schicht-für-schicht-strategie)
   - 3.3 [Vereinfachung überkomplexer Logik](#33-vereinfachung-überkomplexer-logik)
   - 3.4 [Kommentarkultur & Clean Code](#34-kommentarkultur--clean-code)
   - 3.5 [Split-Strategie für große Dateien](#35-split-strategie-für-große-dateien)
   - 3.6 [Priorisierte Umsetzungsreihenfolge](#36-priorisierte-umsetzungsreihenfolge)
4. [Test-Konzept](#4-test-konzept)
   - 4.1 [Teststrategie pro Schicht](#41-teststrategie-pro-schicht)
   - 4.2 [Neue Test-Ordnerstruktur](#42-neue-test-ordnerstruktur)
   - 4.3 [Testabdeckungsziele](#43-testabdeckungsziele)
   - 4.4 [Mocking-Strategie](#44-mocking-strategie)
5. [Anhang: Migrations-Checkliste](#5-anhang-migrations-checkliste)

---

## 1. Analyse der Dependencies

### 1.1 Verfügbare Packages & Code-Generatoren

| Kategorie | Package | Version | Zweck |
|---|---|---|---|
| **State Management** | `flutter_riverpod` | ^3.0.3 | Riverpod für Widget-Baum |
| | `hooks_riverpod` | ^3.0.3 | Riverpod + Flutter Hooks |
| | `riverpod_annotation` | ^3.0.3 | Deklarative Provider via Annotationen |
| | `riverpod_generator` | ^3.0.3 | Code-Generation für Riverpod |
| **Code-Generatoren** | `freezed` | ^3.2.3 | Immutable Data Classes, Union Types, `copyWith` |
| | `freezed_annotation` | ^3.1.0 | Annotationen für Freezed |
| | `build_runner` | ^2.10.5 | Build-System für Code-Generatoren |
| **Datenbank (lokal)** | `drift` | ^2.30.1 | Typsicheres SQLite ORM |
| | `drift_flutter` | ^0.2.8 | Flutter-Integration für Drift |
| | `drift_dev` | ^2.30.1 | Code-Generator für Drift |
| | `sqlite3_flutter_libs` | ^0.5.41 | Native SQLite-Bibliotheken |
| **Backend/Cloud** | `firebase_core` | ^4.4.0 | Firebase-Grundlage |
| | `firebase_auth` | ^6.1.4 | Authentifizierung |
| | `cloud_firestore` | ^6.1.2 | Cloud-Datenbank |
| **Auth** | `google_sign_in` | ^7.2.0 | Google Login |
| **Netzwerk** | `connectivity_plus` | ^7.0.0 | Netzwerkstatus-Erkennung |
| **UI-Bibliotheken** | `percent_indicator` | ^4.2.5 | Fortschrittsanzeigen |
| | `scrollable_positioned_list` | ^0.3.8 | Scrollbare Listen mit Index-Steuerung |
| | `showcaseview` | ^5.0.1 | Onboarding-Overlays |
| | `animations` | ^2.1.1 | Material/Design-Animationen |
| | `flutter_native_splash` | ^2.4.7 | Splash Screen |
| **Utils** | `intl` | ^0.20.2 | Datum/Zahl-Formatierung, Lokalisierung |
| | `uuid` | ^4.5.2 | UUID-Generierung |
| | `collection` | ^1.19.1 | Erweiterte Collection-Methoden |
| | `shared_preferences` | ^2.5.4 | Key-Value-Speicher |
| | `wakelock_plus` | ^1.4.0 | Bildschirm wach halten |
| **Hooks** | `flutter_hooks` | ^0.21.3+1 | React-ähnliche Hooks |
| **Testing** | `flutter_test` (SDK) | — | Widget- und Unit-Tests |
| | `mockito` | 5.6.3 (transitiv) | Mocking-Framework |

### 1.2 Architektur- und Refactoring-Empfehlungen

#### A) Freezed für alle Domain-Models nutzen

**Status:** `freezed` und `freezed_annotation` sind als Dependency vorhanden, werden aber **nirgends genutzt**.

**Empfehlung:** Alle drei Domain-Models (`IncomeSource`, `ExpenseNode`, `Transaction`) auf Freezed umstellen. Das bringt:
- Immutability by Default
- Automatisches `copyWith`, `==`, `hashCode`, `toString`
- JSON-Serialisierung über `fromJson`/`toJson`
- Union Types für zukünftige Erweiterungen (z.B. `ExpenseNodeType`)

```dart
// VORHER (manuell)
class IncomeSource {
  final String id;
  final String name;
  // ... 5 Felder, manueller Constructor, toFirestore(), fromFirestore()
}

// NACHHER (mit Freezed)
@freezed
class IncomeSource with _$IncomeSource {
  const factory IncomeSource({
    required String id,
    required String name,
    required double amount,
    @Default('Monthly') String interval,
    @Default('Main') String group,
  }) = _IncomeSource;
}
```

#### B) Drift als Offline-First-Layer einsetzen

**Status:** `drift` und `drift_flutter` sind als Dependency vorhanden, werden aber **nicht genutzt**. Die App kommuniziert direkt mit Firestore ohne lokalen Cache.

**Empfehlung:** Drift als lokale SQLite-Datenbank einführen und als Single Source of Truth verwenden. Firestore wird zum reinen Sync-Backend. Dies ermöglicht echtes Offline-First-Verhalten (wird im Tutorial versprochen, aber aktuell nicht umgesetzt).

> **Hinweis:** Die Drift-Migration ist ein separates, größeres Feature-Projekt. Dieses Refactoring-Dokument legt die architektonische Grundlage. Die konkrete Drift-Integration wird als Phase 2 empfohlen.

#### C) Riverpod Generator konsequent nutzen

**Status:** Wird bereits teilweise genutzt (`@riverpod`-Annotationen in Providers und Repositories). Wird aber inkonsistent angewandt.

**Empfehlung:** Alle Provider einheitlich über `@riverpod` / `@Riverpod(keepAlive: true)` definieren. Keine manuellen `Provider()`-Definitionen mischen.

#### D) Flutter Hooks nutzen

**Status:** `flutter_hooks` und `hooks_riverpod` sind vorhanden, werden aber **nirgends genutzt**. Alle Screens verwenden `ConsumerStatefulWidget`.

**Empfehlung:** Für neue Screens `HookConsumerWidget` verwenden, wo `TextEditingController`, `AnimationController` oder `ScrollController` benötigt werden. Bestehende Screens können schrittweise migriert werden.

```dart
// VORHER
class _MyScreenState extends ConsumerState<MyScreen> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
}

// NACHHER
class MyScreen extends HookConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = useTextEditingController();
    // Kein dispose nötig!
  }
}
```

#### E) ShowcaseView nutzen

**Status:** `showcaseview` ist als Dependency vorhanden, wird aber nicht genutzt.

**Empfehlung:** Für späteres Feature-basiertes Onboarding einsetzen (anstatt nur des Tutorial-Screens). Niedrige Priorität.

---

## 2. Analyse des Ist-Zustands

### 2.1 Aktuelle Ordnerstruktur

```
lib/
├── main.dart
├── firebase_options.dart
├── data/
│   ├── auth_service.dart            (+ .g.dart)
│   ├── firestore_repositories.dart  (+ .g.dart)
├── domain/
│   ├── repositories.dart
│   ├── logic_extensions.dart
│   └── models/
│       ├── models.dart              (barrel file)
│       ├── expense_node.dart
│       ├── income_source.dart
│       └── transaction.dart
└── presentation/
    ├── providers/
    │   ├── budget_providers.dart         (+ .g.dart)
    │   ├── category_transactions_provider.dart (+ .g.dart)
    │   ├── connectivity_provider.dart   (+ .g.dart)
    │   ├── dashboard_providers.dart     (+ .g.dart)
    │   ├── monthly_detail_provider.dart (+ .g.dart)
    │   ├── transaction_providers.dart   (+ .g.dart)
    │   └── yearly_detail_provider.dart  (+ .g.dart)
    └── screens/
        ├── budget_planning_table_screen.dart  (~1500 Zeilen!)
        ├── category_transactions_screen.dart
        ├── dashboard_screen.dart              (~350 Zeilen)
        ├── home_screen.dart
        ├── monthly_detail_screen.dart
        ├── yearly_detail_screen.dart
        ├── onboarding/
        │   ├── login_screen.dart
        │   ├── tutorial_screen.dart
        │   └── welcome_screen.dart
        ├── transactions/
        │   ├── add_transaction_dialog.dart
        │   └── transaction_screen.dart
        └── widgets/
            └── cloud_status_icon.dart
```

### 2.2 Bewertung der Schichtentrennung

| Schicht | Bewertung | Anmerkungen |
|---|---|---|
| **Domain** | ⚠️ Befriedigend | Models existieren, aber ohne Freezed. Repository-Interfaces sind sauber definiert. Geschäftslogik ist in Extensions ausgelagert, aber unvollständig — viel Logik steckt noch in den Providern. |
| **Data** | ⚠️ Befriedigend | Firestore-Implementierungen nutzen Repository-Pattern korrekt. Aber: Models haben direkte `cloud_firestore`-Imports (Firestore-Kopplung in Domain). |
| **Presentation** | ❌ Mangelhaft | Massive Dateien (budget_planning_table_screen: ~1500 Zeilen). Provider enthalten Geschäftslogik. Dialoge, Helper-Widgets und Screen-Logik in einer Datei vermischt. |

### 2.3 Identifizierte Architekturverletzungen

#### V1: Domain-Models importieren `cloud_firestore` (KRITISCH)

**Betroffen:** `expense_node.dart`, `income_source.dart`, `transaction.dart`

Alle drei Domain-Models importieren `package:cloud_firestore/cloud_firestore.dart` und enthalten `toFirestore()` / `fromFirestore()` Factory-Methoden. Dies koppelt die Domain-Schicht direkt an die Infrastruktur.

**Regel:** Domain darf keine Abhängigkeiten zu externen Frameworks haben.

**Fix:** Serialisierung in die Data-Schicht verschieben (Mapper-Klassen oder Extension-Methoden auf Repository-Ebene).

#### V2: Provider enthalten Geschäftslogik (KRITISCH)

**Betroffen:**
- `dashboard_providers.dart` — Berechnung von `MonthlyBudgetStatus` (Fixed/Variable-Filterung, Monatliche Aggregation)
- `monthly_detail_provider.dart` — Rekursive Budget-vs-Actual-Berechnung
- `yearly_detail_provider.dart` — Offset-Berechnung, Jahresaggregation
- `transaction_providers.dart` — Gruppierung, Enrichment, Flatten-Logik

Diese Logik gehört in die Domain-Schicht (Use Cases oder Service-Klassen).

#### V3: Data-Layer-Imports in Presentation (MITTEL)

**Betroffen:** Nahezu alle Provider-Dateien importieren `package:stutz/data/firestore_repositories.dart` direkt.

**Regel:** Presentation darf nur auf Domain zugreifen, nie direkt auf Data.

**Fix:** Repository-Provider in die Domain-Schicht verschieben oder zumindest über abstrakte Interfaces bereitstellen.

#### V4: Fehlende Use-Case-Schicht (MITTEL)

Es gibt keine dedizierten Use Cases. Provider übernehmen gleichzeitig die Rolle von Use Cases, State Management und teilweise sogar Data Mapping.

#### V5: `BudgetHealthState` in Provider-Datei definiert (NIEDRIG)

**Betroffen:** `budget_providers.dart` — Die Klasse `BudgetHealthState` ist kein Provider, sondern ein Domain-Modell.

Gleiches gilt für `TransactionWithCategory`, `DailyTransactions`, `MonthlyBudgetStatus`, `BudgetVsActualNode`, `YearlyBudgetNode`.

#### V6: Hardcoded Strings für Enums (MITTEL)

`'Monthly'`, `'Yearly'`, `'Fixed'`, `'Variable'`, `'Main'`, `'Additional'` — werden als plain Strings verwendet. Typsicherheit fehlt, Tippfehler werden nicht vom Compiler erkannt.

#### V7: `main.dart` enthält Routing-Logik (NIEDRIG)

`main.dart` entscheidet über den Start-Screen basierend auf Auth-Status und SharedPreferences. Dies sollte in einen dedizierten Auth-State-Provider ausgelagert werden.

### 2.4 Code-Smells & Technische Schulden

| # | Datei | Problem | Schwere |
|---|---|---|---|
| S1 | `budget_planning_table_screen.dart` | **~1500 Zeilen** in einer Datei, enthält 10+ private Widgets, 3 komplexe Dialoge, Helper-Widgets | Hoch |
| S2 | `add_transaction_dialog.dart` | ~500 Zeilen, verschachtelte Builder, Inline-Logik | Mittel |
| S3 | `yearly_detail_screen.dart` | ~430 Zeilen, enthält `_StackedProgressBar` als Allzweck-Widget | Niedrig |
| S4 | `auth_service.dart` | Hardcoded `webClientId` direkt im Code | Hoch (Sicherheit) |
| S5 | `firestore_repositories.dart` | `_buildTree()` ist ~40 Zeilen rekursive Logik — gehört in Domain | Mittel |
| S6 | Alle Models | Keine Immutability (kein `final` Enforcement durch Freezed) | Mittel |
| S7 | Provider-Dateien | `ref.invalidate()` wird manuell nach jeder Mutation aufgerufen (statt Streams) | Mittel |
| S8 | `transaction_providers.dart` | `_flattenNodes()` wird in Provider UND Dialog dupliziert | Niedrig |
| S9 | `dashboard_screen.dart` | Logout-Logik direkt im `onPressed`-Callback (12 Zeilen) | Niedrig |

---

## 3. Refactoring-Konzept

### 3.1 Neue Ziel-Ordnerstruktur

```
lib/
├── main.dart                          // Minimal: ProviderScope + App
├── app.dart                           // MaterialApp, Theme, Router
├── firebase_options.dart
│
├── core/                              // Shared Utilities & Config
│   ├── constants/
│   │   └── firebase_config.dart       // WebClientId etc.
│   ├── enums/
│   │   └── enums.dart                 // Interval, ExpenseType, IncomeGroup
│   └── extensions/
│       └── date_extensions.dart       // Datums-Hilfsfunktionen
│
├── domain/                            // Rein, keine Framework-Imports
│   ├── models/
│   │   ├── income_source.dart         // Freezed
│   │   ├── expense_node.dart          // Freezed
│   │   ├── transaction.dart           // Freezed
│   │   ├── budget_health.dart         // Freezed (ex BudgetHealthState)
│   │   ├── budget_vs_actual.dart      // Freezed (ex BudgetVsActualNode)
│   │   ├── yearly_budget.dart         // Freezed (ex YearlyBudgetNode)
│   │   ├── monthly_budget_status.dart // Freezed (ex MonthlyBudgetStatus)
│   │   └── daily_transactions.dart    // Freezed (ex DailyTransactions)
│   ├── repositories/
│   │   ├── income_repository.dart     // Abstract Interface
│   │   ├── expense_repository.dart    // Abstract Interface
│   │   └── transaction_repository.dart// Abstract Interface
│   └── services/                      // Pure Business Logic
│       ├── budget_calculator.dart     // Berechnung: Income, Expense, Balance
│       ├── transaction_grouper.dart   // Gruppierung, Enrichment
│       ├── tree_builder.dart          // flattenNodes, buildTree
│       └── yearly_calculator.dart     // Offset, Jahresberechnung
│
├── data/                              // Infrastruktur-Implementierungen
│   ├── mappers/
│   │   ├── income_mapper.dart         // toFirestore / fromFirestore
│   │   ├── expense_node_mapper.dart
│   │   └── transaction_mapper.dart
│   ├── repositories/
│   │   ├── firestore_income_repository.dart
│   │   ├── firestore_expense_repository.dart
│   │   └── firestore_transaction_repository.dart
│   └── services/
│       └── auth_service.dart
│
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart             // Auth-State + Routing-Logik
    │   ├── connectivity_provider.dart
    │   ├── repository_providers.dart      // Alle Repo-Provider zentral
    │   ├── budget_providers.dart          // Dünn: delegiert an domain/services
    │   ├── dashboard_providers.dart
    │   ├── transaction_providers.dart
    │   ├── monthly_detail_provider.dart
    │   └── yearly_detail_provider.dart
    ├── screens/
    │   ├── home_screen.dart
    │   ├── dashboard/
    │   │   ├── dashboard_screen.dart
    │   │   ├── widgets/
    │   │   │   ├── current_month_card.dart
    │   │   │   ├── past_month_tile.dart
    │   │   │   └── stat_column.dart
    │   ├── budget/
    │   │   ├── budget_planning_screen.dart
    │   │   ├── widgets/
    │   │   │   ├── income_section_card.dart
    │   │   │   ├── expense_section_card.dart
    │   │   │   ├── expense_item_row.dart
    │   │   │   ├── income_item_row.dart
    │   │   │   ├── budget_overview_card.dart
    │   │   │   └── legend_row.dart
    │   │   ├── dialogs/
    │   │   │   ├── add_income_dialog.dart
    │   │   │   ├── add_expense_node_dialog.dart
    │   │   │   └── add_main_category_dialog.dart
    │   ├── transactions/
    │   │   ├── transaction_screen.dart
    │   │   ├── add_transaction_dialog.dart
    │   │   ├── widgets/
    │   │   │   ├── month_selector.dart
    │   │   │   ├── daily_transaction_group.dart
    │   │   │   └── transaction_item.dart
    │   ├── detail/
    │   │   ├── monthly_detail_screen.dart
    │   │   ├── yearly_detail_screen.dart
    │   │   ├── category_transactions_screen.dart
    │   │   └── widgets/
    │   │       ├── comparison_node_row.dart
    │   │       ├── yearly_node_row.dart
    │   │       └── stacked_progress_bar.dart
    │   ├── onboarding/
    │   │   ├── welcome_screen.dart
    │   │   ├── tutorial_screen.dart
    │   │   └── login_screen.dart
    │   └── shared/
    │       ├── cloud_status_icon.dart
    │       ├── styled_text_field.dart
    │       ├── styled_dropdown.dart
    │       ├── section_card.dart
    │       └── add_button.dart
```

### 3.2 Schicht-für-Schicht-Strategie

#### Domain-Schicht (Kern — zuerst refactoren)

**Ziel:** Null Framework-Imports. Rein Dart.

1. **Models auf Freezed umstellen:**
   - Alle `cloud_firestore`-Imports entfernen
   - `toFirestore()` / `fromFirestore()` entfernen
   - Magic Strings durch Enums ersetzen

   ```dart
   // lib/core/enums/enums.dart
   enum PaymentInterval { monthly, yearly }
   enum ExpenseType { fixed, variable }
   enum IncomeGroup { main, additional }
   ```

   ```dart
   // lib/domain/models/expense_node.dart
   @freezed
   class ExpenseNode with _$ExpenseNode {
     const ExpenseNode._(); // Für Custom Getter

     const factory ExpenseNode({
       required String id,
       String? parentId,
       required String name,
       double? plannedAmount,
       double? actualAmount,
       ExpenseType? type,
       PaymentInterval? interval,
       @Default([]) List<ExpenseNode> children,
       @Default(0) int sortOrder,
     }) = _ExpenseNode;

     bool get isGroup => children.isNotEmpty;
   }
   ```

2. **Geschäftslogik in Domain-Services verschieben:**

   ```dart
   // lib/domain/services/budget_calculator.dart
   class BudgetCalculator {
     double totalMonthlyIncome(List<IncomeSource> sources) {
       return sources.fold(0.0, (sum, s) => sum + s.monthlyAmount);
     }

     double totalMonthlyExpenses(List<ExpenseNode> roots) {
       return roots.fold(0.0, (sum, n) => sum + n.totalMonthlyCalculated);
     }

     BudgetHealth calculate(List<IncomeSource> sources, List<ExpenseNode> roots) {
       final income = totalMonthlyIncome(sources);
       final expenses = totalMonthlyExpenses(roots);
       return BudgetHealth(income: income, expenses: expenses);
     }
   }
   ```

3. **Tree-Logik in eigenen Service extrahieren:**
   - `_buildTree()` aus `FirestoreExpenseNodeRepository` → `domain/services/tree_builder.dart`
   - `_flattenNodes()` (dupliziert in Provider + Dialog) → `domain/services/tree_builder.dart`

#### Data-Schicht

**Ziel:** Reine Infrastruktur. Kennt Domain-Interfaces, implementiert sie.

1. **Mapper-Klassen erstellen:**

   ```dart
   // lib/data/mappers/expense_node_mapper.dart
   class ExpenseNodeMapper {
     static ExpenseNode fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
       final data = doc.data()!;
       return ExpenseNode(
         id: doc.id,
         parentId: data['parentId'],
         name: data['name'] ?? 'Unknown',
         plannedAmount: (data['plannedAmount'] as num?)?.toDouble(),
         interval: _parseInterval(data['interval']),
         type: _parseType(data['type']),
         sortOrder: data['sortOrder'] ?? 99999,
       );
     }

     static Map<String, dynamic> toFirestore(ExpenseNode node) {
       return {
         'parentId': node.parentId,
         'name': node.name,
         'plannedAmount': node.plannedAmount,
         'interval': node.interval?.name,
         'type': node.type?.name,
         'sortOrder': node.sortOrder,
       };
     }
   }
   ```

2. **Repositories aufteilen:** Eine Datei pro Repository (statt alle in `firestore_repositories.dart`).

3. **AuthService:** `webClientId` in `core/constants/firebase_config.dart` auslagern.

#### Presentation-Schicht

**Ziel:** Dünne Provider, kleine Widgets, klare Separation.

1. **Provider verschlanken:** Provider delegieren an Domain-Services:

   ```dart
   // lib/presentation/providers/budget_providers.dart
   @riverpod
   Future<BudgetHealth> budgetHealth(Ref ref) async {
     final sources = await ref.watch(incomeListProvider.future);
     final roots = await ref.watch(expenseTreeProvider.future);
     return const BudgetCalculator().calculate(sources, roots);
   }
   ```

2. **Repository-Provider zentralisieren:** Alle `xxxRepositoryProvider` in eine Datei `repository_providers.dart`, die nur Domain-Interfaces exponiert.

3. **Auth-State als Provider:** Start-Screen-Logik aus `main.dart` in `auth_provider.dart`:

   ```dart
   @riverpod
   Stream<User?> authState(Ref ref) {
     return ref.watch(authServiceProvider).authStateChanges;
   }
   ```

### 3.3 Vereinfachung überkomplexer Logik

| Stelle | Problem | Lösung |
|---|---|---|
| `yearlyDetailTree` Provider | Offset-Berechnung, `DateFormat("D")`, Schaltjahr-Check inline | In `YearlyCalculator`-Service extrahieren mit klar benannten Methoden: `calculateOffsetFactor(year, firstTxnDate)` |
| `dashboardMonthlyStats` Provider | ~50 Zeilen mit verschachtelter Iteration über Nodes + Transactions + 6 Monate | In `DashboardStatsCalculator`-Service mit Methoden: `filterVariableNodes()`, `calculateMonthlyStats()` |
| `_buildTree()` in Repository | 40 Zeilen rekursive Logik | In `TreeBuilder`-Service: `buildTree(flatNodes)` und `flattenTree(rootNodes)` |
| `TransactionList` Provider | Gleichzeitig: Laden, Flatten, Enrichment, Gruppierung, Sortierung | Aufteilen: Provider lädt Daten, `TransactionGrouper`-Service übernimmt Transformation |
| Budget Planning Screen Dialoge | 3 komplexe Dialoge inline | In eigene Dateien `dialogs/` extrahieren |

### 3.4 Kommentarkultur & Clean Code

#### Überflüssige Kommentare entfernen

```dart
// ENTFERNEN — Kommentar sagt nur, was der Code tut:
// Local state for index is sufficient here
int _currentIndex = 0;

// ENTFERNEN — Offensichtlich:
// Screens we switch between
const screens = [...]

// ENTFERNEN — Redundant:
// 1. Income card
incomeAsync.when(...)
```

#### Fehlende Dokumentation hinzufügen

```dart
// HINZUFÜGEN — Business-Regel dokumentieren:
/// Berechnet den Offset-Faktor für das erste Nutzungsjahr.
/// Wenn der erste Eintrag am 1. April ist, sind 3/12 = 25% des Jahresbudgets
/// bereits "virtuell verbraucht", da die App das Budget nicht rückwirkend trackt.
double calculateOffsetFactor(int year, DateTime firstTxnDate) { ... }

// HINZUFÜGEN — Warum, nicht Was:
/// [sortOrder] 99999 dient als Lazy-Migration für alte Dokumente ohne Sortierung.
/// Neue Einträge werden immer ans Ende eingereiht.
@Default(99999) int sortOrder,
```

#### Regeln für das Refactoring

1. **Keine Kommentare für offensichtlichen Code** (`// Navigate to screen`, `// Return the result`)
2. **Docstrings für alle öffentlichen Domain-Services und Models** (nicht für private Widgets)
3. **Business-Regeln als `///`-Kommentare** wo die Logik nicht selbsterklärend ist
4. **TODO-Kommentare** nur mit Ticket-Referenz oder konkretem Aktionspunkt

### 3.5 Split-Strategie für große Dateien

#### budget_planning_table_screen.dart (~1500 Zeilen → ~8 Dateien)

```
lib/presentation/screens/budget/
├── budget_planning_screen.dart          // ~120 Zeilen: Scaffold, Sections-Aufbau
├── widgets/
│   ├── income_section_card.dart         // ~80 Zeilen: Einnahmen-Karte mit Sub-Gruppen
│   ├── expense_section_card.dart        // ~80 Zeilen: Ausgaben-Karte pro Root-Node
│   ├── expense_item_row.dart            // ~70 Zeilen: Rekursive Zeile für Expense-Nodes
│   ├── income_item_row.dart             // ~40 Zeilen: Zeile für eine Einnahme
│   ├── budget_overview_card.dart        // ~100 Zeilen: Übersichtskarte
│   └── legend_row.dart                  // ~30 Zeilen: Legende
├── dialogs/
│   ├── add_income_dialog.dart           // ~120 Zeilen
│   ├── add_expense_node_dialog.dart     // ~150 Zeilen
│   └── add_main_category_dialog.dart    // ~60 Zeilen
```

Wiederverwendbare Helper-Widgets (`_StyledTextField`, `_StyledDropdown`, `_AddButton`, `_SectionCard`, `_TypeSelectorButton`) werden nach `presentation/screens/shared/` verschoben und public gemacht.

#### dashboard_screen.dart (~350 Zeilen → ~4 Dateien)

```
lib/presentation/screens/dashboard/
├── dashboard_screen.dart                // ~80 Zeilen: Scaffold + Layout
├── widgets/
│   ├── current_month_card.dart          // ~100 Zeilen
│   ├── past_month_tile.dart             // ~80 Zeilen
│   └── stat_column.dart                 // ~20 Zeilen
```

#### transaction_screen.dart (~500 Zeilen → ~4 Dateien)

```
lib/presentation/screens/transactions/
├── transaction_screen.dart              // ~120 Zeilen: Scaffold + ScrollLogik
├── add_transaction_dialog.dart          // ~250 Zeilen (bereits eigene Datei)
├── widgets/
│   ├── month_selector.dart              // ~120 Zeilen
│   ├── daily_transaction_group.dart     // ~60 Zeilen
│   └── transaction_item.dart            // ~60 Zeilen
```

### 3.6 Priorisierte Umsetzungsreihenfolge

```
Phase 1: Foundation (Keine Breaking Changes)
─────────────────────────────────────────────
 1. Enums erstellen (core/enums)
 2. Domain-Models auf Freezed migrieren
 3. Mapper-Klassen in data/mappers/ erstellen
 4. Firestore-Imports aus Domain entfernen
 5. build_runner ausführen

Phase 2: Domain-Logik extrahieren
──────────────────────────────────
 6. Domain-Services erstellen (BudgetCalculator, TreeBuilder, etc.)
 7. Geschäftslogik aus Providern in Services verschieben
 8. Repository-Provider zentralisieren
 9. Unit-Tests für Domain-Services schreiben

Phase 3: Presentation aufräumen
────────────────────────────────
10. budget_planning_table_screen.dart aufsplitten
11. dashboard_screen.dart aufsplitten
12. transaction_screen.dart aufsplitten
13. Shared Widgets extrahieren
14. Dialoge in eigene Dateien verschieben

Phase 4: Infrastruktur-Verbesserungen
──────────────────────────────────────
15. Auth-State als Provider (Start-Screen-Logik)
16. `webClientId` in Konfiguration auslagern
17. Hooks einführen (neue Screens / schrittweise Migration)
18. Stream-basierte Providers (statt invalidate)

Phase 5: Offline-First (separates Projekt)
──────────────────────────────────────────
19. Drift-Datenbankschema definieren
20. Lokale Repositories implementieren
21. Sync-Mechanismus Drift ↔ Firestore
```

---

## 4. Test-Konzept

### 4.1 Teststrategie pro Schicht

#### Domain (Unit Tests) — Höchste Priorität

Die Domain-Schicht enthält die gesamte Geschäftslogik und ist framework-frei. Tests hier sind **schnell**, **deterministisch** und **stabil**.

| Testziel | Was wird getestet | Beispiel |
|---|---|---|
| **Models** | Freezed-generiertes `copyWith`, Equality, Enums | `IncomeSource(interval: monthly).monthlyAmount == amount` |
| **BudgetCalculator** | Einnahmen-/Ausgabenberechnung, Balance | Monatlich vs. Jährlich, leere Listen, Negativ-Werte |
| **TreeBuilder** | `buildTree()`, `flattenTree()` | Rekursion, Sortierung, leere Children, Orphan-Nodes |
| **TransactionGrouper** | Gruppierung nach Tag, Enrichment | Mehrere Tage, leere Monate, unbekannte NodeIds |
| **YearlyCalculator** | Offset-Berechnung, Jahresstatistik | Schaltjahr, Start Mitte des Jahres, Start im Vorjahr |
| **Logic Extensions** | `monthlyAmount`, `totalMonthlyCalculated` | Blätter, Gruppen, verschachtelte Gruppen |

#### Data (Integration Tests)

| Testziel | Was wird getestet | Ansatz |
|---|---|---|
| **Mapper** | Korrekte Serialisierung/Deserialisierung | Unit Tests mit Mock-DocumentSnapshot |
| **Repositories** | CRUD-Operationen gegen Firestore | Integration Tests mit Firebase Emulator (optional, aufwendiger) |
| **AuthService** | Login-Flows | Manuell / E2E (Firebase-Auth-Mocking ist komplex) |

#### Presentation (Widget Tests)

| Testziel | Was wird getestet | Ansatz |
|---|---|---|
| **Screens** | Korrekte Darstellung bei verschiedenen States (Loading, Error, Data) | Widget Tests mit `ProviderScope.overrides` |
| **Dialoge** | Formular-Validierung, Eingabefelder, Button-Verhalten | Widget Tests |
| **Shared Widgets** | Isolierte Darstellungstests | Widget Tests |

### 4.2 Neue Test-Ordnerstruktur

```
test/
├── core/
│   └── enums_test.dart
│
├── domain/
│   ├── models/
│   │   ├── income_source_test.dart
│   │   ├── expense_node_test.dart
│   │   └── transaction_test.dart
│   └── services/
│       ├── budget_calculator_test.dart
│       ├── tree_builder_test.dart
│       ├── transaction_grouper_test.dart
│       └── yearly_calculator_test.dart
│
├── data/
│   ├── mappers/
│   │   ├── income_mapper_test.dart
│   │   ├── expense_node_mapper_test.dart
│   │   └── transaction_mapper_test.dart
│   └── repositories/
│       └── (Integration Tests — optional)
│
├── presentation/
│   ├── providers/
│   │   ├── budget_providers_test.dart
│   │   ├── dashboard_providers_test.dart
│   │   └── transaction_providers_test.dart
│   ├── screens/
│   │   ├── dashboard/
│   │   │   └── dashboard_screen_test.dart
│   │   ├── budget/
│   │   │   └── budget_planning_screen_test.dart
│   │   └── transactions/
│   │       └── transaction_screen_test.dart
│   └── shared/
│       └── cloud_status_icon_test.dart
│
├── helpers/
│   ├── test_data.dart            // Factory-Methoden für Test-Fixtures
│   ├── mock_repositories.dart    // Mock-Implementierungen aller Repos
│   └── pump_app.dart             // Helper: MaterialApp + ProviderScope wrappen
│
└── fixtures/
    └── (JSON-Dateien für komplexe Test-Daten, optional)
```

### 4.3 Testabdeckungsziele

| Schicht | Ziel-Coverage | Begründung |
|---|---|---|
| `domain/services/` | **>90%** | Kern-Geschäftslogik, muss korrekt sein |
| `domain/models/` | **>80%** | Freezed generiert vieles, aber Custom Getter testen |
| `data/mappers/` | **>90%** | Serialisierung muss fehlerfrei sein |
| `presentation/providers/` | **>70%** | Provider sind dünn nach Refactoring, aber Orchestrierung testen |
| `presentation/screens/` | **>50%** | Widget Tests für kritische Flows (Add, Delete, Navigation) |

### 4.4 Mocking-Strategie

Da alle Repositories über abstrakte Interfaces definiert sind, kann Mockito nahtlos eingesetzt werden:

```dart
// test/helpers/mock_repositories.dart

// Option A: Mockito (bereits als transitive Dependency vorhanden)
@GenerateMocks([
  IncomeSourceRepository,
  ExpenseNodeRepository,
  TransactionRepository,
])
void main() {} // Leerer main für build_runner

// Option B: Manuelle Fakes (einfacher für Riverpod-Testing)
class FakeIncomeRepository implements IncomeSourceRepository {
  List<IncomeSource> _items = [];

  @override
  Future<List<IncomeSource>> getAllIncomeSources() async => _items;

  @override
  Future<void> addIncomeSource(IncomeSource source) async {
    _items = [..._items, source];
  }
  // ...
}
```

**Test-Helper für Riverpod:**

```dart
// test/helpers/pump_app.dart
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', 'CH')],
          home: widget,
        ),
      ),
    );
  }
}
```

**Beispiel Unit-Test nach Refactoring:**

```dart
// test/domain/services/budget_calculator_test.dart
void main() {
  late BudgetCalculator calculator;

  setUp(() => calculator = const BudgetCalculator());

  group('totalMonthlyIncome', () {
    test('sums monthly incomes directly', () {
      final sources = [
        IncomeSource(id: '1', name: 'Job', amount: 5000, interval: PaymentInterval.monthly),
        IncomeSource(id: '2', name: 'Side', amount: 1000, interval: PaymentInterval.monthly),
      ];
      expect(calculator.totalMonthlyIncome(sources), 6000.0);
    });

    test('divides yearly incomes by 12', () {
      final sources = [
        IncomeSource(id: '1', name: 'Bonus', amount: 12000, interval: PaymentInterval.yearly),
      ];
      expect(calculator.totalMonthlyIncome(sources), 1000.0);
    });

    test('returns 0 for empty list', () {
      expect(calculator.totalMonthlyIncome([]), 0.0);
    });
  });
}
```

---

## 5. Anhang: Migrations-Checkliste

Nutzbar als Tracking während der Umsetzung:

### Phase 1: Foundation

- [x] `lib/core/enums/enums.dart` erstellen (`PaymentInterval`, `ExpenseType`, `IncomeGroup`)
- [x] `IncomeSource` auf Freezed migrieren
- [x] `ExpenseNode` auf Freezed migrieren
- [x] `Transaction` auf Freezed migrieren (Namenskonflikt mit `cloud_firestore.Transaction` beachten → `AppTransaction`)
- [x] `data/mappers/` erstellen (je Model eine Mapper-Klasse)
- [x] Alle `cloud_firestore`-Imports aus `domain/` entfernen
- [x] `dart run build_runner build --delete-conflicting-outputs` ausführen
- [x] Bestehende Tests anpassen und bestätigen, dass sie grün sind

### Phase 2: Domain-Logik

- [ ] `domain/services/budget_calculator.dart` erstellen
- [ ] `domain/services/tree_builder.dart` erstellen
- [ ] `domain/services/transaction_grouper.dart` erstellen
- [ ] `domain/services/yearly_calculator.dart` erstellen
- [ ] Business-Logik-Code aus Providern in Services verschieben
- [ ] `presentation/providers/repository_providers.dart` erstellen
- [ ] Data-Imports aus Provider-Dateien durch Domain-Imports ersetzen
- [ ] Unit-Tests für alle Domain-Services schreiben

### Phase 3: Presentation

- [ ] `budget_planning_table_screen.dart` in 8+ Dateien aufsplitten
- [ ] `dashboard_screen.dart` in 4 Dateien aufsplitten
- [ ] `transaction_screen.dart` Widgets extrahieren
- [ ] Shared Widgets (`_StyledTextField`, `_StyledDropdown`, etc.) nach `shared/` verschieben
- [ ] Dialoge in `dialogs/`-Unterordner verschieben
- [ ] Alle Screens kompilieren und manuell testen

### Phase 4: Infrastruktur

- [ ] Auth-Provider erstellen, `main.dart`-Logik verschieben
- [ ] `webClientId` in Konfigurationsdatei auslagern
- [ ] Stream-basierte Provider evaluieren (Firestore-Streams statt `invalidate`)
- [ ] `HookConsumerWidget` in neuen/refactored Screens nutzen

---

> **Dieses Dokument dient als verbindliche Referenz für das Refactoring des Stutz-Projekts. Jede Phase kann unabhängig umgesetzt werden, solange die Reihenfolge innerhalb einer Phase eingehalten wird. Nach jeder Phase sollten alle Tests grün sein, bevor mit der nächsten fortgefahren wird.**
