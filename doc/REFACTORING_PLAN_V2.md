# REFACTORING_PLAN_V2.md — Stutz Expense Tracker

> **Erstellt:** 13. März 2026  
> **Autor:** Principal Software Architect  
> **Version:** 2.0  
> **Vorgänger:** [REFACTORING_PLAN.md](REFACTORING_PLAN.md) (V1 — vollständig umgesetzt)  
> **Status:** Entwurf — Bereit zur Umsetzung

---

## Inhaltsverzeichnis

1. [Rückblick auf V1](#1-rückblick-auf-v1)
   - 1.1 [Zusammenfassung der V1-Umsetzung](#11-zusammenfassung-der-v1-umsetzung)
   - 1.2 [Verbleibende Schulden aus V1](#12-verbleibende-schulden-aus-v1)
2. [Analyse des aktuellen Ist-Zustands](#2-analyse-des-aktuellen-ist-zustands)
   - 2.1 [Aktuelle Ordnerstruktur (Post-V1)](#21-aktuelle-ordnerstruktur-post-v1)
   - 2.2 [Identifizierte Architekturverletzungen](#22-identifizierte-architekturverletzungen)
   - 2.3 [Code-Smells & Technische Schulden](#23-code-smells--technische-schulden)
   - 2.4 [Test-Defizite](#24-test-defizite)
3. [Refactoring-Konzept V2](#3-refactoring-konzept-v2)
   - 3.1 [Schichttrennung abschließen](#31-schichttrennung-abschließen)
   - 3.2 [Stream-Migration für Transactions](#32-stream-migration-für-transactions)
   - 3.3 [Verbleibende Models auf Freezed migrieren](#33-verbleibende-models-auf-freezed-migrieren)
   - 3.4 [Determinismus in Domain-Services](#34-determinismus-in-domain-services)
   - 3.5 [Mapper-Robustheit & Konsistenz](#35-mapper-robustheit--konsistenz)
   - 3.6 [Infrastruktur-Korrekturen](#36-infrastruktur-korrekturen)
   - 3.7 [Priorisierte Umsetzungsreihenfolge](#37-priorisierte-umsetzungsreihenfolge)
4. [Test-Konzept V2](#4-test-konzept-v2)
   - 4.1 [Aktuelle Testabdeckung](#41-aktuelle-testabdeckung)
   - 4.2 [Neue Tests: Mapper-Schicht](#42-neue-tests-mapper-schicht)
   - 4.3 [Neue Tests: Provider-Schicht](#43-neue-tests-provider-schicht)
   - 4.4 [Bestehende Tests verbessern](#44-bestehende-tests-verbessern)
   - 4.5 [Widget-Tests (optional)](#45-widget-tests-optional)
   - 4.6 [Neue Test-Ordnerstruktur](#46-neue-test-ordnerstruktur)
5. [Anhang: Migrations-Checkliste](#5-anhang-migrations-checkliste)

---

## 1. Rückblick auf V1

### 1.1 Zusammenfassung der V1-Umsetzung

Das V1-Refactoring wurde **in großen Teilen vorbildlich umgesetzt**. Die Codebase hat sich von einer monolithischen Struktur mit 1500-Zeilen-Screens und Geschäftslogik in Providern hin zu einer sauberen Schichtenarchitektur transformiert.

**Erfolgreich abgeschlossene V1-Phasen:**

| Phase | Beschreibung | Status |
|---|---|---|
| **Phase 1** | Foundation (Enums, Freezed-Migration, Mapper, Firestore-Imports entfernt) | ✅ Vollständig |
| **Phase 2** | Domain-Logik (4 Services, Repository-Provider zentralisiert) | ✅ Vollständig |
| **Phase 3** | Presentation (Screen-Splits, Shared Widgets, Dialog-Extraktion) | ✅ Vollständig |
| **Phase 4** | Infrastruktur (Auth-Provider, Firebase-Config, Hooks, Streams) | ⚠️ Größtenteils |

**Architektonische Verbesserungen:**

- Domain-Schicht ist nahezu framework-frei (null `cloud_firestore`-Imports)
- Freezed für Kern-Models (`IncomeSource`, `ExpenseNode`, `AppTransaction`)
- 4 reine Domain-Services (`BudgetCalculator`, `TreeBuilder`, `TransactionGrouper`, `YearlyCalculator`)
- Mapper-Pattern für Firestore-Serialisierung
- Screens von ~1500 auf ~120 Zeilen reduziert
- `HookConsumerWidget` in 6+ Screens/Dialogen eingesetzt
- Stream-basierte Provider für Income und Expenses
- Auth-Routing über `AppRouter` und `authStateProvider`

### 1.2 Verbleibende Schulden aus V1

Trotz des erfolgreichen Refactorings wurden folgende Punkte **nicht oder unvollständig** umgesetzt:

| # | V1-Plan-Punkt | Status | Detail |
|---|---|---|---|
| 1 | Data-Imports aus Provider-Dateien eliminieren | ⚠️ Teilweise | `auth_provider.dart`, `repository_providers.dart` importieren aus `data/` — erwartungsgemäß als Bridge. Aber `dashboard_screen.dart` und `login_screen.dart` importieren `data/auth_service.dart` direkt. |
| 2 | Stream-basierte Provider (statt `invalidate`) | ⚠️ Teilweise | Income/Expenses nutzen Streams. Transactions nutzen weiterhin `Future` + `ref.invalidate()`. |
| 3 | Alle Domain-Models auf Freezed | ⚠️ Unvollständig | Nur 3/9 Models sind Freezed. 6 Models (`BudgetHealth`, `MonthlyBudgetStatus`, `BudgetVsActualNode`, `YearlyBudgetNode`, `TransactionWithCategory`, `DailyTransactions`) sind manuelle Klassen. |
| 4 | Testabdeckung laut Test-Konzept | ⚠️ Teilweise | Domain-Services getestet. Mapper, Provider und Widget-Tests fehlen komplett. |

---

## 2. Analyse des aktuellen Ist-Zustands

### 2.1 Aktuelle Ordnerstruktur (Post-V1)

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   └── firebase_config.dart
│   └── enums/
│       └── enums.dart
├── domain/
│   ├── logic_extensions.dart
│   ├── models/
│   │   ├── models.dart                    (barrel file)
│   │   ├── income_source.dart             ✅ Freezed
│   │   ├── expense_node.dart              ✅ Freezed
│   │   ├── transaction.dart               ✅ Freezed (AppTransaction)
│   │   ├── budget_health.dart             ❌ Manuell
│   │   ├── monthly_budget_status.dart     ❌ Manuell
│   │   ├── budget_vs_actual_node.dart     ❌ Manuell
│   │   ├── yearly_budget_node.dart        ❌ Manuell
│   │   ├── transaction_with_category.dart ❌ Manuell
│   │   └── daily_transactions.dart        ❌ Manuell
│   ├── repositories/
│   │   ├── expense_repository.dart
│   │   ├── income_repository.dart
│   │   └── transaction_repository.dart
│   └── services/
│       ├── budget_calculator.dart
│       ├── transaction_grouper.dart
│       ├── tree_builder.dart
│       └── yearly_calculator.dart
├── data/
│   ├── auth_service.dart
│   ├── mappers/
│   │   ├── expense_node_mapper.dart
│   │   ├── income_mapper.dart
│   │   └── transaction_mapper.dart
│   └── repositories/
│       ├── firestore_expense_repository.dart
│       ├── firestore_income_repository.dart
│       └── firestore_transaction_repository.dart
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart
    │   ├── budget_providers.dart
    │   ├── category_transactions_provider.dart
    │   ├── connectivity_provider.dart
    │   ├── dashboard_providers.dart
    │   ├── monthly_detail_provider.dart
    │   ├── repository_providers.dart
    │   ├── transaction_providers.dart
    │   └── yearly_detail_provider.dart
    └── screens/
        ├── home_screen.dart
        ├── category_transactions_screen.dart
        ├── monthly_detail_screen.dart
        ├── yearly_detail_screen.dart
        ├── budget/
        │   ├── budget_planning_screen.dart
        │   ├── dialogs/ (3 Dateien)
        │   └── widgets/ (6 Dateien)
        ├── dashboard/
        │   ├── dashboard_screen.dart
        │   └── widgets/ (3 Dateien)
        ├── onboarding/
        │   ├── welcome_screen.dart
        │   ├── tutorial_screen.dart
        │   └── login_screen.dart
        ├── shared/ (4 Dateien)
        ├── transactions/
        │   ├── transaction_screen.dart
        │   ├── add_transaction_dialog.dart
        │   └── widgets/ (3 Dateien)
        └── widgets/
            └── cloud_status_icon.dart
```

```
test/
├── domain_entities_test.dart
├── application/
│   └── budget_logic_test.dart
├── domain/
│   └── services/
│       ├── budget_calculator_test.dart
│       ├── transaction_grouper_test.dart
│       ├── tree_builder_test.dart
│       └── yearly_calculator_test.dart
└── helpers/
    └── test_data.dart
```

### 2.2 Identifizierte Architekturverletzungen

#### V1: Direkte Data-Layer-Imports in Screens (KRITISCH)

**Betroffen:**
- `presentation/screens/dashboard/dashboard_screen.dart` → `import 'package:stutz/data/auth_service.dart'`
- `presentation/screens/onboarding/login_screen.dart` → `import 'package:stutz/data/auth_service.dart'`

Beide Screens importieren `AuthService` direkt, statt den bereits existierenden `authServiceProvider` zu nutzen. Die Schichttrennung ist gebrochen: Presentation → Data statt Presentation → Provider → Data.

**Regel:** Screens dürfen niemals direkt auf die Data-Schicht zugreifen.

#### V2: `ref.invalidate()` in Widget-Code (HOCH)

**Betroffen:** `presentation/screens/transactions/add_transaction_dialog.dart`

```dart
// Zeile 140-141 (nach Add/Update)
ref.invalidate(transactionListProvider);
ref.invalidate(dashboardMonthlyStatsProvider);

// Zeile 172-173 (nach Delete)
ref.invalidate(transactionListProvider);
ref.invalidate(dashboardMonthlyStatsProvider);
```

Probleme:
1. **Duplizierung:** `TransactionList.addTransaction()` ruft intern bereits `ref.invalidateSelf()` auf.
2. **Fragil:** Jeder neue abhängige Provider muss manuell hier ergänzt werden.
3. **Inkonsistenz:** Income/Expenses nutzen Streams (auto-refresh), Transactions nutzen `invalidate` (manuell).

#### V3: `currentUserIdProvider` ist nicht reaktiv (HOCH)

**Betroffen:** `presentation/providers/repository_providers.dart`

```dart
@riverpod
String? currentUserId(Ref ref) {
  return FirebaseAuth.instance.currentUser?.uid;  // ← Einmaliger Snapshot!
}
```

Dieser Provider gibt den aktuellen User **zum Zeitpunkt des ersten Aufrufs** zurück. Ändert sich der Login-Status (Logout/Login), aktualisiert sich der Provider **nicht**, da er keinen Stream oder Watcher nutzt. Der bereits existierende `authStateProvider` wird nicht referenziert.

#### V4: `TransactionGrouper.groupByDay` — Undefinierte Sortierung der Tage (MITTEL)

Die Methode sortiert Transaktionen **innerhalb** eines Tages korrekt (neueste zuerst), aber die **Tagesgruppen selbst** werden in `Map`-Reihenfolge zurückgegeben. Die Reihenfolge von `LinkedHashMap` ist zwar de facto insertion-ordered (und da die Eingabe vorsortiert ist, stimmt das Ergebnis), aber dieses Verhalten ist ein Implementationsdetail und sollte explizit abgesichert werden.

#### V5: `FirestoreExpenseNodeRepository` koppelt an `TreeBuilder` (MITTEL)

```dart
// In firestore_expense_repository.dart:
final _treeBuilder = const TreeBuilder();
```

Der `TreeBuilder` wird intern instanziiert statt injiziert. Das macht die Repository-Klasse schwerer testbar (man kann den `TreeBuilder` nicht mocken oder durch eine andere Implementierung ersetzen).

### 2.3 Code-Smells & Technische Schulden

| # | Datei | Problem | Schwere |
|---|---|---|---|
| S1 | `domain/models/budget_health.dart` u.a. | 6 Models ohne Freezed — keine Value-Equality, kein `copyWith`, kein `toString` | Mittel |
| S2 | `domain/services/budget_calculator.dart` | `calculateDashboardStats()` nutzt `DateTime.now()` intern — nicht-deterministisch, Tests können bei Monatswechsel brechen | Hoch |
| S3 | `data/mappers/*.dart` | `switch`-Statements statt `enum.name` / `Enum.values.byName()` — Serialisierung PascalCase (`'Yearly'`), Parsing lowercase — inkonsistente Konventionen | Niedrig |
| S4 | `data/auth_service.dart` | `print()` in catch-Blöcken statt Logger — Fehler werden in Production verschluckt | Mittel |
| S5 | `presentation/screens/dashboard/dashboard_screen.dart` | Logout-Logik direkt im `onPressed`-Callback, importiert `WelcomeScreen` direkt (unnötig dank `AppRouter`) | Niedrig |
| S6 | `presentation/providers/transaction_providers.dart` | `availableMonths` hängt von `transactionListProvider` ab und triggert damit die gesamte Group-by-Day-Pipeline nur für Monatslisten | Niedrig |
| S7 | `add_transaction_dialog.dart` | Ruft `ref.read(transactionRepositoryProvider)` direkt auf statt über den `TransactionList`-Notifier | Mittel |

### 2.4 Test-Defizite

| Bereich | Geplant (V1) | Vorhanden | Fehlend |
|---|---|---|---|
| `domain/services/` | >90% | 4 Testdateien, gute Abdeckung | `DateTime.now()`-Abhängigkeit, fehlende Sortier-Tests |
| `domain/models/` | >80% | Basis-Constructor-Tests, Extension-Tests | Freezed-Equality, Default-Werte, `isGroup`-Gegentest |
| `data/mappers/` | >90% | **KEINE TESTS** | Alles (Serialisierung, Deserialisierung, Edge Cases) |
| `presentation/providers/` | >70% | **KEINE TESTS** | Provider-Orchestrierung, Mutations-Logik |
| `presentation/screens/` | >50% | **KEINE TESTS** | Kritische Flows (Add, Delete, Navigation) |
| Test-Helpers | — | `test_data.dart` (3 Factory-Methoden) | Mock-Repositories, `pumpApp`-Helper |

**Gesamtbewertung: ~30-35% der geplanten Testabdeckung umgesetzt.**

---

## 3. Refactoring-Konzept V2

### 3.1 Schichttrennung abschließen

#### 3.1.1 `AuthController`-Notifier erstellen

Die Auth-Logik (`signIn`, `signOut`) wird in verschiedenen Screens direkt über `AuthService` aufgerufen. Stattdessen soll ein dedizierter `AuthController` als einziger Einstiegspunkt dienen.

**Neue Datei:** `lib/presentation/providers/auth_provider.dart` (ergänzen)

```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<User?> signInAnonymously() async {
    return ref.read(authServiceProvider).signInAnonymously();
  }

  Future<User?> signInWithGoogle() async {
    return ref.read(authServiceProvider).signInWithGoogle();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    await ref.read(authServiceProvider).signOut();
  }
}
```

**Auswirkung:** Alle `import 'package:stutz/data/auth_service.dart'` Einträge in Screens können entfernt werden. Screens nutzen:
```dart
ref.read(authControllerProvider.notifier).signOut();
```

#### 3.1.2 Data-Imports aus Screens entfernen

| Datei | Aktueller Import | Ersetzen durch |
|---|---|---|
| `dashboard_screen.dart` | `data/auth_service.dart` | `ref.read(authControllerProvider.notifier).signOut()` |
| `login_screen.dart` | `data/auth_service.dart` | `ref.read(authControllerProvider.notifier).signInWithGoogle()` |

Nach dieser Änderung importieren **nur noch** `repository_providers.dart` und `auth_provider.dart` aus `data/` — das ist korrekt, da diese Dateien die **Bridge** zwischen Presentation und Data darstellen.

#### 3.1.3 `add_transaction_dialog.dart` — Über Notifier statt direkt

Das Dialog-Widget soll CRUD-Operationen **ausschließlich** über den `TransactionList`-Notifier ausführen, nicht direkt über das Repository:

```dart
// VORHER:
await ref.read(transactionRepositoryProvider).addTransaction(txn);
ref.invalidate(transactionListProvider);
ref.invalidate(dashboardMonthlyStatsProvider);

// NACHHER:
await ref.read(transactionListProvider.notifier).addTransaction(txn);
// Kein manuelles invalidate nötig — TransactionList macht invalidateSelf()
```

> **Hinweis:** Das verbleibende `ref.invalidate(dashboardMonthlyStatsProvider)` wird durch die Stream-Migration (§3.2) obsolet.

### 3.2 Stream-Migration für Transactions

#### Ziel

Alle drei Daten-Streams (Income, Expenses, Transactions) sollen einheitlich über Firestore-`snapshots()` laufen. Damit reagiert die gesamte App automatisch auf Datenänderungen — ohne manuelles `ref.invalidate()`.

#### 3.2.1 Neuer Stream-basierter Transaction-Provider

```dart
// lib/presentation/providers/transaction_providers.dart

/// Streams all transactions directly from Firestore — auto-updates on any
/// change without requiring manual [ref.invalidate] calls after mutations.
@riverpod
Stream<List<AppTransaction>> allTransactions(Ref ref) {
  return ref.watch(transactionRepositoryProvider).watchAllTransactions();
}
```

#### 3.2.2 `TransactionList` migrieren

Der bestehende `TransactionList`-Notifier wird vereinfacht. Er muss keine Daten mehr selbst laden, sondern orchestriert nur noch die Gruppierung auf Basis des Streams:

```dart
@riverpod
Future<List<DailyTransactions>> transactionList(Ref ref) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  final rootNodes = await ref.watch(expenseTreeProvider.future);
  final flatNodes = const TreeBuilder().flattenTree(rootNodes);
  return const TransactionGrouper().groupByDay(transactions, flatNodes);
}
```

CRUD-Operationen werden in einen separaten Mutations-Provider oder direkt über das Repository in den Screens abgewickelt:

```dart
@riverpod
class TransactionMutations extends _$TransactionMutations {
  @override
  FutureOr<void> build() {}

  Future<void> addTransaction(AppTransaction txn) async {
    await ref.read(transactionRepositoryProvider).addTransaction(txn);
    // Stream aktualisiert sich automatisch — kein invalidate nötig
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
  }

  Future<void> updateTransaction(AppTransaction txn) async {
    await ref.read(transactionRepositoryProvider).updateTransaction(txn);
  }
}
```

#### 3.2.3 `ref.invalidate()` entfernen

Nach der Stream-Migration können **alle** `ref.invalidate()`-Aufrufe in `add_transaction_dialog.dart` und `ref.invalidateSelf()` in `TransactionList` entfernt werden. Die Provider reagieren automatisch auf Firestore-Snapshots.

| Datei | Zeile(n) | Entfernen |
|---|---|---|
| `add_transaction_dialog.dart` | 140-141 | `ref.invalidate(transactionListProvider)` + `ref.invalidate(dashboardMonthlyStatsProvider)` |
| `add_transaction_dialog.dart` | 172-173 | `ref.invalidate(transactionListProvider)` + `ref.invalidate(dashboardMonthlyStatsProvider)` |
| `transaction_providers.dart` | 69 | `ref.invalidateSelf()` (in `addTransaction`) |
| `transaction_providers.dart` | 74 | `ref.invalidateSelf()` (in `deleteTransaction`) |

### 3.3 Verbleibende Models auf Freezed migrieren

#### Betroffene Models

| Model | Datei | Felder | Komplexität |
|---|---|---|---|
| `BudgetHealth` | `budget_health.dart` | 4 (2 computed) | Niedrig |
| `MonthlyBudgetStatus` | `monthly_budget_status.dart` | 3 + 2 computed Getters | Niedrig |
| `TransactionWithCategory` | `transaction_with_category.dart` | 3 | Niedrig |
| `DailyTransactions` | `daily_transactions.dart` | 3 | Niedrig |
| `BudgetVsActualNode` | `budget_vs_actual_node.dart` | 4 + 2 computed Getters | Mittel |
| `YearlyBudgetNode` | `yearly_budget_node.dart` | 5 + 4 computed Getters | Mittel |

#### Migrations-Muster

```dart
// VORHER (budget_health.dart):
class BudgetHealth {
  final double income;
  final double expenses;
  final double balance;
  final bool isDeficit;

  BudgetHealth({required this.income, required this.expenses})
      : balance = income - expenses,
        isDeficit = (income - expenses) < 0;
}

// NACHHER (budget_health.dart):
@freezed
abstract class BudgetHealth with _$BudgetHealth {
  const BudgetHealth._();

  const factory BudgetHealth({
    required double income,
    required double expenses,
  }) = _BudgetHealth;

  double get balance => income - expenses;
  bool get isDeficit => balance < 0;
}
```

```dart
// VORHER (budget_vs_actual_node.dart):
class BudgetVsActualNode {
  final ExpenseNode node;
  final double planned;
  final double actual;
  final List<BudgetVsActualNode> children;
  // ...computed getters...
}

// NACHHER:
@freezed
abstract class BudgetVsActualNode with _$BudgetVsActualNode {
  const BudgetVsActualNode._();

  const factory BudgetVsActualNode({
    required ExpenseNode node,
    required double planned,
    required double actual,
    required List<BudgetVsActualNode> children,
  }) = _BudgetVsActualNode;

  double get difference => planned - actual;
  double get percentUsed {
    if (planned == 0) return actual > 0 ? 1.0 : 0.0;
    return actual / planned;
  }
}
```

#### Warum lohnt sich das?

1. **Value-Equality:** Riverpod kann identische Zustände erkennen und unnötige Widget-Rebuilds vermeiden.
2. **`copyWith`:** Ermöglicht immutable Updates.
3. **`toString`:** Debug-Output zeigt alle Feldwerte statt `Instance of 'BudgetHealth'`.
4. **Konsistenz:** Alle Domain-Models folgen dem gleichen Pattern.

### 3.4 Determinismus in Domain-Services

#### `BudgetCalculator.calculateDashboardStats` — `DateTime.now()` extrahieren

**Problem:** Die Methode nutzt `DateTime.now()` intern. Tests sind damit nicht-deterministisch und können bei Monatswechseln brechen.

**Lösung:** Optionalen `referenceDate`-Parameter einführen.

```dart
// VORHER:
List<MonthlyBudgetStatus> calculateDashboardStats(
  List<ExpenseNode> rootNodes,
  List<AppTransaction> allTransactions, {
  int monthCount = 6,
}) {
  final now = DateTime.now();
  // ...
}

// NACHHER:
List<MonthlyBudgetStatus> calculateDashboardStats(
  List<ExpenseNode> rootNodes,
  List<AppTransaction> allTransactions, {
  int monthCount = 6,
  DateTime? referenceDate,
}) {
  final now = referenceDate ?? DateTime.now();
  // ...
}
```

**Auswirkung auf Provider:** Null — der Provider ruft die Methode weiterhin ohne `referenceDate` auf, was auf `DateTime.now()` fällt. Nur Tests profitieren von der Injizierbarkeit.

**Auswirkung auf Tests:** Volle Determinismus-Kontrolle:

```dart
test('calculates stats for specific months', () {
  final result = calc.calculateDashboardStats(
    nodes, txns,
    monthCount: 3,
    referenceDate: DateTime(2025, 6, 1),
  );
  expect(result[0].month, DateTime(2025, 6));
  expect(result[1].month, DateTime(2025, 5));
  expect(result[2].month, DateTime(2025, 4));
});
```

### 3.5 Mapper-Robustheit & Konsistenz

#### 3.5.1 Serialisierungskonvention vereinheitlichen

Aktuell: Parsing via `toLowerCase()`, Serialisierung in PascalCase (`'Yearly'`, `'Fixed'`).

**Empfehlung:** Konsistent auf **lowercase** umstellen (`'yearly'`, `'fixed'`) — entspricht dem Dart-`enum.name`. Für Backward-Compatibility bleibt das Parsing weiterhin case-insensitiv.

```dart
// VORHER:
static String _serializeInterval(PaymentInterval interval) {
  switch (interval) {
    case PaymentInterval.yearly: return 'Yearly';
    case PaymentInterval.monthly: return 'Monthly';
  }
}

// NACHHER:
static String _serializeInterval(PaymentInterval interval) => interval.name;
```

> **Achtung:** Bereits gespeicherte Firestore-Dokumente enthalten PascalCase-Werte. Die `_parse`-Methoden müssen **beides** verstehen. Das ist bereits der Fall, da sie `toLowerCase()` nutzen.

#### 3.5.2 Robustheit: Unbekannte Enum-Werte

Was passiert, wenn ein Firestore-Dokument `interval: "Quarterly"` enthält (z.B. nach einem Feature-Update)? Aktuell: `null` wird zurückgegeben. Das ist akzeptabel, sollte aber **explizit getestet** sein.

### 3.6 Infrastruktur-Korrekturen

#### 3.6.1 `currentUserIdProvider` reaktiv machen

```dart
// VORHER:
@riverpod
String? currentUserId(Ref ref) {
  return FirebaseAuth.instance.currentUser?.uid;
}

// NACHHER:
@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
}
```

Damit reagieren alle Repository-Provider automatisch auf Login/Logout.

#### 3.6.2 `AuthService` — `print` durch Logger ersetzen

```dart
// VORHER:
if (kDebugMode) {
  print("Error Anonymous Login: $e");
}

// NACHHER:
import 'dart:developer' as dev;
// ...
dev.log('Anonymous login failed', error: e, name: 'AuthService');
```

`dev.log` ist Flutter-nativ, erscheint in DevTools, und verschluckt keine Informationen in Release-Builds (da `dev.log` dort automatisch gefiltert wird).

#### 3.6.3 Dashboard — Logout via AppRouter

`dashboard_screen.dart` importiert `WelcomeScreen` für die manuelle Navigation nach Logout. Mit dem `AppRouter` ist das überflüssig — `signOut()` ändert den Auth-State, `AppRouter` reagiert automatisch.

```dart
// VORHER (dashboard_screen.dart):
import 'package:stutz/presentation/screens/onboarding/welcome_screen.dart';
// ...
await ref.read(authServiceProvider).signOut();
Navigator.pushReplacement(..., WelcomeScreen());

// NACHHER:
await ref.read(authControllerProvider.notifier).signOut();
// AppRouter erkennt automatisch, dass der User ausgeloggt ist
// und navigiert zu WelcomeScreen/LoginScreen
```

#### 3.6.4 `TransactionGrouper` — Explizite Sortierung der Tage

```dart
// In groupByDay(), nach dem groupBy-Ergebnis:
final days = groupedMap.entries.map((entry) {
  return DailyTransactions(
    date: entry.key,
    totalAmount: entry.value.fold(0.0, (sum, t) => sum + t.transaction.amount),
    transactions: entry.value,
  );
}).toList();

// Explizit sortieren — neueste Tage zuerst:
days.sort((a, b) => b.date.compareTo(a.date));
return days;
```

#### 3.6.5 `FirestoreExpenseNodeRepository` — Dependency Injection für `TreeBuilder`

```dart
// VORHER:
class FirestoreExpenseNodeRepository implements ExpenseNodeRepository {
  final String userId;
  final _treeBuilder = const TreeBuilder();
  // ...
}

// NACHHER:
class FirestoreExpenseNodeRepository implements ExpenseNodeRepository {
  final String userId;
  final TreeBuilder _treeBuilder;

  FirestoreExpenseNodeRepository(this.userId, {TreeBuilder treeBuilder = const TreeBuilder()})
      : _treeBuilder = treeBuilder;
  // ...
}
```

### 3.7 Priorisierte Umsetzungsreihenfolge

```
Phase 1: Kritische Architektur-Fixes (Kein UI-Impact)
──────────────────────────────────────────────────────
 1. AuthController-Notifier erstellen
 2. Data-Imports aus Screens entfernen (dashboard_screen, login_screen)
 3. currentUserIdProvider reaktiv machen (authStateProvider waten)
 4. build_runner ausführen, bestehende Tests grün bestätigen

Phase 2: Stream-Migration & Invalidate-Entfernung
──────────────────────────────────────────────────
 5. allTransactionsProvider (Stream) erstellen
 6. TransactionList auf Stream-Basis umbauen (oder TransactionMutations extrahieren)
 7. ref.invalidate()-Aufrufe in add_transaction_dialog.dart entfernen
 8. ref.invalidateSelf() in TransactionList entfernen
 9. Manuell testen: Add/Edit/Delete Transactions → UI aktualisiert sich

Phase 3: Domain-Model-Freeze & Determinismus
─────────────────────────────────────────────
10. BudgetHealth auf Freezed migrieren
11. MonthlyBudgetStatus auf Freezed migrieren
12. TransactionWithCategory auf Freezed migrieren
13. DailyTransactions auf Freezed migrieren
14. BudgetVsActualNode auf Freezed migrieren
15. YearlyBudgetNode auf Freezed migrieren
16. BudgetCalculator.calculateDashboardStats — referenceDate-Parameter einführen
17. TransactionGrouper.groupByDay — explizite Tagessortierung
18. build_runner ausführen, alle Tests grün bestätigen

Phase 4: Infrastruktur-Polish
─────────────────────────────
19. AuthService: print() → dev.log()
20. Dashboard: WelcomeScreen-Import + manuelle Navigation entfernen
21. Mapper-Serialisierung auf enum.name umstellen
22. FirestoreExpenseNodeRepository: TreeBuilder injizierbar machen
23. availableMonths-Provider vom transactionList entkoppeln (optional)

Phase 5: Test-Offensive (siehe §4)
───────────────────────────────────
24. Mapper-Tests (3 Dateien)
25. Bestehende Domain-Tests verbessern
26. Provider-Tests (mit ProviderContainer)
27. Widget-Tests für kritische Dialoge (optional)
```

---

## 4. Test-Konzept V2

### 4.1 Aktuelle Testabdeckung

```
test/
├── domain_entities_test.dart          — Basis-Constructor-Tests (geringer Wert)
├── application/
│   └── budget_logic_test.dart         — Extensions: monthlyAmount, totalMonthlyCalculated
├── domain/
│   └── services/
│       ├── budget_calculator_test.dart     — 5 Gruppen, ~15 Tests ✅
│       ├── transaction_grouper_test.dart   — 2 Gruppen, ~10 Tests ✅
│       ├── tree_builder_test.dart          — 4 Gruppen, ~12 Tests ✅
│       └── yearly_calculator_test.dart     — 2 Gruppen, ~12 Tests ✅
└── helpers/
    └── test_data.dart                 — 3 Factory-Methoden ✅
```

**Was gut ist:** Domain-Service-Tests sind solide, nutzen Factory-Methoden, folgen AAA-Pattern, testen Edge Cases.

**Was fehlt:** Alle Tests außerhalb `domain/services/` und `application/`.

### 4.2 Neue Tests: Mapper-Schicht

**Priorität: HOCH** — Serialisierung ist eine der häufigsten Fehlerquellen.

#### 4.2.1 `expense_node_mapper_test.dart`

```dart
// test/data/mappers/expense_node_mapper_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/data/mappers/expense_node_mapper.dart';
import 'package:stutz/domain/models/models.dart';

// Hilfsfunktion: Erzeugt ein Fake-DocumentSnapshot
// (da Firestore-DocumentSnapshot nicht direkt instanziierbar ist,
//  empfiehlt es sich, die Mapper auf Map<String, dynamic> umzustellen
//  — siehe 4.2.4 Refactoring-Hinweis)

void main() {
  group('ExpenseNodeMapper.toFirestore', () {
    test('serializes all fields', () {
      final node = ExpenseNode(
        id: 'e1',
        parentId: 'p1',
        name: 'Rent',
        plannedAmount: 1200.0,
        interval: PaymentInterval.monthly,
        type: ExpenseType.fixed,
        sortOrder: 3,
      );
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['parentId'], 'p1');
      expect(map['name'], 'Rent');
      expect(map['plannedAmount'], 1200.0);
      expect(map['interval'], 'Monthly');
      expect(map['type'], 'Fixed');
      expect(map['sortOrder'], 3);
    });

    test('serializes null interval and type as null', () {
      final node = ExpenseNode(id: 'e1', name: 'Group');
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['interval'], isNull);
      expect(map['type'], isNull);
    });

    test('serializes null plannedAmount', () {
      final node = ExpenseNode(id: 'e1', name: 'Group', plannedAmount: null);
      final map = ExpenseNodeMapper.toFirestore(node);
      expect(map['plannedAmount'], isNull);
    });
  });

  // fromFirestore-Tests erfordern entweder Mapper-Refactoring (auf Map)
  // oder einen Fake DocumentSnapshot-Wrapper (siehe 4.2.4).
}
```

#### 4.2.2 `income_mapper_test.dart`

```dart
// test/data/mappers/income_mapper_test.dart

void main() {
  group('IncomeMapper.toFirestore', () {
    test('serializes all fields', () { ... });
    test('yearly interval serialized correctly', () { ... });
    test('additional group serialized correctly', () { ... });
  });

  group('IncomeMapper.fromFirestore', () {
    test('defaults to monthly when interval missing', () { ... });
    test('defaults to main when group missing', () { ... });
    test('unknown interval falls back to monthly', () { ... });
    test('unknown group falls back to main', () { ... });
  });
}
```

#### 4.2.3 `transaction_mapper_test.dart`

```dart
// test/data/mappers/transaction_mapper_test.dart

void main() {
  group('TransactionMapper.toFirestore', () {
    test('serializes dateTime as Firestore Timestamp', () { ... });
    test('serializes null note', () { ... });
  });
}
```

#### 4.2.4 Refactoring-Hinweis: Mapper-Testbarkeit

Die aktuellen Mapper-Methoden nehmen `DocumentSnapshot<Map<String, dynamic>>` als Parameter-Typ. Da `DocumentSnapshot` nicht ohne Firebase-SDK instanziiert werden kann, gibt es zwei Ansätze:

**Option A (empfohlen):** Mapper auf `(String id, Map<String, dynamic> data)` umstellen:

```dart
// VORHER:
static ExpenseNode fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return ExpenseNode(id: doc.id, ...);
}

// NACHHER:
static ExpenseNode fromMap(String id, Map<String, dynamic> data) {
  return ExpenseNode(id: id, ...);
}

// Convenience-Wrapper (in Repository genutzt):
static ExpenseNode fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  return fromMap(doc.id, doc.data()!);
}
```

Tests können dann `fromMap` direkt aufrufen — ohne Firebase-Dependency.

**Option B:** `fake_cloud_firestore`-Package als dev_dependency hinzufügen. Schwergewichtiger, aber testet auch die `DocumentSnapshot`-Integration.

### 4.3 Neue Tests: Provider-Schicht

**Priorität: MITTEL** — Provider sind nach V1 dünn, aber Orchestrierung und Edge Cases (z.B. `uid == null`) sollten getestet werden.

#### Voraussetzung: Test-Helpers erstellen

```dart
// test/helpers/fake_repositories.dart

class FakeIncomeRepository implements IncomeSourceRepository {
  List<IncomeSource> items;

  FakeIncomeRepository([this.items = const []]);

  @override
  Future<List<IncomeSource>> getAllIncomeSources() async => items;

  @override
  Stream<List<IncomeSource>> watchAllIncomeSources() => Stream.value(items);

  @override
  Future<void> addIncomeSource(IncomeSource source) async {
    items = [...items, source];
  }

  @override
  Future<void> updateIncomeSource(IncomeSource source) async {
    items = items.map((s) => s.id == source.id ? source : s).toList();
  }

  @override
  Future<void> deleteIncomeSource(String id) async {
    items = items.where((s) => s.id != id).toList();
  }
}

class FakeExpenseNodeRepository implements ExpenseNodeRepository { ... }
class FakeTransactionRepository implements TransactionRepository { ... }
```

#### Test-Beispiele

```dart
// test/presentation/providers/budget_providers_test.dart

void main() {
  test('budgetHealth returns correct values', () async {
    final incomeRepo = FakeIncomeRepository([
      makeIncome(amount: 5000),
    ]);
    final expenseRepo = FakeExpenseNodeRepository([
      makeExpense(plannedAmount: 3000),
    ]);

    final container = ProviderContainer(overrides: [
      incomeSourceRepositoryProvider.overrideWithValue(incomeRepo),
      expenseNodeRepositoryProvider.overrideWithValue(expenseRepo),
    ]);
    addTearDown(container.dispose);

    final health = await container.read(budgetHealthProvider.future);
    expect(health.income, 5000.0);
    expect(health.expenses, 3000.0);
    expect(health.balance, 2000.0);
    expect(health.isDeficit, isFalse);
  });

  test('repository provider throws when not logged in', () {
    final container = ProviderContainer(overrides: [
      currentUserIdProvider.overrideWithValue(null),
    ]);
    addTearDown(container.dispose);

    expect(
      () => container.read(transactionRepositoryProvider),
      throwsA(isA<Exception>()),
    );
  });
}
```

### 4.4 Bestehende Tests verbessern

#### 4.4.1 `domain_entities_test.dart` — Aufwerten

Aktuelle Tests prüfen nur Constructor-Zuweisung (von Freezed generiert — trivial). Stattdessen:

```dart
group('ExpenseNode', () {
  test('isGroup returns true when children non-empty', () {
    final node = ExpenseNode(id: '1', name: 'X', children: [
      ExpenseNode(id: '2', name: 'Y'),
    ]);
    expect(node.isGroup, isTrue);
  });

  test('isGroup returns false when children empty', () {
    final node = ExpenseNode(id: '1', name: 'X', children: []);
    expect(node.isGroup, isFalse);
  });

  test('default sortOrder is 99999', () {
    final node = ExpenseNode(id: '1', name: 'X');
    expect(node.sortOrder, 99999);
  });

  test('Freezed equality: same values are equal', () {
    final a = ExpenseNode(id: '1', name: 'X', plannedAmount: 100);
    final b = ExpenseNode(id: '1', name: 'X', plannedAmount: 100);
    expect(a, equals(b));
  });

  test('Freezed equality: different values are not equal', () {
    final a = ExpenseNode(id: '1', name: 'X');
    final b = ExpenseNode(id: '2', name: 'X');
    expect(a, isNot(equals(b)));
  });

  test('copyWith creates modified copy', () {
    final original = ExpenseNode(id: '1', name: 'Old');
    final modified = original.copyWith(name: 'New');
    expect(modified.name, 'New');
    expect(modified.id, '1'); // Unverändert
    expect(original.name, 'Old'); // Original unverändert
  });
});

group('IncomeSource', () {
  test('default interval is monthly', () {
    final s = IncomeSource(id: '1', name: 'X', amount: 100);
    expect(s.interval, PaymentInterval.monthly);
  });

  test('default group is main', () {
    final s = IncomeSource(id: '1', name: 'X', amount: 100);
    expect(s.group, IncomeGroup.main);
  });
});
```

#### 4.4.2 Standalone-Test in `domain_entities_test.dart` einklammern

Der letzte Test (`'supports Group Node (null amount)'`) steht außerhalb jeder `group()`. In die `ExpenseNode`-Gruppe verschieben.

#### 4.4.3 `budget_calculator_test.dart` — Determinismus-Tests

Nach Einführung des `referenceDate`-Parameters:

```dart
group('calculateDashboardStats', () {
  test('returns stats for specific reference months', () {
    final node = makeExpense(id: 'e1', plannedAmount: 500);
    final txn = makeTransaction(
      expenseNodeId: 'e1',
      amount: 200,
      dateTime: DateTime(2025, 3, 15),
    );
    final result = calc.calculateDashboardStats(
      [node], [txn],
      monthCount: 3,
      referenceDate: DateTime(2025, 4, 1),
    );
    expect(result[0].month, DateTime(2025, 4));
    expect(result[0].totalSpent, 0.0);
    expect(result[1].month, DateTime(2025, 3));
    expect(result[1].totalSpent, 200.0);
    expect(result[2].month, DateTime(2025, 2));
    expect(result[2].totalSpent, 0.0);
  });
});
```

#### 4.4.4 `transaction_grouper_test.dart` — Sortierung testen

```dart
test('days are sorted newest first', () {
  final txns = [
    makeTransaction(id: 't1', dateTime: DateTime(2025, 6, 10)),
    makeTransaction(id: 't2', dateTime: DateTime(2025, 6, 15)),
    makeTransaction(id: 't3', dateTime: DateTime(2025, 6, 12)),
  ];
  final result = grouper.groupByDay(txns, []);
  final dates = result.map((d) => d.date).toList();
  expect(dates, [
    DateTime(2025, 6, 15),
    DateTime(2025, 6, 12),
    DateTime(2025, 6, 10),
  ]);
});
```

### 4.5 Widget-Tests (optional)

Widget-Tests werden als niedrigste Priorität eingestuft, da:
1. Die meisten Screens sind reine Darstellungslogik ohne komplexes Verhalten
2. Die Geschäftslogik liegt vollständig in getesteten Domain-Services
3. Widget-Tests sind aufwändiger in der Wartung

**Empfohlene Kandidaten (wenn Zeit vorhanden):**

| Widget | Testfokus | Wert |
|---|---|---|
| `AddTransactionDialog` | Formular-Validierung, Submit-Flow, Delete-Confirmation | Hoch |
| `AppRouter` | Routing basierend auf Auth-State | Mittel |
| `MonthSelector` | Korrekte Monatsanzeige, Scroll-Verhalten | Niedrig |

### 4.6 Neue Test-Ordnerstruktur

```
test/
├── domain_entities_test.dart         (bestehend, aufgewertet)
│
├── application/
│   └── budget_logic_test.dart        (bestehend, unverändert)
│
├── domain/
│   └── services/
│       ├── budget_calculator_test.dart    (bestehend + Determinismus-Tests)
│       ├── transaction_grouper_test.dart  (bestehend + Sortier-Tests)
│       ├── tree_builder_test.dart         (bestehend, unverändert)
│       └── yearly_calculator_test.dart    (bestehend, unverändert)
│
├── data/                             ← NEU
│   └── mappers/
│       ├── expense_node_mapper_test.dart
│       ├── income_mapper_test.dart
│       └── transaction_mapper_test.dart
│
├── presentation/                     ← NEU
│   └── providers/
│       ├── budget_providers_test.dart
│       └── repository_providers_test.dart
│
└── helpers/
    ├── test_data.dart                (bestehend, unverändert)
    └── fake_repositories.dart        ← NEU (Fake-Implementierungen)
```

---

## 5. Anhang: Migrations-Checkliste

### Phase 1: Kritische Architektur-Fixes

- [ ] `AuthController`-Notifier in `auth_provider.dart` erstellen
- [ ] `dashboard_screen.dart`: `data/auth_service.dart`-Import entfernen, `authControllerProvider` nutzen
- [ ] `login_screen.dart`: `data/auth_service.dart`-Import entfernen, `authControllerProvider` nutzen
- [ ] `currentUserIdProvider` auf `ref.watch(authStateProvider).valueOrNull?.uid` umstellen
- [ ] `build_runner` ausführen
- [ ] Bestehende Tests grün bestätigen
- [ ] Manuell testen: Login, Logout, App-Neustart

### Phase 2: Stream-Migration

- [ ] `allTransactionsProvider` (Stream) in `transaction_providers.dart` erstellen
- [ ] `transactionListProvider` auf Stream-basierte Quelle umbauen
- [ ] `TransactionMutations`-Notifier erstellen (oder Mutations in bestehenden Notifier belassen)
- [ ] `add_transaction_dialog.dart`: Alle `ref.invalidate()`-Aufrufe entfernen
- [ ] `add_transaction_dialog.dart`: CRUD über Notifier statt direkt über Repository
- [ ] `transaction_providers.dart`: `ref.invalidateSelf()` entfernen
- [ ] `build_runner` ausführen
- [ ] Manuell testen: Add/Edit/Delete → UI aktualisiert sich ohne Verzögerung

### Phase 3: Domain-Model-Freeze & Determinismus

- [ ] `BudgetHealth` auf Freezed migrieren
- [ ] `MonthlyBudgetStatus` auf Freezed migrieren
- [ ] `TransactionWithCategory` auf Freezed migrieren
- [ ] `DailyTransactions` auf Freezed migrieren
- [ ] `BudgetVsActualNode` auf Freezed migrieren
- [ ] `YearlyBudgetNode` auf Freezed migrieren
- [ ] `BudgetCalculator.calculateDashboardStats`: `referenceDate`-Parameter hinzufügen
- [ ] `TransactionGrouper.groupByDay`: Explizite Tagessortierung einbauen
- [ ] `build_runner` ausführen
- [ ] Alle bestehenden Tests grün bestätigen

### Phase 4: Infrastruktur-Polish

- [ ] `AuthService`: `print()` → `dev.log()`
- [ ] `dashboard_screen.dart`: `WelcomeScreen`-Import und manuelle Navigation entfernen
- [ ] Mapper-Serialisierung: PascalCase → `enum.name` (lowercase)
- [ ] `FirestoreExpenseNodeRepository`: `TreeBuilder` als Constructor-Parameter (mit Default)
- [ ] (Optional) `availableMonths`-Provider von `transactionList` entkoppeln

### Phase 5: Test-Offensive

- [ ] Mapper-Refactoring: `fromFirestore` → `fromMap` + `fromFirestore`-Wrapper
- [ ] `expense_node_mapper_test.dart` schreiben
- [ ] `income_mapper_test.dart` schreiben
- [ ] `transaction_mapper_test.dart` schreiben
- [ ] `domain_entities_test.dart` aufwerten (Equality, Defaults, `isGroup`, `copyWith`)
- [ ] `budget_calculator_test.dart` Determinismus-Tests ergänzen
- [ ] `transaction_grouper_test.dart` Sortier-Tests ergänzen
- [ ] `test/helpers/fake_repositories.dart` erstellen
- [ ] `budget_providers_test.dart` schreiben
- [ ] `repository_providers_test.dart` schreiben
- [ ] (Optional) `AddTransactionDialog` Widget-Test
- [ ] Alle Tests grün bestätigen
- [ ] Coverage-Report generieren und gegen Ziele prüfen

---

> **Dieses Dokument baut auf dem erfolgreich abgeschlossenen V1-Refactoring auf. Jede Phase kann unabhängig umgesetzt werden, solange die Reihenfolge innerhalb einer Phase eingehalten wird. Nach jeder Phase sollten alle Tests grün sein, bevor mit der nächsten fortgefahren wird.**
