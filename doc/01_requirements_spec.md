# 01 Requirements Specification

## App Name
**Stutz** – *Dein Geld. Dein Vibe. Dein Stutz.*

## Purpose
Ein persönlicher Finanz-Tracker für Android, der finanzielle Klarheit über komplexer Buchhaltung stellt. Die App beantwortet die zentrale Frage: *Wie viel Geld ist wirklich noch verfügbar, nachdem alle Fixkosten gedeckt sind?*

## Implementierte Funktionale Anforderungen

### 1. Authentifizierung & Onboarding
- **Google Sign-In:** OAuth 2.0 via Firebase Auth mit Web Client ID
- **Anonyme Anmeldung:** Gast-Zugang über Firebase Anonymous Auth
- **Onboarding-Flow:**
  - WelcomeScreen → TutorialScreen (3 Seiten: Fix vs. Variabel, Intervalle, Cloud) → LoginScreen
  - `seenOnboarding`-Flag in SharedPreferences steuert Routing-Entscheidung
- **Involuntary Logout Detection:** AppRouter erkennt unerwartete Abmeldungen (z.B. Account deaktiviert) und zeigt erklärendes SnackBar
- **Routing:** Auth-State-basiert über `AppRouter` (ConsumerWidget), reagiert reaktiv auf `authStateProvider`

### 2. Budget Planung (Kernmodell)
- **Einnahmen (IncomeSource):**
  - Mehrere Quellen mit Name, Betrag, Intervall (Monatlich/Jährlich)
  - Gruppierung als "Haupteinnahmen" (`main`) und "Nebeneinnahmen" (`additional`)
  - Jährliche Einnahmen werden automatisch durch 12 geteilt für die Monatsansicht
- **Ausgaben (ExpenseNode) — Baumstruktur:**
  - Composite Pattern: Hauptkategorien → Untergruppen → Blatt-Ausgaben (beliebig tief)
  - Blatt-Nodes: Name, Betrag, Intervall (Monatlich/Jährlich), Typ (Fix/Variabel)
  - Gruppen-Nodes: Nur Name + Kinder (kein Betrag/Intervall/Typ)
  - Aggregation: Rekursive Berechnung der Monatstotals über alle Ebenen
  - Sortierung: `sortOrder`-Feld für benutzerdefinierte Reihenfolge (Lazy Migration: Default 99999)
- **Budget Health:** Automatische Berechnung von Einkommen vs. Ausgaben → Überschuss/Defizit

### 3. Dashboard & Übersicht
- **Aktueller Monat:** Circular Indicator mit verbleibendem Budget (CHF), Ampel-Farbsystem (Teal/Orange/Rot)
- **Monatshistorie:** Vergangene Monate als lineare Fortschrittsbalken mit Prozentanzeige
- **Smart Calculation:** Nur variable Ausgaben werden getrackt – Fixkosten werden automatisch vom Budget abgezogen
- **Quick Actions:** FAB für Transaktionserfassung, Jahresansicht-Button in AppBar

### 4. Transaktionserfassung
- **Felder:** Betrag (CHF, großes 42pt Eingabefeld), Kategorie (Autocomplete aus variablen Nodes), Datum/Uhrzeit, optionale Notiz
- **Modus:** Erstellen + Bearbeiten + Löschen mit Bestätigungsdialog
- **Kategorieauswahl:** `RawAutocomplete`-Widget filtert nur variable Blatt-Nodes
- **Tagesgruppierung:** Transaktionen werden per `TransactionGrouper` nach Kalendertag gruppiert, mit Tagessummen
- **Smart Scroll:** `ScrollablePositionedList` mit automatischer Monatserkennung beim Scrollen

### 5. Monatliche Detail-Analyse
- **Ist-Soll-Vergleich:** Rekursiver Baum (`BudgetVsActualNode`) vergleicht geplante vs. tatsächliche Ausgaben
- **Nur variable Kosten:** Fixkosten werden komplett ausgeschlossen
- **Pruning:** Nodes ohne geplanten Betrag UND ohne Transaktionen werden ausgeblendet
- **Aufklappbar:** Gruppen können erweitert werden, um Kinder-Nodes zu sehen
- **Drill-Down:** Jede Kategorie verlinkt zur `CategoryTransactionsScreen` mit allen zugehörigen Transaktionen

### 6. Jahresansicht
- **Jährliche Budget-Analyse:** `YearlyBudgetNode`-Baum mit geplantem vs. tatsächlichem Jahresverbrauch
- **Mid-Year-Adoption Offset:** `YearlyCalculator.calculateOffsetFactor()` berechnet anteilige Nutzung vor App-Start
- **Toggle:** Benutzer kann Offset ein-/ausblenden
- **Gestapelter Fortschrittsbalken:** Offset (blau) + tatsächliche Ausgaben (teal)
- **Jahresnavigation:** Pfeil-Buttons zum Wechseln zwischen Jahren
- **Drill-Down:** Kategorien verlinken zur `CategoryTransactionsScreen` im Jahreskontext

### 7. Kategorie-Transaktionsansicht
- **Parametrisiert:** `nodeIds`, `year`, optionaler `month` (für monatlichen oder jährlichen Kontext)
- **Detailliste:** Datum, Notiz, Kategoriename, Betrag pro Transaktion
- **Footer:** Anzahl Transaktionen + Gesamtsumme

## Implementierte Nicht-Funktionale Anforderungen

### Technologie
- **Flutter** (SDK ^3.10.7, Dart)
- **Clean Architecture:** Domain → Data → Presentation Layer-Trennung
- **Cloud Firestore:** Echtzeit-synchronisierte Daten per Streams (kein lokales Drift/SQLite mehr)
- **State Management:** Riverpod 3.x mit Code Generation (`@riverpod`, `Notifier`, `AsyncNotifier`)
- **Immutable Models:** Freezed 3.x für alle Domain Models
- **Authentifizierung:** Firebase Auth (Google Sign-In + Anonym)
- **Lokalisierung:** Deutsch (de-CH) als einzige Sprache, `intl` für Datumsformate

### Architektur-Prinzipien
- **Repository Pattern:** Abstrakte Interfaces in `domain/repositories/`, Implementierungen in `data/repositories/`
- **Reaktive Streams:** Alle Daten werden über `Stream<List<T>>` geladen – keine manuelle Invalidierung nötig
- **Stateless Services:** Business Logic in zustandslosen Service-Klassen (`BudgetCalculator`, `TreeBuilder`, `TransactionGrouper`, `YearlyCalculator`)
- **Strikte Schichtentrennung:** Presentation kennt nur Domain-Interfaces, nie direkte Firestore-Aufrufe

### CI/CD
- **GitHub Actions:** Automatisierte Pipeline mit Unit Tests → APK Build → GitHub Release + AAB → Google Play Upload
- **Trigger:** Push auf `main` + Tags `v*`
