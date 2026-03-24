# 04 Step-by-Step Plan

## Abgeschlossene Meilensteine

### 1. Setup Project & Dependencies
- ✅ Flutter-Projekt initialisiert (SDK ^3.10.7)
- ✅ Alle Dependencies hinzugefügt: Riverpod 3, Freezed 3, Firebase, Hooks, UI-Packages
- ✅ Code-Generation Pipeline eingerichtet (`build_runner` für `@riverpod` + `@freezed`)

### 2. Project Structure
- ✅ Clean Architecture Ordnerstruktur: `lib/core`, `lib/domain`, `lib/data`, `lib/presentation`
- ✅ Test-Spiegel-Struktur: `test/domain`, `test/data`, `test/presentation`, `test/helpers`

### 3. Domain Layer
- ✅ Alle Domain Models mit Freezed definiert:
  - `AppTransaction`, `ExpenseNode`, `IncomeSource`, `BudgetHealth`,
  - `BudgetVsActualNode`, `MonthlyBudgetStatus`, `DailyTransactions`,
  - `TransactionWithCategory`, `YearlyBudgetNode`
- ✅ Abstrakte Repository Interfaces: `ExpenseNodeRepository`, `IncomeSourceRepository`, `TransactionRepository`
- ✅ Logic Extensions: `IncomeSource.monthlyAmount`, `ExpenseNode.totalMonthlyCalculated`
- ✅ Stateless Services: `BudgetCalculator`, `TreeBuilder`, `TransactionGrouper`, `YearlyCalculator`
- ✅ Barrel-Export `models.dart`

### 4. Data Layer
- ✅ Migration von Drift (SQLite) zu Firebase Cloud Firestore abgeschlossen
- ✅ Firestore ↔ Domain Mappers: `TransactionMapper`, `IncomeMapper`, `ExpenseNodeMapper`
- ✅ Firestore Repository-Implementierungen mit Echtzeit-Streams (`watchAll*`)
- ✅ Baum-Assembly: `TreeBuilder` wird in `FirestoreExpenseNodeRepository` verwendet
- ✅ `AuthService` mit Google Sign-In + Anonymous Auth (Riverpod keepAlive Provider)
- ✅ `FirebaseConfig` Konstanten für OAuth Web Client ID
- ✅ Core Enums: `PaymentInterval`, `ExpenseType`, `IncomeGroup`

### 5. Presentation Layer — Providers
- ✅ Alle Provider mit Riverpod 3 Code Generation (`@riverpod`)
- ✅ Auth Provider: `AuthController`, `VoluntarySignOut`, `authState`, `seenOnboarding`
- ✅ Repository Provider: `currentUserId`, `transactionRepository`, `expenseNodeRepository`, `incomeSourceRepository`
- ✅ Budget Provider: `incomeList`, `expenseTree`, `totalMonthlyIncome`, `totalMonthlyExpenses`, `budgetHealth`
- ✅ Transaction Provider: `CurrentVisibleMonth`, `allTransactions`, `transactionList`, `availableMonths`, `TransactionMutations`
- ✅ Dashboard Provider: `dashboardMonthlyStats`
- ✅ Detail Provider: `monthlyDetailTree` (Family), `yearlyDetailTree` (Family), `categoryTransactions` (Family)
- ✅ Connectivity Provider: `connectivityStatus`, `isOffline`

### 6. Presentation Layer — Screens & Widgets
- ✅ `AppRouter`: Auth-basiertes Routing (Splash → Welcome → Login → Home)
- ✅ Onboarding: `WelcomeScreen`, `TutorialScreen` (3 Seiten), `LoginScreen`
- ✅ `HomeScreen` mit Bottom Navigation (3 Tabs, IndexedStack)
- ✅ `DashboardScreen` mit `CurrentMonthCard` + `PastMonthTile`
- ✅ `BudgetPlanningScreen` mit `IncomeSectionCard`, `ExpenseSectionCard`, `BudgetOverviewCard`
- ✅ `TransactionScreen` mit `CleanMonthSelector`, `ScrollablePositionedList`, Smart-Scroll
- ✅ `AddTransactionDialog` mit Autocomplete, DatePicker, Add/Edit/Delete
- ✅ `MonthlyDetailScreen` mit rekursivem Ist-Soll-Vergleich
- ✅ `YearlyDetailScreen` mit Offset-Berechnung und Stacked Progress Bars
- ✅ `CategoryTransactionsScreen` für Drill-Down
- ✅ Budget-Dialoge: `AddExpenseNodeDialog`, `AddIncomeDialog`, `AddMainCategoryDialog`
- ✅ Shared Widgets: `SectionCard`, `StyledTextField`, `StyledDropdown`, `AddButton`, `CloudStatusIcon`

