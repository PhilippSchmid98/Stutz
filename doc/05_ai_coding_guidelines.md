# 05 AI Coding Guidelines

> **Zweck:** Strikte Regeln für AI-gestützte Code-Generierung in diesem Projekt.
> Jeder generierte Code MUSS diesen Richtlinien entsprechen. Bei Widersprüchen zwischen diesen Guidelines und dem bestehenden Code gelten diese Guidelines.

---

## 1. Architektur-Regeln

### 1.1 Layer-Trennung (STRENG)

```
presentation/ → darf importieren → domain/
data/         → darf importieren → domain/
domain/       → darf importieren → NICHTS aus data/ oder presentation/
```

**VERBOTEN:**
- ❌ `import 'package:stutz/data/...'` in `domain/`-Dateien
- ❌ `import 'package:cloud_firestore/...'` in `domain/`- oder `presentation/`-Dateien
- ❌ Direkte Firestore-Aufrufe in Screens oder Widgets

**Einzige Ausnahme:** `presentation/providers/repository_providers.dart` darf aus `data/repositories/` importieren, um die konkreten Implementierungen als Provider bereitzustellen.

### 1.2 Repository Pattern

- Neue Datenquellen: Abstrakte Interfaces in `domain/repositories/`, Implementierung in `data/repositories/`
- Mappers gehören in `data/mappers/` — nie in `domain/`
- Repositories liefern immer Domain-Models zurück, nie Firestore-Dokumente oder Maps

### 1.3 Domain Services

- Services sind **zustandslos** und `const`-konstruierbar
- Services empfangen ALLE Daten als Parameter — kein Zugriff auf Repositories oder Provider
- Instanzierung in Providern: `const MyService().methodName(...)`

```dart
// ✅ RICHTIG
class BudgetCalculator {
  const BudgetCalculator();
  BudgetHealth calculateHealth(List<IncomeSource> sources, List<ExpenseNode> roots) { ... }
}

// ❌ FALSCH — Service mit Abhängigkeiten
class BudgetCalculator {
  final ExpenseNodeRepository _repo;
  BudgetCalculator(this._repo);
}
```

---

## 2. Riverpod 3 — STRIKTE REGELN

> **KRITISCH:** Dieses Projekt verwendet Riverpod 3.x mit Code Generation. 
> Es darf **NIEMALS** veraltete Riverpod 2 Syntax verwendet werden.

### 2.1 VERBOTENE Syntax (Riverpod 2 — NIEMALS verwenden)

```dart
// ❌ VERBOTEN: StateNotifier
class MyNotifier extends StateNotifier<MyState> { ... }
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) => ...);

// ❌ VERBOTEN: Manuelle Provider-Definitionen
final myProvider = Provider<MyType>((ref) => ...);
final myProvider = FutureProvider<MyType>((ref) => ...);
final myProvider = StreamProvider<MyType>((ref) => ...);
final myProvider = StateProvider<MyType>((ref) => ...);
final myProvider = ChangeNotifierProvider<MyType>((ref) => ...);

// ❌ VERBOTEN: .family Konstruktor
final myProvider = FutureProvider.family<MyType, String>((ref, id) => ...);

// ❌ VERBOTEN: .autoDispose Modifier
final myProvider = Provider.autoDispose<MyType>((ref) => ...);

// ❌ VERBOTEN: ref.listen in build() für Datenbindung (statt ref.watch)
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen(myProvider, (prev, next) { ... }); // ❌ Nur für Seiteneffekte, nicht als Datenbindung
}
```

### 2.2 RICHTIGE Syntax (Riverpod 3 — IMMER verwenden)

#### Einfacher Provider (synchron)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'my_provider.g.dart';

