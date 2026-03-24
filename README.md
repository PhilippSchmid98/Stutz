# Stutz 💸
[![Android Release](https://img.shields.io/github/v/release/PhilippSchmid98/stutz?style=flat-square&logo=android&label=Latest%20APK&color=3DDC84)](https://github.com/PhilippSchmid98/stutz/releases/latest/download/app-release.apk)

### Dein Geld. Dein Vibe. Dein Stutz.

**Stutz** ist ein moderner, minimalistischer Finanz-Tracker für Android, entwickelt mit Flutter.
Der Fokus der App liegt nicht auf reiner Buchhaltung, sondern auf **finanzieller Klarheit**: Wie viel Geld ist *wirklich* noch verfügbar, nachdem alle Fixkosten gedeckt sind?

Stutz ersetzt komplexe Excel-Tabellen durch ein intuitives "Karten-Design" und bietet tiefgehende Einblicke in monatliche und jährliche Budgets durch eine smarte Drill-Down-Analyse.

---

## 📥 Download & Installation

Du möchtest die App sofort ausprobieren, ohne sie selbst zu bauen?
Lade dir hier die aktuellste Android-Version direkt herunter:

<a href="https://github.com/PhilippSchmid98/stutz/releases/latest/download/app-release.apk">
  <img src="https://img.shields.io/badge/Download_APK-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" height="45" />
</a>

> **⚠️ Wichtiger Hinweis zur Installation:**
> Da diese App (noch) nicht im Play Store ist, wird dein Android-Smartphone beim Installieren eine Warnung anzeigen ("Unbekannte Apps installieren").
> Das ist normal bei direktem APK-Download. Du musst in den Einstellungen einmalig **"Dieser Quelle vertrauen"** aktivieren, um Stutz zu installieren.

[Zu den Release Notes & Changelogs](https://github.com/PhilippSchmid98/stutz/releases)

---

## ✨ Features

### 🔐 Authentifizierung
Sichere Anmeldung für deine Finanzdaten.
* **Google Sign-In:** Melde dich mit deinem Google-Konto an – Daten werden sicher in der Cloud gespeichert.
* **Gast-Modus:** Starte ohne Account mit anonymer Firebase-Authentifizierung.
* **Onboarding:** Willkommens-Screen mit 3-seitiger Tutorial-Tour (Fix vs. Variabel, Intervalle, Cloud-Sync).

### 📊 Das Dashboard
Der zentrale Hub. Auf einen Blick siehst du nicht nur, was du ausgegeben hast, sondern **was noch übrig ist**.
* **Visualisierung:** Circular Indicators zeigen sofort, ob du im grünen Bereich bist (Grün < 85%, Orange 85–100%, Rot > 100%).
* **Historie:** Vergleiche deine Performance mit den vergangenen Monaten durch lineare Fortschrittsbalken.
* **Smart Calculation:** Automatische Trennung von Fixkosten und variablem Budget – nur variable Ausgaben werden getrackt.
* **Schnellzugriff:** FAB für sofortige Transaktionserfassung, Jahresansicht über AppBar-Icon.

### 💰 Budget Planung
Weg vom Tabellen-Chaos, hin zu strukturierten Karten.
* **Hierarchische Kategorien:** Erstelle Hauptkategorien und verschachtelte Untergruppen (beliebig tief) als Baumstruktur.
* **Fix vs. Variabel:** Markiere Ausgaben als Fixkosten (Miete, Netflix) oder Variabel (Essen, Ausgang).
* **Intervalle:** Die App rechnet automatisch jährliche Zahlungen (z.B. KFZ-Steuer) auf den monatlichen Durchschnitt herunter.
* **Einnahmen-Verwaltung:** Pflege Haupt- und Nebeneinnahmen mit monatlichen/jährlichen Intervallen.
* **Budget-Übersicht:** Live-Anzeige von Überschuss/Defizit, getrennt nach Fix- und Variabel-Kosten.
* **Sortierbare Kategorien:** Ändere die Reihenfolge deiner Ausgabenkategorien per Drag & Sort.

### ⚡ Transaktionen
* **Schnellerfassung:** Füge neue Ausgaben in Sekunden hinzu – mit Betrag (CHF), Datum/Uhrzeit, Kategorie (Autocomplete) und optionaler Notiz.
* **Endlos-Liste:** Scrolle durch deine gesamte Historie, sauber gruppiert nach Tagen mit Tagessummen.
* **Monats-Sprung:** Navigiere blitzschnell zu vergangenen Monaten über die horizontale Monats-Leiste mit Smart-Scroll-Erkennung.
* **Bearbeiten & Löschen:** Tippe auf eine Transaktion zum Bearbeiten oder Löschen.

### 🔍 Monatliche Detail-Analyse (Drill-Down)
Klicke auf einen Monat im Dashboard, um zu sehen, wo das Geld wirklich hinfließt.
* **Rekursiver Baum:** Die App aggregiert Ausgaben von den kleinsten Unterkategorien hoch zu den Hauptgruppen.
* **Ist-Soll-Vergleich:** Fortschrittsbalken zeigen pro Kategorie, wie viel vom geplanten Budget verbraucht wurde.
* **Aufklappbare Gruppen:** Erweitere Kategorien, um Unterkategorien mit eigenen Fortschrittsanzeigen zu sehen.
* **Transaktions-Drill-Down:** Tippe auf eine Kategorie, um alle zugehörigen Transaktionen des Monats zu sehen.

### 📅 Jahresansicht
Jahresübergreifende Analyse deiner variablen Ausgaben.
* **Jahresnavigation:** Wechsle per Pfeil zwischen Jahren.
* **Offset-Berechnung:** Berücksichtigt den Zeitpunkt, ab dem du die App nutzt (Mid-Year-Adoption).
* **Gestapelte Fortschrittsbalken:** Zeigen Offset (blau) + tatsächliche Ausgaben (teal) an.
* **Jahresfortschritt:** Wie viel % des Jahres bereits vergangen sind.

### ☁️ Cloud & Offline
* **Firebase Cloud Firestore:** Echtzeit-Synchronisation aller Daten.
* **Offline-Erkennung:** Cloud-Status-Icon zeigt Verbindungsstatus in allen Screens.
* **Reactive Streams:** Alle Daten werden über Firestore-Streams geladen – Änderungen werden sofort reflektiert.

---

## 📱 Screenshots

| Dashboard | Transaktionen | Planung | Erfassung |
|:---:|:---:|:---:|:---:|
| <img src="assets/dashboard.png" width="200"> | <img src="assets/transactions.png" width="200"> | <img src="assets/planning.png" width="200"> | <img src="assets/add_transaction.png" width="200"> |

*(Hinweis: Lege deine Screenshots in einen Ordner `assets/` im Hauptverzeichnis und benenne sie entsprechend, damit sie hier angezeigt werden.)*

---

## 🛠 Tech Stack

Die App wurde mit einem Fokus auf **Skalierbarkeit** und **Clean Architecture** entwickelt.

| Kategorie | Technologie | Details |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev/) | Dart, Material 3 |
| **State Management** | [Riverpod 3.x](https://riverpod.dev/) | `@riverpod` Code Generation, `Notifier`, `AsyncNotifier` |
| **Backend** | [Firebase](https://firebase.google.com/) | Cloud Firestore (Echtzeit-Streams), Firebase Auth (Google + Anonym) |
| **Code Generation** | Freezed 3.x, Riverpod Generator 3.x | Immutable Models, Provider-Generation |
| **UI Packages** | `percent_indicator`, `scrollable_positioned_list`, `intl` | Budget-Kreise, Transaktions-Scroll, Lokalisierung (de-CH) |
| **Architektur** | Clean Architecture / Repository Pattern | Domain → Data → Presentation Layer-Trennung |

### Highlight: Rekursive Budget-Berechnung 🧮
Eine der technischen Herausforderungen war die Berechnung der Budgets über verschachtelte Gruppen hinweg.
Die Domain-Services (`BudgetCalculator`, `YearlyCalculator`) nutzen rekursive Algorithmen, um:
1.  Den Kategorien-Baum zu durchlaufen.
2.  Ausgaben (Transactions) den korrekten Blättern zuzuordnen.
3.  Die Summen (Actual vs. Planned) von unten nach oben ("Bubbling up") zu den Hauptkategorien zu aggregieren.
4.  Dabei intelligent zwischen "Fix" und "Variabel" zu filtern – nur variable Kosten werden analysiert.
5.  Für die Jahresansicht einen Offset-Faktor für Mid-Year-Adoption zu berechnen.

---

## 🚀 Getting Started

**Voraussetzungen:**
* Flutter SDK (^3.10.7) installiert.
* Ein Google/Firebase Account.

1.  **Repository klonen:**
    ```bash
    git clone https://github.com/PhilippSchmid98/stutz.git
    cd stutz
    ```

2.  **Abhängigkeiten installieren:**
    ```bash
    flutter pub get
    ```

3.  **⚙️ Konfiguration (Wichtig!)**

    Da diese App **Firebase** nutzt, benötigst du für die lokale Entwicklung deine eigene Konfigurationsdatei.

    **1. Firebase Setup:**
    1.  Erstelle ein neues Projekt in der [Firebase Console](https://console.firebase.google.com/).
    2.  Füge eine **Android-App** hinzu (Package Name: `ch.stutz.app`).
    3.  Aktiviere im Firebase Dashboard:
        * **Authentication:** Aktiviere "Google" und "Anonym".
        * **Firestore Database:** Erstelle eine Datenbank (starte im Test-Modus).

    **2. WICHTIG: SHA-1 Fingerabdruck (für Google Login):**
    Damit der Login im Debug-Modus funktioniert, musst du deinen lokalen Fingerabdruck registrieren **bevor** du die Config herunterlädst.
    * **Mac/Linux:**
      ```bash
      cd android && ./gradlew signingReport
      ```
    * **Windows:**
      ```bash
      cd android && gradlew signingReport
      ```
    Suche in der Ausgabe nach dem Eintrag **Variant: debug**, kopiere den **SHA1**-Schlüssel und füge ihn in den [Firebase Projekteinstellungen](https://console.firebase.google.com/project/_/settings/general/) unter "Apps" → "Fingerabdruck hinzufügen" ein.

    **3. Config Datei integrieren:**
    1.  Lade **jetzt** (nachdem der SHA-1 drin ist) die `google-services.json` herunter.
    2.  Verschiebe die Datei nach: `android/app/google-services.json`.

    **4. (Optional) Release Signing:**
    Für `flutter run` (Debug Mode) ist dies nicht nötig. Wenn du jedoch eine **Release APK** bauen möchtest (`flutter build apk --release`), benötigst du einen Keystore.
    1.  Erstelle eine Datei `android/key.properties`:
        ```properties
        storePassword=DEIN_PASSWORT
        keyPassword=DEIN_PASSWORT
        keyAlias=upload
        storeFile=upload-keystore.jks
        ```
    2.  Lege deinen Keystore unter `android/app/upload-keystore.jks` ab.

4.  **Code Generierung (Riverpod & Freezed):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

5.  **App starten:**
    ```bash
    flutter run
    ```

---

## 📂 Projektstruktur
```text
lib/
├── core/
│   ├── constants/           # Firebase Config (OAuth Client IDs)
│   └── enums/               # PaymentInterval, ExpenseType, IncomeGroup
├── data/
│   ├── auth_service.dart    # Firebase Auth + Google Sign-In
│   ├── mappers/             # Firestore ↔ Domain Model Mapper
│   └── repositories/        # Firestore Repository Implementierungen
├── domain/
│   ├── logic_extensions.dart # Extensions auf IncomeSource & ExpenseNode
│   ├── models/              # Freezed Domain Models
│   ├── repositories/        # Abstrakte Repository Interfaces
│   └── services/            # Stateless Business Logic (Calculator, Grouper, TreeBuilder)
├── presentation/
│   ├── app_router.dart      # Auth-basiertes Routing (Splash → Welcome → Login → Home)
│   ├── providers/           # Riverpod 3 Provider (Generated, Streams, AsyncNotifiers)
│   └── screens/
│       ├── budget/          # Budget-Planung (Einnahmen, Ausgaben, Dialoge)
│       ├── dashboard/       # Dashboard mit Monatsübersicht
│       ├── onboarding/      # Welcome, Tutorial, Login Screens
│       ├── shared/          # Wiederverwendbare Widgets (SectionCard, StyledTextField, etc.)
│       ├── transactions/    # Transaktionsliste & Erfassungs-Dialog
│       └── widgets/         # Cloud-Status-Icon
├── firebase_options.dart
└── main.dart
```

---

## 🔮 Roadmap

* [ ] Dark Mode Support
* [ ] Daten-Export (CSV/PDF)
* [ ] Unterstützung für wiederkehrende Transaktionen (Recurring)
* [ ] Showcaseview-Integration für In-App-Tutorials
* [ ] iOS Release

---

Erstellt mit ❤️ und Flutter.

<details>
<summary>🤖 CI/CD Pipeline Setup (für Forks)</summary>

Diese App nutzt **GitHub Actions** für automatisierte Releases. Die Pipeline (`deploy_android.yml`) führt folgende Schritte aus:

1. **Unit Tests** auf jedem Push/PR
2. **APK Build** (parallel) → GitHub Release
3. **AAB Build** (parallel) → Google Play Store Upload (Internal Track)

Wenn du das Repository forkst, musst du folgende **Repository Secrets** in GitHub hinterlegen:

* `ANDROID_KEYSTORE_BASE64`: Dein Base64-encodierter Keystore (.jks).
* `ANDROID_KEYSTORE_PASSWORD`: Passwort des Stores.
* `ANDROID_KEY_PASSWORD`: Passwort des Keys.
* `ANDROID_KEY_ALIAS`: Alias Name.
* `ANDROID_GOOGLE_SERVICES_JSON`: Base64-encodierte google-services.json.
* `ANDROID_SERVICE_ACCOUNT_JSON`: JSON Key für Google Play Console Upload.

Releases werden automatisch bei Tags im Format `v*` erstellt.

</details>