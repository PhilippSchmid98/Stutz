# 02 Architecture

## Clean Architecture Layer Structure

```
lib/
├── core/                          # Shared Constants & Enums
│   ├── constants/
│   │   └── firebase_config.dart   # OAuth Web Client ID
│   └── enums/
│       └── enums.dart             # PaymentInterval, ExpenseType, IncomeGroup
│
├── data/                          # Implementierungs-Schicht (Firestore)
│   ├── auth_service.dart          # Firebase Auth + Google Sign-In (@Riverpod keepAlive)
│   ├── mappers/                   # Firestore Document ↔ Domain Model
│   │   ├── expense_node_mapper.dart
│   │   ├── income_mapper.dart
│   │   └── transaction_mapper.dart
│   └── repositories/              # Firestore Repository-Implementierungen
│       ├── firestore_expense_repository.dart
│       ├── firestore_income_repository.dart
│       └── firestore_transaction_repository.dart
│
├── domain/                        # Reine Business-Logik (keine Abhängigkeiten zu Flutter/Firebase)
│   ├── logic_extensions.dart      # Extensions: IncomeSource.monthlyAmount, ExpenseNode.totalMonthlyCalculated
│   ├── models/                    # Freezed Immutable Models
│   │   ├── models.dart            # Barrel-Export
│   │   ├── transaction.dart       # AppTransaction
│   │   ├── expense_node.dart      # ExpenseNode (Composite Pattern)
│   │   ├── income_source.dart     # IncomeSource
│   │   ├── budget_health.dart     # BudgetHealth (computed: balance, isDeficit)
│   │   ├── budget_vs_actual_node.dart  # BudgetVsActualNode (monatl. Vergleich)
│   │   ├── monthly_budget_status.dart  # MonthlyBudgetStatus (Dashboard)
│   │   ├── daily_transactions.dart     # DailyTransactions (Tagesgruppierung)
│   │   ├── transaction_with_category.dart  # TransactionWithCategory (angereichert)
│   │   └── yearly_budget_node.dart     # YearlyBudgetNode (Jahresvergleich mit Offset)
│   ├── repositories/              # Abstrakte Interfaces
│   │   ├── expense_repository.dart
│   │   ├── income_repository.dart
│   │   └── transaction_repository.dart
│   └── services/                  # Stateless Business Logic
│       ├── budget_calculator.dart    # Monatsberechnung, Health, Dashboard-Stats
│       ├── transaction_grouper.dart  # Tagesgruppierung + Kategorie-Enrichment
│       ├── tree_builder.dart         # Flat → Tree + Tree → Flat Konvertierung
│       └── yearly_calculator.dart    # Jahresberechnung mit Offset-Faktor
│
├── presentation/                  # UI + State Management
│   ├── app_router.dart            # Auth-basiertes Routing
│   ├── providers/                 # Riverpod 3 Provider (alle generiert via @riverpod)
│   │   ├── auth_provider.dart
│   │   ├── budget_providers.dart
│   │   ├── category_transactions_provider.dart
│   │   ├── connectivity_provider.dart
│   │   ├── dashboard_providers.dart
│   │   ├── monthly_detail_provider.dart
│   │   ├── repository_providers.dart
│   │   ├── transaction_providers.dart
│   │   └── yearly_detail_provider.dart
│   └── screens/
│       ├── home_screen.dart              # Bottom Navigation (3 Tabs)
│       ├── monthly_detail_screen.dart    # Monatlicher Ist-Soll-Vergleich
│       ├── yearly_detail_screen.dart     # Jahresansicht
│       ├── category_transactions_screen.dart  # Transaktionen einer Kategorie
│       ├── budget/
│       │   ├── budget_planning_screen.dart
│       │   ├── dialogs/                  # Add/Edit Dialoge
│       │   │   ├── add_expense_node_dialog.dart
│       │   │   ├── add_income_dialog.dart
│       │   │   └── add_main_category_dialog.dart
│       │   └── widgets/                  # Budget-spezifische Widgets
│       │       ├── budget_overview_card.dart
│       │       ├── expense_item_row.dart
│       │       ├── expense_section_card.dart
│       │       ├── income_item_row.dart
│       │       ├── income_section_card.dart
│       │       └── legend_row.dart
│       ├── dashboard/
│       │   ├── dashboard_screen.dart
│       │   └── widgets/
│       │       ├── current_month_card.dart
│       │       ├── past_month_tile.dart
│       │       └── stat_column.dart
│       ├── onboarding/
│       │   ├── login_screen.dart
│       │   ├── tutorial_screen.dart
│       │   └── welcome_screen.dart
│       ├── shared/                       # Wiederverwendbare UI-Komponenten
│       │   ├── add_button.dart
│       │   ├── section_card.dart
│       │   ├── styled_dropdown.dart
│       │   └── styled_text_field.dart
│       ├── transactions/
│       │   ├── add_transaction_dialog.dart
│       │   └── widgets/
│       │       ├── daily_transaction_group.dart
│       │       ├── month_selector.dart
│       │       └── transaction_item.dart
│       └── widgets/
│           └── cloud_status_icon.dart
│
├── firebase_options.dart          # Generierte Firebase-Konfiguration
└── main.dart                      # App Entry Point
```

