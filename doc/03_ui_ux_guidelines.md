# 03 UI/UX Guidelines

## Design-System

### Material 3
- **Theme:** `ThemeData(useMaterial3: true)` mit `ColorScheme.fromSeed(seedColor: Colors.teal)`
- **Brightness:** Nur Light Mode (kein Dark Mode implementiert)
- **Lokalisierung:** `de-CH` als einzige Locale, alle Labels in Deutsch

### Farbsystem
| Verwendung | Farbe | Kontext |
|---|---|---|
| Primärfarbe / Akzent | **Teal** | Fortschrittsbalken, aktive Elemente, Selected Month |
| Budget OK (< 85%) | **Teal** | Circular/Linear Indicators |
| Budget Warnung (85–100%) | **Orange** | Indicators |
| Budget Überschritten (> 100%) | **Rot** | Indicators |
| Positiver Saldo | **Grün (Teal)** | Verbleibendes Budget, Überschuss |
| Negativer Saldo | **Rot** | Defizit-Anzeige |
| Offset (Jahresansicht) | **Blau** | Stacked Progress Bar |
| Fixkosten-Text | **Grau** | Gedämpfte Darstellung |
| Variable Kosten-Text | **Schwarz** | Hervorgehobene Darstellung |
| Hintergründe | **Weiß + Grau(50)** | Karten, Input-Felder |

### Typografie
- **Beträge:** Große, fette Zahlen (z.B. 42pt im Transaktions-Dialog, 24pt auf Karten)
- **Labels:** Kleinere, graue Texte für Beschreibungen
- **Kategorienamen:** Bold für Gruppen, Normal für Blätter
- **Währung:** "CHF" als Suffix/Label (nie als Prefix)

### Icon-System
| Icon | Bedeutung |
|---|---|
| `Icons.lock` | Fixkosten |
| `Icons.shopping_bag` | Variable Kosten / Transaktion |
| `Icons.folder` | Gruppe (Kategorie mit Kindern) |
| `Icons.trending_up` | Einnahmen |
| `Icons.monetization_on` | Einzelne Einnahme |
| `Icons.cloud_off` | Offline-Status |
| `Icons.calendar_today` | Jahresansicht |
| `Icons.pie_chart_outline` | Tutorial: Fix vs. Variabel |
| `Icons.savings` | Welcome-Screen |

---

## Screens & Navigation

### Navigation-Struktur
```
AppRouter (Auth-basiert)
├─ WelcomeScreen (wenn nicht eingeloggt + Onboarding nicht gesehen)
│   └─ TutorialScreen (3-seitiger PageView)
│       └─ LoginScreen
├─ LoginScreen (wenn nicht eingeloggt + Onboarding gesehen)
└─ HomeScreen (wenn eingeloggt)
    ├─ Tab 0: DashboardScreen
    │   ├─ → MonthlyDetailScreen (Tap auf Monatskarte)
    │   │   └─ → CategoryTransactionsScreen (Tap auf Kategorie)
    │   ├─ → YearlyDetailScreen (AppBar-Icon)
    │   │   └─ → CategoryTransactionsScreen (Tap auf Kategorie)
    │   └─ → AddTransactionDialog (FAB)
    ├─ Tab 1: BudgetPlanningScreen
    │   ├─ → AddMainCategoryDialog
    │   ├─ → AddExpenseNodeDialog (Entry/Group, Add/Edit/Delete)
    │   └─ → AddIncomeDialog (Add/Edit/Delete)
    └─ Tab 2: TransactionScreen
        └─ → AddTransactionDialog (FAB oder Tap auf Transaktion)
```

### HomeScreen
- **Widget:** `StatefulWidget` mit `IndexedStack` (erhält Scroll-State aller Tabs)
- **Bottom Navigation:** Material `NavigationBar` mit 3 Destinations
  - Dashboard (Index 0)
  - Budget Planung (Index 1)
  - Transaktionen (Index 2)

---

## Screen-Details

### 1. Onboarding Flow

#### WelcomeScreen
- **Layout:** Zentriert, SafeArea
- **Elemente:** Teal Circle Icon (80pt, savings), Titel "Hallo bei Stutz", Untertitel, "Tour starten" FilledButton (schwarz)

#### TutorialScreen
- **Layout:** `PageView` mit 3 Seiten
- **Seiten:**
  1. "Fix vs. Variabel" (pie_chart_outline Icon)
  2. "Monatlich & Jährlich" (calendar_today Icon)
  3. "Offline First" (cloud_off Icon)
- **Navigation:** "Überspringen" in AppBar, animierte Dots, "Weiter" bzw. "Alles klar" Button
- **Dots:** Aktuell = 24w breit (teal), Rest = 8w (grau)

#### LoginScreen
- **Layout:** Zentriert, SafeArea
- **Elemente:** Lock Icon (60pt), Titel "Anmelden", Subtitle, zwei Buttons:
  - "Mit Google fortfahren" (Google Sign-In)
  - "Ohne Account fortfahren (Gast)" (Anonymous)
- **Fehlerbehandlung:** SnackBar bei fehlgeschlagener Anmeldung via `authControllerProvider` Listener
- **Widget-Typ:** `HookConsumerWidget` (useState für isLoading)