@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
}
```

#### Stream Provider
```dart
@riverpod
Stream<List<IncomeSource>> incomeList(Ref ref) {
  return ref.watch(incomeSourceRepositoryProvider).watchAllIncomeSources();
}
```

#### Future Provider
```dart
@riverpod
Future<double> totalMonthlyIncome(Ref ref) async {
  final sources = await ref.watch(incomeListProvider.future);
  return sources.fold<double>(0.0, (sum, item) => sum + item.monthlyAmount);
}
```

#### Family Provider (mit Parametern)
```dart
@riverpod
Future<List<BudgetVsActualNode>> monthlyDetailTree(
  Ref ref,
  DateTime month,
) async {
  final expenseRepo = ref.watch(expenseNodeRepositoryProvider);
  final txnRepo = ref.watch(transactionRepositoryProvider);
  final rootNodes = await expenseRepo.getAllExpenseNodes();
  // ...
}
```

#### Family Provider (mit mehreren Parametern)
```dart
@riverpod
Future<List<AppTransaction>> categoryTransactions(
  Ref ref,
  List<String> nodeIds,
  int year,
  int? month,
) async {
  // Parameter werden direkt als Funktionsparameter übergeben
  // Riverpod 3 generiert automatisch die korrekte Family
}
```

#### Notifier (mutierbarer Zustand)
```dart
@riverpod
class CurrentVisibleMonth extends _$CurrentVisibleMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void set(DateTime date) {
    state = date;
  }
}
```

#### AsyncNotifier (asynchrone Mutationen)
```dart
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<User?> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authServiceProvider).signInAnonymously();
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}
```

#### keepAlive Provider
```dart
// Für Provider, die den gesamten App-Lebenszyklus überdauern müssen:
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}
```

### 2.3 ref.watch vs. ref.read vs. ref.listen — STRIKTE REGELN

| Kontext | `ref.watch` | `ref.read` | `ref.listen` |
|---------|-------------|------------|--------------|
| In `build()` Methode | ✅ IMMER | ❌ NIEMALS | ✅ Für Seiteneffekte |
| In Provider-Funktion | ✅ IMMER (vor await) | ❌ Nur für Mutationen | ✅ Für Seiteneffekte |
| In Callbacks (onTap, onPressed) | ❌ NIEMALS | ✅ IMMER | ❌ NIEMALS |
| In Notifier-Methoden | ❌ NIEMALS | ✅ IMMER | ❌ NIEMALS |

```dart
// ✅ RICHTIG: watch in build / Provider
@override
Widget build(BuildContext context, WidgetRef ref) {
  final stats = ref.watch(dashboardMonthlyStatsProvider);
  // ...
}

// ✅ RICHTIG: read in Callback
onPressed: () {
  ref.read(authControllerProvider.notifier).signOut();
}

// ✅ RICHTIG: read in AsyncNotifier-Methode
Future<void> addTransaction(AppTransaction txn) async {
  await ref.read(transactionRepositoryProvider).addTransaction(txn);
}
```

### 2.3a ref.listen — Seiteneffekte auf Zustandsänderungen

`ref.listen` registriert einen Callback, der auf **jede Zustandsänderung** reagiert, ohne einen Rebuild auszulösen. Es ist das richtige Werkzeug für Seiteneffekte wie SnackBars, Dialoge oder Navigationsaufrufe.

**REGELN:**
- Nur in `build()`-Methoden oder in Providern verwenden — **nie in Callbacks**
- Gibt keinen Wert zurück — kann nicht wie `ref.watch` zur Datenbindung genutzt werden
- Der Callback wird beim **ersten** Build **nicht** aufgerufen, nur bei nachfolgenden Änderungen

```dart
// ✅ RICHTIG: listen für Fehler-SnackBar in build()
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
    if (next is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anmeldung fehlgeschlagen')),
      );
    }
  });

  // ... restlicher Widget-Code
}

// ✅ RICHTIG: listen in einem Provider für reaktive Seiteneffekte
@riverpod
void someProvider(Ref ref) {
  ref.listen(authStateProvider, (previous, next) {
    // Reagiere auf Auth-Zustandsänderungen
  });
}

