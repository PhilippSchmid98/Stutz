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

### ☁️ Cloud & Offline
* **Firebase Cloud Firestore:** Echtzeit-Synchronisation aller Daten.
* **Offline-Erkennung:** Cloud-Status-Icon zeigt Verbindungsstatus in allen Screens.
* **Reactive Streams:** Alle Daten werden über Firestore-Streams geladen – Änderungen werden sofort reflektiert.

---

## 📱 Screenshots

Screenshots werden ergänzt, sobald die aktuelle UI-Version finalisiert ist.

---

## 🛠 Tech Stack

Die App wurde mit einem Fokus auf **Skalierbarkeit** und **Clean Architecture** entwickelt.

| Kategorie | Technologie | Details |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev/) | Dart, Material 3 |
| **State Management** | [Riverpod 3.x](https://riverpod.dev/) | `@riverpod` Code Generation, `Notifier`, `AsyncNotifier` |
| **Backend** | [Firebase](https://firebase.google.com/) | Cloud Firestore (Echtzeit-Streams), Firebase Auth (Google + Anonym) |
| **Code Generation** | Freezed 3.x, Riverpod Generator 3.x | Immutable Models, Provider-Generation |
| **UI Packages** | `scrollable_positioned_list`, `intl`, `google_fonts` | Transaktions-Scroll, Lokalisierung (de-CH), Typografie |
| **Architektur** | Clean Architecture / Repository Pattern | Domain → Data → Presentation Layer-Trennung |

### Highlight: Rekursive Budget-Berechnung 🧮
`BudgetCalculator` traversiert verschachtelte Kategorien und erzeugt eine zentrale
Budget-Zusammenfassung mit Einkommen, Ausgaben, Fixkosten, variablen Kosten und
monatlichem Saldo. Transaktionen werden nach Datum gruppiert und über einen
schreibgeschützten Kategorie-Lookup angereichert.

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

6.  **Tests ausführen:**
    ```bash
    flutter analyze
    flutter test
    npm install
    npm run test:rules
    ```

### Google Wallet notification inspection

The active Android notification drawer can be exported into a readable report
for notification-template development. Connect one Android device with USB
debugging enabled, then run this from the project root:

```powershell
adb devices
.\scripts\inspect-wallet-notifications.ps1
```

The report is written to `wallet-notifications.txt`. Use `-Serial <SERIAL>`
when more than one device is connected. Add `-IncludeRawDump` when the full
Android dump is needed for investigating new notification layouts. These files
can contain payment data and are ignored by Git. The command reads currently
active notifications only; it cannot recover notifications that Android has
already removed.

### Transaction month index migration

Existing transaction data can be indexed once with the Admin SDK. Store the
service-account JSON outside this repository and set its path in
`GOOGLE_APPLICATION_CREDENTIALS`. The migration writes derived
`transactionMonths` documents and uses `Europe/Zurich` for month boundaries.
Migration version 2 also stores `year`, `month`, and per-category totals in
each month document so the Dashboard can load a year of budget analytics
without reading every raw transaction. Rerun the migration after deploying this
version, including when version 1 month indexes already exist.

Deploy the declared Firestore index before opening a category drill-down in the
Dashboard:

```bash
firebase deploy --only firestore:indexes
```

#### Spark backup checkpoint

Spark does not provide the managed Firestore export/import service to Cloud
Storage. The repository therefore includes a local logical backup. It is an
NDJSON archive with a typed Firestore value codec, a SHA-256 checksum, and a
completion manifest. It is not the managed Firestore export format and cannot
be passed to `gcloud firestore import`.

The archive contains sensitive financial data. Keep it outside Git, store it
with appropriate encryption and access controls, and consider pausing writes
during backup and migration when an exact rollback point is required. Admin
SDK reads and writes still consume Firestore quotas, including Spark quotas.

The documented `transactions` scope is sufficient for the month-index
migration. Use `--scope=all` when a recursive logical archive of all reachable
documents and subcollections is required. Use `--max-documents=<N>` as a
read-quota guard for large backups.

Test the complete workflow against the emulator first:

```powershell
$env:FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080"
npm run backup:firestore -- --emulator --scope=transactions --output=backups/firestore-transactions-test
npm run restore:firestore -- --emulator --input=backups/firestore-transactions-test --dry-run
npm run migrate:transaction-months -- --emulator --dry-run
npm run migrate:transaction-months -- --emulator
```

For production, create and verify a transaction backup before allowing the
migration to write. The backup command does not start the migration
automatically:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\outside\stutz\stutz-service-account.json"
$backup = "backups/firestore-transactions-$(Get-Date -Format yyyy-MM-dd)"
npm run backup:firestore -- --project-id=stutz-7ed90 --scope=transactions --output=$backup
npm run migrate:transaction-months -- --project-id=stutz-7ed90 --dry-run --require-backup --backup-dir=$backup
npm run migrate:transaction-months -- --project-id=stutz-7ed90 --require-backup --backup-dir=$backup
```

`--require-backup` validates the complete manifest, project ID, transaction
scope, document count, and checksum before migration writes begin. The
migration is safe to repeat. It writes exact per-month counts and category
totals, removes stale month documents, and marks each completed user with the
`_meta` document.

To inspect or restore an archive, start with a dry run. Normal restore is an
idempotent upsert in batches of at most 500 documents. An interrupted restore
leaves a journal; rerun it with `--resume` to continue from the last committed
batch:

```powershell
npm run restore:firestore -- --project-id=stutz-7ed90 --input=$backup --dry-run
npm run restore:firestore -- --project-id=stutz-7ed90 --input=$backup --confirm
npm run restore:firestore -- --project-id=stutz-7ed90 --input=$backup --scope=transactions --user-id=<USER_ID> --delete-missing --confirm
```

`--delete-missing` is deliberately restricted to one user's transaction
scope. It can remove data and should only be used with a maintenance window
and an explicit `--confirm`. Production restores require `--confirm`; a
project mismatch is rejected unless `--allow-project-mismatch` is supplied
intentionally.

---

## 📂 Projektstruktur
```text
lib/
├── app/                         # Root router and home navigation
├── core/                        # Theme, connectivity, shared utilities
├── features/
│   ├── auth/                    # Firebase Auth and onboarding
│   ├── budget/                  # Budget domain, repositories, UI and mutations
│   └── transactions/            # Transaction domain, pagination, UI and mutations
├── shared/                      # Reusable widgets
├── firebase_options.dart
└── main.dart
```

---

## 🔮 Roadmap

* [ ] Dark Mode Support
* [ ] Daten-Export (CSV/PDF)
* [ ] Unterstützung für wiederkehrende Transaktionen (Recurring)
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