---

## Schichtentrennung & Abhängigkeitsregeln

```
┌──────────────────────────────────────────┐
│            PRESENTATION                   │
│  Screens, Widgets, Providers              │
│  ↓ kennt nur Domain-Interfaces            │
├──────────────────────────────────────────┤
│              DOMAIN                       │
│  Models, Repository-Interfaces, Services  │
│  ↓ keine Abhängigkeiten nach oben/unten   │
├──────────────────────────────────────────┤
│               DATA                        │
│  Firestore Repos, Mappers, AuthService    │
│  ↑ implementiert Domain-Interfaces        │
└──────────────────────────────────────────┘
```

**Regeln:**
1. `domain/` importiert **niemals** aus `data/` oder `presentation/`
2. `presentation/` importiert aus `domain/` (Models, Interfaces, Services) — nie direkt aus `data/`
3. `data/` importiert aus `domain/` (um Interfaces zu implementieren)
4. Einzige Ausnahme: `repository_providers.dart` in `presentation/providers/` erstellt die konkreten Firestore-Implementierungen — dies ist der einzige Brückenpunkt

---

## Data Modeling

### Composite Pattern für Expenses
- Jeder Expense ist ein Node in einem Baum
- **Felder:**
  - `id` (String, UUID)
  - `parentId` (String?, null = Root-Node)
  - `name` (String)
  - `plannedAmount` (double?, null für Gruppen)
  - `interval` (PaymentInterval?, null für Gruppen)
  - `type` (ExpenseType?, null für Gruppen)
  - `children` (List\<ExpenseNode\>, virtuell — aufgebaut durch `TreeBuilder`)
  - `sortOrder` (int, default: 99999 für Lazy Migration)
- **`isGroup` Getter:** `children.isNotEmpty`

### Firestore-Struktur
```
users/{userId}/
  ├── expense_nodes/{nodeId}    # Flache Dokumente mit parentId-Referenz
  ├── incomes/{incomeId}        # IncomeSource-Dokumente
  └── transactions/{txnId}      # AppTransaction-Dokumente (sortiert nach dateTime)
```

### Mapper-Schicht
- `ExpenseNodeMapper`: Firestore Document ↔ ExpenseNode (keine Kinder — Baum wird separat aufgebaut)
- `IncomeMapper`: Firestore Document ↔ IncomeSource (parst Enums mit Fallbacks)
- `TransactionMapper`: Firestore Document ↔ AppTransaction (konvertiert Timestamp ↔ DateTime)

### Baum-Assembly
- `TreeBuilder.buildTree(flatNodes)`: Flache Liste → Parent-Child-Hierarchie (sortiert nach `sortOrder`, dann Name)
- `TreeBuilder.flattenTree(nodes)`: Depth-First Flattening (Parent vor Kindern)
- Baum wird **nach dem Laden** aus Firestore in `FirestoreExpenseNodeRepository` zusammengebaut

---

## State Management: Riverpod 3