// ❌ FALSCH: listen in einem Callback
onPressed: () {
  ref.listen(authControllerProvider, (_, __) { ... }); // ❌ NIEMALS in Callbacks
}

// ❌ FALSCH: listen als Datenbindung
@override
Widget build(BuildContext context, WidgetRef ref) {
  // listen gibt keinen Wert zurück — für Datenbindung ref.watch() verwenden
  ref.listen(myProvider, (_, value) {
    final x = value; // ❌ Kein direktes Lesen — dafür ref.watch() nutzen
  });
}
```

**Faustregel:**
- Brauchst du den **Wert** des Providers im Widget-Baum? → `ref.watch()`
- Willst du auf **Änderungen reagieren** (SnackBar, Navigation)? → `ref.listen()`
- Brauchst du den Wert **einmalig** in einem Callback? → `ref.read()`

### 2.4 Async Provider — ref.watch VOR await

**KRITISCH:** In async Providern müssen ALLE `ref.watch()`-Aufrufe **synchron VOR dem ersten `await`** erfolgen. Andernfalls kann Riverpod die Abhängigkeiten nicht korrekt tracken.

```dart
// ✅ RICHTIG: Alle watches synchron, dann await
@riverpod
Future<BudgetHealth> budgetHealth(Ref ref) async {
  final sourcesFuture = ref.watch(incomeListProvider.future);
  final rootsFuture = ref.watch(expenseTreeProvider.future);
  final sources = await sourcesFuture;
  final roots = await rootsFuture;
  return const BudgetCalculator().calculateHealth(sources, roots);
}

// ❌ FALSCH: watch nach await
@riverpod
Future<BudgetHealth> budgetHealth(Ref ref) async {
  final sources = await ref.watch(incomeListProvider.future);
  final roots = await ref.watch(expenseTreeProvider.future); // ❌ watch nach await!
  return const BudgetCalculator().calculateHealth(sources, roots);
}
```

### 2.5 Provider-Datei-Konventionen

Jede Provider-Datei MUSS enthalten:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'dateiname.g.dart';
```

Nach jeder Änderung an Provider-Dateien:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2.6 Kein manuelles Invalidieren bei Streams

Da alle Daten über Firestore-Streams fließen, ist **kein `ref.invalidate()`** nach Mutationen nötig. Die Streams aktualisieren sich automatisch.

```dart
// ✅ RICHTIG: Einfach die Mutation ausführen
Future<void> addTransaction(AppTransaction txn) async {
  await ref.read(transactionRepositoryProvider).addTransaction(txn);
  // Kein ref.invalidate() nötig — Stream aktualisiert sich automatisch
}

// ❌ FALSCH: Manuelles Invalidieren
Future<void> addTransaction(AppTransaction txn) async {
  await ref.read(transactionRepositoryProvider).addTransaction(txn);
  ref.invalidate(allTransactionsProvider); // ❌ Unnötig und fehleranfällig
}
```

---

## 3. Widget-Typen — Wann welcher?

| Widget-Typ | Wann verwenden | Beispiel |
|------------|----------------|----------|
| `StatelessWidget` | Kein State, kein Riverpod | `LegendRow`, `AddButton`, `StatColumn` |
| `ConsumerWidget` | Riverpod-Zugriff, kein lokaler State | `DashboardScreen`, `MonthlyDetailScreen` |
| `HookConsumerWidget` | Riverpod + lokaler State (useState, useRef, useTextEditingController) | `TransactionScreen`, `AddTransactionDialog`, `LoginScreen` |
| `StatefulWidget` | Lokaler State, kein Riverpod | `HomeScreen` (Bottom Nav Index), `TutorialScreen` (PageController) |