### 2. DashboardScreen
- **Widget:** `ConsumerWidget`
- **AppBar:** Titel "Dashboard", Actions: CloudStatusIcon, Jahresansicht-Button, Logout-Button
- **FAB:** "Neue Ausgabe" → AddTransactionDialog
- **Body:**
  - `CurrentMonthCard` (aktueller Monat): GestureDetector → MonthlyDetailScreen
    - Container mit Schatten, CircularPercentIndicator (80pt Radius, 12pt Linie)
    - Verbleibendes Budget in CHF, 3 StatColumn (Ausgegeben, Geplant, Verbraucht)
  - `PastMonthTile` (vergangene Monate): LinearPercentIndicator
    - Monatsbadge (50×50), Prozentanzeige, Actual/Planned in CHF

### 3. BudgetPlanningScreen
- **Widget:** `ConsumerWidget`
- **AppBar:** Titel "Budget Planung" + CloudStatusIcon
- **Body (ScrollView):**
  1. `IncomeSectionCard` (grün getönt): Haupt- + Nebeneinnahmen, SubsectionTitles
  2. Separater Divider
  3. `ExpenseSectionCard` pro Root-Node: Header mit Folder-Icon + Totals, ExpenseItemRows (rekursiv)
  4. "Hauptkategorie hinzufügen" Button → AddMainCategoryDialog
  5. `BudgetOverviewCard`: Monatliches Budget (Ø), Überschuss/Defizit, Fix/Variabel-Aufschlüsselung
  6. `LegendRow`: Lock=Fix, ShoppingBag=Variabel, Folder=Gruppe

### 4. TransactionScreen
- **Widget:** `HookConsumerWidget` (Flutter Hooks für ScrollController, Refs)
- **AppBar:** Titel "Transaktionen" + CloudStatusIcon
- **FAB:** "+" → AddTransactionDialog
- **Body:**
  - `CleanMonthSelector`: Horizontale Monatsleiste, animierte Text-Größe (18pt selected, 15pt unselected), Auto-Scroll
  - `ScrollablePositionedList`: Smart-Scroll-Erkennung (Rule 1: Top = erster Monat, Rule 2: Bottom-most sichtbares Item)
  - `DailyTransactionGroup`: Datum-Header (dd + Wochentag) + Tagessumme, TransactionItems
  - `TransactionItem`: Icon + Kategorie (bold) + Notiz (grau) + Betrag (rechts, "−" Prefix)

### 5. AddTransactionDialog
- **Widget:** `HookConsumerWidget`
- **Modus:** Add (neuer Eintrag) oder Edit (bestehender Eintrag)
- **Felder:**
  - **Betrag:** 42pt zentrierter Text, "CHF" Suffix
  - **Kategorie:** RawAutocomplete (nur variable Nodes, max 200px Dropdown)
  - **Datum/Uhrzeit:** DatePicker + TimePicker (schwarzes Theme)
  - **Notiz:** Optionales Textfeld
- **Actions:** Speichern (Add/Update), Löschen (nur Edit, mit Bestätigung)

### 6. MonthlyDetailScreen
- **Widget:** `ConsumerWidget`
- **AppBar:** Monatsname (deutsch) + "(Variabel)" Tag
- **Header:** "Kategorie | Ist | Budget"
- **Body:** Rekursive `_ComparisonNodeRow` mit:
  - Einrückung nach Tiefe
  - Farbcodierter Fortschrittsbalken (Teal/Orange/Rot)
  - Aufklappbare Gruppen
  - Tap → CategoryTransactionsScreen
- **Footer:** Total Actual vs. Budget, Fortschrittsbalken, Verbleibendes Budget (grün/rot)

### 7. YearlyDetailScreen
- **Widget:** `HookConsumerWidget`
- **AppBar:** Jahresnavigation (← Jahr →), Jahresfortschritt (XX% Jahr)
- **Features:**
  - Info-Banner wenn Offset > 0 mit Toggle-Switch
  - Spalten: "Kategorie | Verbrauch | %"
  - Rekursive `_YearlyNodeRow`
  - `_StackedProgressBar`: Offset (blau) + Actual (teal)
- **Footer:** Jahresbilanz mit optionaler Offset-Aufschlüsselung

### 8. CategoryTransactionsScreen
- **Widget:** `ConsumerWidget`
- **Parameter:** `nodeName`, `nodeIds`, `nodeNames`, `year`, `month?`
- **AppBar:** Kategoriename (bold) + Periodenbezeichnung
- **Body:** Transaktionsliste mit Datums-Block (dd | MMM), Notiz, Node-Name, Betrag
- **Footer:** Anzahl + Gesamtsumme

---

## Wiederverwendbare Widgets

### Shared Widgets (`screens/shared/`)
| Widget | Beschreibung |
|--------|-------------|
| `SectionCard` | Karte mit Header (Icon, Titel, Totals), Divider, Children. Für Budget-Sektionen. |
| `SubsectionTitle` | Uppercase graues Label mit Letter-Spacing |
| `StyledTextField` | TextFormField mit Teal Focus-Border, Grau-Hintergrund, Validator |
| `StyledDropdown` | DropdownButtonFormField mit gleichem Styling |
| `AddButton` | Farbiger "+ Label" Centered Text in gerundeter Box |

### App-weite Widgets (`screens/widgets/`)
| Widget | Beschreibung |
|--------|-------------|
| `CloudStatusIcon` | Zeigt `cloud_off` Icon wenn offline, sonst unsichtbar |

---

## Dialog-Pattern
- Alle Dialoge sind `HookConsumerWidget` (useState für lokalen State)
- AlertDialog mit Form-Validierung
- "Abbrechen" TextButton + "Speichern/Erstellen" schwarz gefüllter Button
- Delete-Action nur im Edit-Modus mit Bestätigungs-Dialog
- UUIDs werden via `uuid` Package generiert