### 7. Dashboard Features
- ✅ Aktueller Monat mit Circular Indicator und Ampel-Farbsystem
- ✅ Vergangene Monate mit linearen Fortschrittsbalken
- ✅ Nur variable Ausgaben im Tracking (Fixkosten werden abgezogen)
- ✅ FAB für Schnellerfassung

### 8. Variable Expense Tracking
- ✅ Transaktionserfassung: Betrag, Kategorie (Autocomplete), Datum/Uhrzeit, Notiz
- ✅ Tagesgruppierung mit Tagessummen
- ✅ Smart-Scroll mit automatischer Monatserkennung
- ✅ Bearbeiten + Löschen bestehender Transaktionen

### 9. Analysis Features
- ✅ Monatlicher Ist-Soll-Vergleich (rekursiver Baum, nur variable Kosten)
- ✅ Jährliche Analyse mit Mid-Year-Offset
- ✅ Kategorie-Drill-Down auf Transaktionsebene

### 10. Firebase & Auth
- ✅ Firebase Core + Auth + Cloud Firestore integriert
- ✅ Google Sign-In mit Lazy Init (verhindert Cancellation Bugs)
- ✅ Anonymous Auth für Gast-Zugang
- ✅ Involuntary Logout Detection mit erklärendem SnackBar
- ✅ Echtzeit-Sync über Firestore Streams

### 11. CI/CD
- ✅ GitHub Actions Pipeline: Tests → APK Build → GitHub Release + AAB → Play Store (Internal)
- ✅ Secret Management für Keystore, Google Services, Service Account

### 12. Testing
- ✅ Test-Infrastruktur: `test_data.dart` (Factory Helpers), `fake_repositories.dart`
- ✅ Domain Service Tests: `budget_calculator_test.dart`, `transaction_grouper_test.dart`, `tree_builder_test.dart`, `yearly_calculator_test.dart`
- ✅ Data Mapper Tests: `expense_node_mapper_test.dart`, `income_mapper_test.dart`, `transaction_mapper_test.dart`
- ✅ Application Logic Test: `budget_logic_test.dart`
- ✅ Domain Entities Test: `domain_entities_test.dart`
- ✅ Provider Tests: `budget_providers_test.dart`, `repository_providers_test.dart`

---

## Nächste Schritte (Roadmap)

### Phase 4: Polish & UX Improvements
- ⬜ Dark Mode Support (Theme Switching)
- ⬜ Showcaseview-Integration für In-App-Tutorials (Dependency bereits vorhanden)
- ⬜ Animations/Transitions zwischen Screens verfeinern (Dependency `animations` vorhanden)
- ⬜ Drag-and-Drop Sortierung für Expense Nodes im Budget-Screen
- ⬜ Leere Zustände (Empty States) mit Illustrationen verbessern

### Phase 5: Feature Erweiterungen
- ⬜ Wiederkehrende Transaktionen (Recurring Transactions)
- ⬜ Daten-Export (CSV/PDF)
- ⬜ Multi-Währungs-Support
- ⬜ Budget-Vorlagen / Presets für Schnellstart
- ⬜ Monats-Vergleichs-Charts (Barkendiagramme Dashboard)

### Phase 6: Plattform & Distribution
- ⬜ iOS Release vorbereiten + App Store Deployment
- ⬜ Play Store Release (aktuell nur Internal Track)
- ⬜ Firebase Security Rules hardenen (Produktions-Rules)

### Phase 7: Testing & Qualitätssicherung
- ⬜ Widget Tests für alle Screens
- ⬜ Integration Tests (End-to-End Flow)
- ⬜ Test Coverage > 80% anstreben
- ⬜ Performance Profiling (große Datensätze)