**REGEL:** Bevorzuge `ConsumerWidget` über `HookConsumerWidget`, wenn kein Flutter Hooks benötigt wird. Verwende `StatelessWidget`, wenn kein Riverpod-Zugriff nötig ist.

---

## 4. Domain Models (Freezed)

### 4.1 Freezed-Konventionen

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_model.freezed.dart';

@freezed
abstract class MyModel with _$MyModel {
  const factory MyModel({
    required String id,
    required String name,
    double? optionalField,
    @Default(0) int sortOrder,
    @Default([]) List<MyModel> children,
  }) = _MyModel;
}
```

**REGELN:**
- Alle Domain Models MÜSSEN `@freezed` verwenden
- Berechnete Felder als Getter auf der Factory oder als Extension
- Keine `toJson`/`fromJson` in Domain Models — Mapping gehört in `data/mappers/`
- Barrel-Export über `models.dart`

### 4.2 Enums

Neue Enums in `lib/core/enums/enums.dart` definieren:
```dart
enum PaymentInterval { monthly, yearly }
enum ExpenseType { fixed, variable }
enum IncomeGroup { main, additional }
```

### 4.3 Extensions

Business-Logic-Extensions auf Domain Models in `lib/domain/logic_extensions.dart`:
```dart
extension IncomeSourceX on IncomeSource {
  double get monthlyAmount =>
      interval == PaymentInterval.yearly ? amount / 12 : amount;
}
```

---

## 5. Data Layer Konventionen

### 5.1 Mapper

Mapper sind statische Utility-Klassen:
```dart
class MyMapper {
  MyMapper._(); // Privater Konstruktor — nicht instanzierbar

  static MyModel fromMap(String id, Map<String, dynamic> data) { ... }
  static MyModel fromFirestore(DocumentSnapshot doc) {
    return fromMap(doc.id, doc.data()! as Map<String, dynamic>);
  }
  static Map<String, dynamic> toFirestore(MyModel model) { ... }
}
```

### 5.2 Firestore Repository

```dart
class FirestoreMyRepository implements MyRepository {
  final String userId;
  FirestoreMyRepository(this.userId);

  CollectionReference get _collection =>
      FirebaseFirestore.instance.collection('users/$userId/my_collection');

  @override
  Stream<List<MyModel>> watchAll() {
    return _collection.snapshots().map((snap) =>
        snap.docs.map(MyMapper.fromFirestore).toList());
  }

  @override
  Future<void> add(MyModel item) async {
    await _collection.doc(item.id).set(MyMapper.toFirestore(item));
  }
}
```

### 5.3 Firestore-Pfade
- Alle Daten unter `users/{userId}/` (User-isoliert)
- Collection-Namen: Plural, snake_case (`expense_nodes`, `incomes`, `transactions`)

---

## 6. UI/UX Code-Konventionen

### 6.1 Navigation

```dart
// Push zu neuem Screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => MonthlyDetailScreen(month: status.month),
  ),
);

// Zurück
Navigator.of(context).pop();
```

Kein deklarativer Router (GoRouter etc.) — einfaches imperative `Navigator.push/pop`.

### 6.2 Dialoge

```dart
showDialog(
  context: context,
  builder: (context) => const AddTransactionDialog(),
);
```

Alle Edit-Dialoge akzeptieren ein optionales `existing`-Objekt für den Edit-Modus.

### 6.3 AsyncValue-Handling in Widgets

```dart
final statsAsync = ref.watch(dashboardMonthlyStatsProvider);

return statsAsync.when(
  data: (stats) => _buildContent(stats),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text('Fehler: $e')),
);
```

### 6.4 Farb-Logik für Budget-Indikatoren

```dart
Color getIndicatorColor(double percentage) {
  if (percentage > 1.0) return Colors.red;
  if (percentage > 0.85) return Colors.orange;
  return Colors.teal;
}
```

### 6.5 Datumsformatierung

```dart
import 'package:intl/intl.dart';