### Provider-Hierarchie
```
authServiceProvider (keepAlive)
  └─ authStateProvider (keepAlive, Stream<User?>)
       ├─ voluntarySignOutProvider (keepAlive, Notifier<bool>)
       ├─ authControllerProvider (keepAlive, AsyncNotifier)
       ├─ seenOnboardingProvider (Future<bool>)
       └─ currentUserIdProvider (String?)
            ├─ transactionRepositoryProvider
            ├─ expenseNodeRepositoryProvider
            └─ incomeSourceRepositoryProvider
                 ├─ allTransactionsProvider (Stream)
                 ├─ incomeListProvider (Stream)
                 └─ expenseTreeProvider (Stream)
                      ├─ transactionListProvider (Future, grouped)
                      ├─ availableMonthsProvider (sync)
                      ├─ totalMonthlyIncomeProvider (Future)
                      ├─ totalMonthlyExpensesProvider (Future)
                      ├─ budgetHealthProvider (Future)
                      ├─ dashboardMonthlyStatsProvider (Future)
                      ├─ monthlyDetailTreeProvider(month) (Future, Family)
                      ├─ yearlyDetailTreeProvider(year) (Future, Family)
                      └─ categoryTransactionsProvider(ids, year, month?) (Future, Family)

connectivityStatusProvider (keepAlive, Stream)
  └─ isOfflineProvider (keepAlive, bool)

currentVisibleMonthProvider (Notifier<DateTime>)
transactionMutationsProvider (AsyncNotifier)
```

### Provider-Typen im Projekt
| Typ | Annotation | Beispiel | Verwendung |
|-----|------------|----------|------------|
| Einfacher Provider | `@riverpod` | `currentUserId` | Synchrone Berechnungen |
| Stream Provider | `@riverpod Stream<T>` | `incomeList`, `allTransactions` | Firestore-Echtzeit-Streams |
| Future Provider | `@riverpod Future<T>` | `budgetHealth`, `monthlyDetailTree` | Asynchrone Berechnungen |
| Family Provider | `@riverpod` mit Parameter | `categoryTransactions(ids, year, month?)` | Parametrisierte Abfragen |
| Notifier | `class X extends _$X` | `CurrentVisibleMonth`, `VoluntarySignOut` | Mutierbarer Zustand |
| AsyncNotifier | `class X extends _$X` | `AuthController`, `TransactionMutations` | Async Mutationen |
| KeepAlive | `@Riverpod(keepAlive: true)` | `authService`, `authState`, `connectivity` | Überlebt Dispose |

---

## ER-Diagramm (Textuell)

```
┌─────────────────────┐       ┌─────────────────────┐
│    IncomeSource      │       │     ExpenseNode      │
├─────────────────────┤       ├─────────────────────┤
│ id: String           │       │ id: String           │
│ name: String         │       │ parentId: String?    │──┐ (self-referencing)
│ amount: double       │       │ name: String         │  │
│ interval: Payment    │       │ plannedAmount: double?│  │
│ group: IncomeGroup   │       │ interval: Payment?   │  │
└─────────────────────┘       │ type: ExpenseType?   │  │
                              │ sortOrder: int       │  │
                              │ children: List<Node> │←─┘
                              └──────────┬──────────┘
                                         │ 1:N
                              ┌──────────┴──────────┐
                              │   AppTransaction     │
                              ├─────────────────────┤
                              │ id: String           │
                              │ expenseNodeId: String│
                              │ amount: double       │
                              │ dateTime: DateTime   │
                              │ note: String?        │
                              └─────────────────────┘
```

---

## Stateless Domain Services

| Service | Methoden | Beschreibung |
|---------|----------|--------------|
| `BudgetCalculator` | `totalMonthlyIncome()`, `totalMonthlyExpenses()`, `calculateHealth()`, `buildMonthlyDetail()`, `calculateDashboardStats()` | Monatsberechnung, nur variable Kosten, Pruning von leeren Nodes |
| `TreeBuilder` | `buildTree()`, `flattenTree()` | Flat ↔ Hierarchie Konvertierung |
| `TransactionGrouper` | `groupByDay()` | Tagesgruppierung + Kategorie-Anreicherung |
| `YearlyCalculator` | `calculateOffsetFactor()`, `buildYearlyDetail()` | Jahresanalyse mit Mid-Year-Offset |

Alle Services sind `const`-konstruierbar und zustandslos — sie empfangen ihre Daten als Parameter.
