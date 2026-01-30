# Stutz 💸
[![Android Release](https://img.shields.io/github/v/release/PhilippSchmid98/stutz?style=flat-square&logo=android&label=Latest%20APK&color=3DDC84)](https://github.com/PhilippSchmid98/stutz/releases/latest/download/app-release.apk)

### Dein Geld. Dein Vibe. Dein Stutz.

**Stutz** ist ein moderner, minimalistischer Finanz-Tracker für iOS und Android, entwickelt mit Flutter.
Der Fokus der App liegt nicht auf reiner Buchhaltung, sondern auf **finanzieller Klarheit**: Wie viel Geld ist *wirklich* noch verfügbar, nachdem alle Fixkosten gedeckt sind?

Stutz ersetzt komplexe Excel-Tabellen durch ein intuitives "Karten-Design" und bietet tiefgehende Einblicke in monatliche Budgets durch eine smarte Drill-Down-Analyse.

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

### 📊 Das Dashboard
Der zentrale Hub. Auf einen Blick siehst du nicht nur, was du ausgegeben hast, sondern **was noch übrig ist**.
* **Visualisierung:** Circular Indicators zeigen sofort, ob du im grünen Bereich bist.
* **Historie:** Vergleiche deine Performance mit den letzten 6 Monaten durch interaktive Balkendiagramme.
* **Smart Calculation:** Automatische Trennung von Fixkosten und variablem Budget.

### 💰 Budget Planung
Weg vom Tabellen-Chaos, hin zu strukturierten Karten.
* **Hierarchische Kategorien:** Erstelle Hauptkategorien und verschachtelte Untergruppen (beliebig tief).
* **Fix vs. Variabel:** Markiere Ausgaben als Fixkosten (Miete, Netflix) oder Variabel (Essen, Ausgang).
* **Intervalle:** Die App rechnet automatisch jährliche Zahlungen (z.B. KFZ-Steuer) auf den monatlichen Durchschnitt herunter.

### ⚡ Transaktionen
* **Schnellerfassung:** Füge neue Ausgaben in Sekunden hinzu – mit Datum, Kategorie und Notiz.
* **Endlos-Liste:** Scrolle durch deine Historie, sauber gruppiert nach Tagen.
* **Monats-Sprung:** Navigiere blitzschnell zu vergangenen Monaten über die horizontale Leiste.

### 🔍 Detail-Analyse (Drill-Down)
Klicke auf einen Monat, um zu sehen, wo das Geld wirklich hinfließt.
* **Rekursiver Baum:** Die App aggregiert Ausgaben von den kleinsten Unterkategorien hoch zu den Hauptgruppen.
* **Ist-Soll-Vergleich:** Balkendiagramme zeigen pro Kategorie, wie viel vom geplanten Budget verbraucht wurde.

---

## 📱 Screenshots

| Dashboard | Transaktionen | Planung | Erfassung |
|:---:|:---:|:---:|:---:|
| <img src="assets/dashboard.png" width="200"> | <img src="assets/transactions.png" width="200"> | <img src="assets/planning.png" width="200"> | <img src="assets/add_transaction.png" width="200"> |

*(Hinweis: Lege deine Screenshots in einen Ordner `assets/` im Hauptverzeichnis und benenne sie entsprechend, damit sie hier angezeigt werden.)*

---

## 🛠 Tech Stack

Die App wurde mit einem Fokus auf **Skalierbarkeit** und **Clean Architecture** entwickelt.

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** [Riverpod 2.x](https://riverpod.dev/) (mit Code Generation `@riverpod`)
* **UI Komponenten:**
    * `percent_indicator`: Für die visuellen Budget-Fortschritte.
    * `scrollable_positioned_list`: Für die präzise Navigation in der Transaktionshistorie.
    * `intl`: Für Datumsformatierung und Lokalisierung (De-CH).
* **Architektur:** Feature-First / Repository Pattern. Trennung von `Domain` (Models), `Data` (Repositories) und `Presentation` (Screens & Providers).

### Highlight: Rekursive Budget-Berechnung 🧮
Eine der technischen Herausforderungen war die Berechnung der Budgets über verschachtelte Gruppen hinweg.
Der `monthlyDetailTreeProvider` nutzt einen rekursiven Algorithmus, um:
1.  Den Kategorien-Baum zu durchlaufen.
2.  Ausgaben (Transactions) den korrekten Blättern zuzuordnen.
3.  Die Summen (Actual vs. Planned) von unten nach oben ("Bubbling up") zu den Hauptkategorien zu aggregieren.
4.  Dabei intelligent zwischen "Fix" und "Variabel" zu filtern, je nach gewählter Ansicht.

---

## 🚀 Getting Started

**Voraussetzungen:**
* Flutter SDK installiert.
* Ein Google/Firebase Account


1.  **Repository klonen:**
    ```bash
    git clone [https://github.com/PhilippSchmid98/stutz.git](https://github.com/PhilippSchmid98/stutz.git)
    cd stutz
    ```

2.  **Abhängigkeiten installieren:**
    ```bash
    flutter pub get
    ```

3. **⚙️ Konfiguration (Wichtig!)**

    Da diese App **Firebase** nutzt, benötigst du für die lokale Entwicklung deine eigene Konfigurationsdatei. Die sensiblen Daten sind aus Sicherheitsgründen nicht im Repository enthalten.

    **1. Firebase Setup:**
    1.  Erstelle ein neues Projekt in der [Firebase Console](https://console.firebase.google.com/).
    2.  Füge eine **Android-App** hinzu (Package Name: `ch.stutz.app` – oder passe ihn in `android/app/build.gradle` an).
    3.  Aktiviere im Firebase Dashboard folgende Dienste:
        * **Authentication** (Google Sign-In & Anonym).
        * **Firestore Database** (Erstelle eine Datenbank im Test-Modus).
    4.  Lade die `google-services.json` herunter.
    5.  Platziere die Datei in: `android/app/google-services.json`.

    **2. (Optional) Release Signing:**
    Für `flutter run` (Debug Mode) ist dies nicht nötig. Wenn du jedoch eine **Release APK** bauen möchtest (`flutter build apk --release`), benötigst du einen Keystore.
    1.  Erstelle eine Datei `android/key.properties` (siehe `android/key.properties.example` falls vorhanden, sonst Struktur wie folgt):
        ```properties
        storePassword=DEIN_PASSWORT
        keyPassword=DEIN_PASSWORT
        keyAlias=upload
        storeFile=upload-keystore.jks
        ```
    2.  Lege deinen Keystore unter `android/app/upload-keystore.jks` ab.

4.  **Code Generierung (Riverpod & Freezed/JsonSerializable):**
    Da wir Riverpod Generator nutzen, muss der Build Runner ausgeführt werden, um die Provider zu generieren:
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
├── data/                  # Implementierung der Repositories, Datenbank
├── domain/                # Models (Transaction, ExpenseNode, Income)
├── presentation/
│   ├── providers/         # Riverpod Provider (Logik & State)
│   ├── screens/
│   │   ├── budget/        # Planungs-Screen & Dialoge
│   │   ├── dashboard/     # Dashboard & Widgets
│   │   ├── transactions/  # Liste & Erfassungs-Screen
│   │   └── detail/        # Monatliche Detailansicht
│   └── widgets/           # Wiederverwendbare UI-Komponenten
└── main.dart
```

---

## 🔮 Roadmap

* [ ] Daten-Export (CSV/PDF)
* [ ] Synchronisierung via Cloud
* [ ] Dark Mode Support
* [ ] Unterstützung für wiederkehrende Transaktionen (Recurring)

---

Erstellt mit ❤️ und Flutter.

<details>
<summary>🤖 CI/CD Pipeline Setup (für Forks)</summary>

Diese App nutzt GitHub Actions für automatisierte Releases. Wenn du das Repository forkst, musst du folgende **Repository Secrets** in GitHub hinterlegen, damit die Pipeline funktioniert:

* `ANDROID_KEYSTORE_BASE64`: Dein Base64-encodierter Keystore (.jks).
* `ANDROID_KEYSTORE_PASSWORD`: Passwort des Stores.
* `ANDROID_KEY_PASSWORD`: Passwort des Keys.
* `ANDROID_KEY_ALIAS`: Alias Name.
* `ANDROID_GOOGLE_SERVICES_JSON`: Base64-encodierte google-services.json.
* `ANDROID_SERVICE_ACCOUNT_JSON`: JSON Key für Google Play Console Upload.

</details>