// Monat + Jahr (deutsch)
DateFormat('MMMM yyyy', 'de_CH').format(date)  // "März 2026"

// Kurzer Monat
DateFormat('MMM', 'de_CH').format(date)  // "Mär"

// Wochentag
DateFormat('EEEE', 'de_CH').format(date)  // "Freitag"
```

---

## 7. Testing-Konventionen

### 7.1 Test-Struktur

```
test/
├── domain/
│   └── services/     # Unit Tests für alle Domain Services
├── data/
│   └── mappers/      # Unit Tests für alle Mapper
├── presentation/
│   └── providers/    # Provider Tests mit Overrides
├── application/
│   └── ...           # Integration/Logic Tests
├── helpers/
│   ├── test_data.dart      # Factory Helpers (makeIncome, makeExpense, makeTransaction)
│   └── fake_repositories.dart  # Fake Repository Implementierungen
└── domain_entities_test.dart
```

### 7.2 Factory Helpers

Verwende die bestehenden Helper in `test/helpers/test_data.dart`:
```dart
final income = makeIncome(amount: 5000, interval: PaymentInterval.yearly);
final expense = makeExpense(id: 'e1', name: 'Essen', plannedAmount: 300);
final txn = makeTransaction(expenseNodeId: 'e1', amount: 50);
```

### 7.3 Test-Benennung

```dart
group('BudgetCalculator', () {
  test('calculates health with income and expenses', () { ... });
  test('returns zero balance when no data', () { ... });
});
```

---

## 8. Code-Stil & Formatierung

### 8.1 Dateinamen
- snake_case für alle Dart-Dateien: `budget_calculator.dart`
- Generierte Dateien: `*.g.dart` (Riverpod), `*.freezed.dart` (Freezed)

### 8.2 Imports
- Package-Imports vor relativen Imports
- `part 'dateiname.g.dart';` direkt nach Imports
- Keine unbenutzen Imports

### 8.3 Kommentare
- Kurze `///` Doc-Comments auf Provider-Funktionen (Zweck, was sie streamen/berechnen)
- Inline-Kommentare nur bei nicht-offensichtlicher Logik
- Kommentarsprache: Deutsch oder Englisch (mischen OK, Konsistenz innerhalb einer Datei)

### 8.4 Fehlermeldungen
- UI-Texte: Deutsch (`'Anmeldung fehlgeschlagen'`, `'Pflichtfeld'`)
- Log-Messages: Englisch (`'Google sign-in canceled by user'`)
- Exception-Messages: Englisch (`'Not logged in (TransactionRepo)'`)

---

## 9. Zusammenfassung der Key Rules

| # | Regel | Priorität |
|---|-------|-----------|
| 1 | **IMMER** `@riverpod` Annotation + Code Generation verwenden | 🔴 KRITISCH |
| 2 | **NIEMALS** `StateNotifier`, `StateProvider`, `ChangeNotifier` verwenden | 🔴 KRITISCH |
| 3 | **NIEMALS** manuelle `Provider()`, `FutureProvider()`, `StreamProvider()` Konstruktoren | 🔴 KRITISCH |
| 4 | `ref.watch()` in build/Provider, `ref.read()` in Callbacks/Notifier | 🔴 KRITISCH |
| 5 | Alle `ref.watch()`-Aufrufe SYNCHRON vor dem ersten `await` | 🔴 KRITISCH |
| 6 | Domain darf nie aus Data oder Presentation importieren | 🟡 HOCH |
| 7 | Services sind zustandslos und `const`-konstruierbar | 🟡 HOCH |
| 8 | Alle Domain Models müssen `@freezed` sein | 🟡 HOCH |
| 9 | Kein `ref.invalidate()` bei Stream-basierten Daten | 🟡 HOCH |
| 10 | `ConsumerWidget` bevorzugen, `HookConsumerWidget` nur bei Hooks-Bedarf | 🟢 MITTEL |
