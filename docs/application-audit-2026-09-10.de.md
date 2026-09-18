# Stutz Application Audit

Zuletzt geprüft: 2026-09-10

Implementierungsstatus aktualisiert: 2026-09-18

## 1. Zweck und Umfang

Dieses Dokument ist ein detailliertes technisches Audit der aktuellen Stutz-Codebase. Es
behandelt die Anwendung als Android-fokussierte Flutter-Finanzanwendung, nicht als
bloßen Prototyp.

Der Review deckt ab:

1. Architektur und State Management.
2. Android-Plattformcode und Notification Capture.
3. Firebase-Integration und der Data Layer.
4. Performance, UI/UX und Android-Accessibility.
5. Automatisierte Test Coverage und Testqualität.
6. CI/CD und Release-Engineering.

Die Befunde stützen sich auf die aktuelle Implementierung unter `lib/`,
`android/app/src/main/`, `test/`, `android/app/src/test/`, Firebase-Regeln und
-Indizes, Paketmanifeste und GitHub-Actions-Workflows. Generierte Dart-Dateien
gelten als Implementierungsartefakte, nicht als primäre Designquelle.

Dies ist eine Momentaufnahme. Zeilenverweise können mit Codeänderungen wandern.

### 1.1 Severity-Level

| Symbol | Bedeutung |
| --- | --- |
| 🔥 Kritisch | Ein produktionsblockierendes Risiko für finanzielle Korrektheit, Datenschutz, Sicherheit oder Account Recovery. |
| ⚠️ Warnung | Ein relevanter Mangel bei Reliability, Performance, Wartbarkeit oder UX, der eingeplant werden sollte. |
| ✅ Gute Praxis | Eine Design- oder Implementierungsentscheidung, die erhalten bleiben sollte. |

### 1.2 Review-Prinzipien

Der Review setzt einen strengeren Maßstab an als bei einer gewöhnlichen Consumer-CRUD-App,
weil Stutz Finanzdaten und daraus abgeleitete Budgetsummen speichert. In diesem
Bereich gilt:

- Persistiertes Geld braucht deterministische Arithmetik;
- Transaktionen anzulegen muss retry-safe sein;
- abgeleitete Aggregate müssen sich aus den Quelldaten rekonstruieren lassen;
- Kontoübergänge dürfen Daten weder verwaisen lassen noch falsch zuordnen;
- fehlerhafte Datensätze dürfen nicht das gesamte Ledger unlesbar machen;
- sensible lokale Daten brauchen eine explizite Backup-, Encryption- und
  Retention Policy;
- Tests müssen sich auf Mutation Boundaries konzentrieren, nicht nur auf
  Darstellung und reine Berechnungen.

## 2. Executive Summary

**Gesamtscore: 61/100.**

Stutz ist ein starker, ungewöhnlich sauber strukturierter Prototyp. Die Feature-first-
Organisation ist stimmig, Riverpod wird im Allgemeinen korrekt eingesetzt, die
zentralen Budgetberechnungen sind als Pure Functions umgesetzt, Firestore-Reads sind größtenteils sauber
eingegrenzt, der Transaktionsverlauf ist paginiert, und die Test Suite
deckt substanzielles Verhalten ab. Die App ist keine Ansammlung von
God-Widgets oder Ad-hoc-Firebase-Aufrufen.

Finance-Grade ist sie aber noch nicht. Die zentralen Blocker:

1. Geld wird als IEEE-754-`double` persistiert und aggregiert.
2. Firestore-Regeln prüfen nur Ownership, nicht Ledger-Schemata oder zulässige
   State-Übergänge.
3. Das manuelle Anlegen von Transaktionen ist nicht idempotent und kann bei
  einem Replay derselben Transaktions-ID die Monatssumme doppelt erhöhen.
4. Anonyme Benutzer können sich abmelden und dabei dauerhaft den Zugriff auf ihr
   Ledger verlieren.
5. Bei erfassten Notification-Daten bestehen noch Klartext- und
  Retention-Risiken. Owner-Lifecycle, Debug-Logging und Android-Backup wurden
  am 16.09.2026 nachträglich adressiert.

Es wurde kein bestätigtes Firestore-Datenleck über Benutzergrenzen hinweg
gefunden. Jede aktuelle Wildcard-Regel prüft weiterhin, dass die authentifizierte UID
mit dem Benutzerpfad übereinstimmt. Das eigentliche Problem ist die Integrität
innerhalb des eigenen Namensraums eines Benutzers: Ein fehlerhafter, veralteter
oder modifizierter Client kann Daten schreiben, die der Rest der App nicht sicher
verarbeiten kann.

### 2.1 Phasen-Scorecard

| Phase | Score | Einschätzung |
| --- | ---: | --- |
| 1. Architektur und State Management | 78/100 | Starke Struktur mit ein paar unvollständigen Refactorings und verborgenen Hintergrundfehlern. |
| 2. Android und Notifications | 48/100 | Guter Parser und gutes Event-Modell, aber ernsthafte Lücken beim Owner-Lifecycle und beim Schutz lokaler Daten. |
| 3. Firebase und Data Layer | 38/100 | Produktionsblockierende Risiken bei Geld, Regeln, Idempotenz und Account Recovery. |
| 4. Performance und UI/UX | 67/100 | Gute Basis-Ergonomie, aber unbegrenztes Detail-Rendering und mehrere Interaktions-/Accessibility-Mängel. |
| 5. Tests | 62/100 | Aussagekräftige Suite, aber die riskantesten Repositories und die native Boundary sind praktisch ungetestet. |
| 6. CI/CD | 70/100 | Solides Flutter-Gate und Android-Builds, aber unvollständige Test-Gates, schwaches Caching und nicht gepinnte Tool-Versionen. |

### 2.2 Korrekturen zum älteren Refactoring-Audit

Die Implementierung ist seit
[refactoring-audit.md](refactoring-audit.md) weitergekommen. Zwei ältere
Schlussfolgerungen sollten nicht mehr als aktuelle Mängel wiederholt werden:

- Die Notification-Sync ist nicht mehr nur ein beobachteter, schreibender
  Provider. `_AuthenticatedHome` löst die Synchronisierung jetzt beim Start,
  beim App-Resume und bei nativen Capture-Events aus, und
  `NotificationDraftSynchronizer` serialisiert überlappende Anfragen.
- Die Bestätigung importierter Drafts ist auf Draft-Ebene idempotent. Ein
  bereits als `saved` markierter Draft liefert seine bestehende
  Transaktions-ID zurück, bevor Monatssummen geändert werden.

Der veraltete generierte Sync-Provider wurde am 16.09.2026 entfernt. Der Pfad
zur manuellen Transaktionserstellung bleibt nicht idempotent.

### 2.3 Refactoring-Update (18.09.2026)

Der KISS/YAGNI-Refactoring-Plan wurde vollständig umgesetzt und automatisiert
validiert. Entfernt wurden ungenutzte Widgets, Repository-Reads, Provider,
einmalige Konfigurationshüllen, der In-Memory-Händlerregel-Zweig,
`DraftSyncService`, `TransactionDraftStore`, `CategoryLookup` und alte
Pagination-Aliase. Die verbleibende Plattformabstraktion
`NotificationCaptureGateway`, Firestore-Mapper, Freezed-Modelle und die
gerichtete Pagination bleiben erhalten, weil sie reale Grenzen oder fachliche
Anforderungen abbilden.

Die Abschlussprüfung bestand aus `flutter analyze`, 132 Flutter-Tests, Rules-,
Backup- und Migrationssuite sowie wiederholbarer Codegenerierung. Manuelle
Smoke-Tests waren mangels verfügbarer Flutter-Geräte nicht möglich;
`android\gradlew.bat testDebugUnitTest` blieb durch die lokale
Cross-Drive-Gradle-Konfiguration blockiert.

## 3. Validation Baseline

Die folgenden Checks liefen gegen den geprüften Workspace:

| Check | Ergebnis |
| --- | --- |
| `flutter analyze` | Bestanden, keine Diagnosen. |
| Flutter-Tests | 140 bestanden, 0 fehlgeschlagen. |
| `npm run test:rules` | Bestanden. |
| `npm run test:backup` | 7 bestanden, 0 fehlgeschlagen. |
| `npm run test:migration` | 5 bestanden, 0 fehlgeschlagen. |
| Flutter Line Coverage (gesamt) | 2.407 / 3.925 Zeilen, bzw. 61,32 %. |
| Android `testDebugUnitTest` | Liess sich lokal nicht konfigurieren, weil die Plugin-Build-Ausgabe auf `E:` lag, während der Pub-Cache auf `C:` lag. Die Tests liefen nicht; das ist kein fehlgeschlagener Parser-Test. |

### Implementierungsupdate: Prioritaet 1 (16.09.2026)

Die folgenden Auditbefunde wurden nach dem urspruenglichen Review umgesetzt
und lokal validiert:

- Native Ownership wird vor dem Sign-out und bei Auth-State `null` bereinigt;
  die zugehoerige Queue des aktiven Owners wird geloescht.
- Ein abgebrochener Synchronizer setzt, liest, schreibt oder quittiert nach
  einem Owner-Wechsel keine alten Daten mehr.
- Rohes Google-Wallet-Notification-Logging wurde entfernt.
- Android-Backups sind deaktiviert; zusaetzliche Backup- und
  Data-Extraction-Regeln schliessen Queue und Owner-Preferences aus.
- Queue-Schema v3 verwendet nur `UNIQUE(owner_id, source_dedupe_key)`;
  der Upgrade-Pfad von v2 ist getestet.

`flutter analyze`, die fokussierte Dart-Synchronisationssuite (4 Tests) und
`NotificationCaptureQueueTest` bestanden. Eine Android-Backup-Inspektion und
ein dokumentierter Debug-Log-Review stehen noch aus. Verschluesselung sowie
Retention quittierter Queue-Zeilen bleiben offene Folgearbeiten.

Coverage wird in Phase 5 im Detail besprochen. Der generierte Coverage-Report
wurde nach der Messung entfernt.

---

## 4. Phase 1: Architektur und State Management

### 4.1 ✅ Feature-first-Grenzen sind stimmig

Die Hauptfeatures besitzen ihren eigenen Application-, Data-, Domain- und
Presentation-Code. Budget-Reads werden zum Beispiel in
[budget_providers.dart](../lib/features/budget/application/budget_providers.dart#L14-L66)
zusammengesetzt, während die Persistenz in Feature-Repositories und die
Berechnungen in reinen Domain-Services bleiben.

Der Dependency-Flow ist grundsätzlich gesund:

```text
presentation -> application providers/controllers -> repositories/services
                                              \-> domain value objects
```

Die Feature-übergreifende Transaktionsanreicherung nutzt die gemeinsame flache
`ExpenseNode`-Sicht. Das Transaction-Feature hängt damit vom Budget-Domain-
Modell, nicht vom Budget-Repository oder dessen Firestore-Details ab.

**Warum das gut ist**

- Firestore-Belange sickern nicht in die meisten Widgets durch.
- Rechner und Grouping-Services lassen sich ohne Firebase testen.
- Riverpod-Provider-Overrides machen Tests der Application-Schicht unkompliziert.
- Die Feature-Zuständigkeit ist nachvollziehbar, ohne ein großes
  Dependency-Injection-Framework zu brauchen.

**Empfehlung:** Diese Struktur beibehalten. Nicht überall Repository-Interfaces
einführen, nur um architektonische Symmetrie zu erzeugen. Ein Interface nur dort
ergänzen, wo es eine echte alternative Implementierung, eine Emulator-Boundary
oder einen echten Testnutzen gibt.

### 4.2 ✅ Riverpod wird größtenteils richtig eingesetzt

Reaktive Dependencies verwenden durchweg `ref.watch`, während Callbacks
und Commands `ref.read` verwenden. Auth-Routing-Provider werden bewusst
keep-alive gehalten, weil sie die gesamte App-Lifetime steuern.
Feature-Streams sind standardmäßig auto-disposed.

Das Dashboard komponiert unabhängige asynchrone Kategorie- und Summendaten in
[dashboard_providers.dart](../lib/features/dashboard/application/dashboard_providers.dart#L29-L58),
und Budget-Streams propagieren Firestore-Änderungen automatisch, ohne
manuelle Invalidierung.

Ein größeres Stream-Subscription-Leck wurde nicht gefunden:

- das native Capture-Stream-Abonnement wird gecancelt;
- das manuelle Abonnement des Pending-Drafts-Providers wird geschlossen;
- der Widget-Binding-Observer wird entfernt;
- der Transaction-Screen entfernt seinen `ItemPositionsListener`-Callback im
  Hook-Cleanup.

Siehe [app_router.dart](../lib/app/app_router.dart#L118-L123) und
[transaction_screen.dart](../lib/features/transactions/presentation/transaction_screen.dart#L92-L151).

### 4.3 ✅ Die Notification-Sync ist serialisiert

`NotificationDraftSynchronizer` hält genau eine aktive Synchronisierung und
merkt sich, ob während des laufenden Durchlaufs ein weiterer angefordert wurde:

```dart
Future<void> synchronize(String userId) {
  final activeSynchronization = _activeSynchronization;
  if (activeSynchronization != null) {
    _synchronizationRequested = true;
    return activeSynchronization;
  }

  final synchronization = _drain(userId);
  _activeSynchronization = synchronization;
  // ...
}
```

Quelle:
[notification_draft_sync.dart](../lib/features/notification_import/application/notification_draft_sync.dart#L18-L51).

Das verhindert, dass Start, Resume und native Capture-Events überlappende
Queue-Uploads ausführen. Die Drain-Loop stellt zudem sicher, dass ein
Event, das während einer laufenden Sync eintrifft, einen weiteren Durchlauf
auslöst, statt verloren zu gehen.

**Empfehlung:** Dieses Serialisierungsverhalten beibehalten, wenn der in Phase 2
beschriebene Owner-Lifecycle-Fix umgesetzt wird.

### 4.4 ✅ Veralteter Sync-Provider ist entfernt

Der nicht verwendete schreibende Sync-Provider wurde entfernt.
`_AuthenticatedHome` besitzt den `NotificationDraftSynchronizer`, der Start,
Resume und native Capture-Events koordiniert. Der Synchronizer enthält den
linearen Ablauf direkt und erhält ausschließlich den Callback
`upsertCapturedDraft`; dadurch bestehen weder ein zweiter Provider-Owner noch
eine direkte Firebase-Abhängigkeit in der Application-Schicht.

Die Synchronisationssuite deckt Upload-vor-Acknowledge, Upload-Fehler,
Koaleszenz und den abgebrochenen Owner-Wechsel ab. Die separate offene Frage
zur Sichtbarkeit von Hintergrund-Sync-Fehlern bleibt in Abschnitt 4.5 bestehen.

### 4.5 ⚠️ Hintergrund-Sync-Fehler werden absichtlich verschluckt

Der Listener für Capture-Events hat einen leeren Fehler-Callback, und die
Hintergrund-Sync wandelt jeden Fehler in ein ignoriertes Future um:

```dart
_captureEventsSubscription = gateway.draftCapturedEvents.listen(
  (_) => _synchronizeInBackground(),
  onError: (_, __) {},
);

// Later:
_synchronizer.synchronize(userId).catchError((_) {});
```

Quelle: [app_router.dart](../lib/app/app_router.dart#L96-L100) und
[app_router.dart](../lib/app/app_router.dart#L159-L164).

Fehler beim Start sind über einen Retry-Screen sichtbar, aber spätere Fehler
haben weder Status noch Retry-Option noch eine geschwärzte Diagnose. Die
SQLite-Queue verhindert unmittelbaren Datenverlust, was gut ist, aber der
Benutzer kann nicht unterscheiden zwischen "nichts Neues" und "erfasste Drafts
wurden seit Tagen nicht synchronisiert".

**Fehlerszenario**

1. Firestore wird nach dem Start nicht mehr erreichbar.
2. Wallet-Drafts gelangen weiterhin in die SQLite-Queue.
3. Jede Resume-Sync schlägt fehl.
4. Die App behält veraltete Drafts stillschweigend lokal.
5. Der Benutzer geht davon aus, dass alle Ausgaben importiert wurden.

**Empfohlene Lösung**

Einen kleinen Sync-Status wie `idle`, `syncing`, `failed` und
`lastSuccessfulAt` bereitstellen. Fehler geschwärzt halten. Eine
Retry-Action in der Nähe der Pending-Drafts-Anzeige nur dann zeigen, wenn
eine dauerhafte Queue unsynchronisiert bleibt.

Keine Händler-, Betrags-, UID-, Notiz- oder Rohbenachrichtigungsdaten in Logs
oder Telemetrie aufnehmen.

### 4.6 ⚠️ `TransactionMonthSummary` legt veränderlichen State offen

Die Klasse speichert die vom Aufrufer übergebene Map direkt:

```dart
class TransactionMonthSummary {
  final DateTime month;
  final int transactionCount;
  final Map<String, double> categoryTotals;
}
```

Quelle:
[transaction_month_summary.dart](../lib/features/transactions/domain/entities/transaction_month_summary.dart#L3-L12).

`final` verhindert nur, dass die Map-Referenz ersetzt wird; es verhindert nicht
`summary.categoryTotals['food'] = 999`. Das verletzt das ansonsten
immutable Domain-Modell und kann State-Änderungen erzeugen, die Riverpod
nicht beobachtet.

**Mögliche Lösungen**

- Den Input mit `Map.unmodifiable` umschließen.
- `UnmodifiableMapView` bereitstellen.
- Das Modell auf Freezed umstellen, passend zum Rest des Domain-Layers, mit
  struktureller Gleichheit und unveränderlichen Collection-Views.

**Empfohlene Lösung**

Den Typ im Zug der Minor-Units-Migration auf Freezed umstellen. Seine Map
sollte zu `Map<String, int> categoryTotalsMinor` werden, um zwei Migrationen
desselben Modells zu vermeiden.

### 4.7 ✅ Keine nennenswerten God-Klassen oder Const-Constructor-Probleme

Große Screens sind bereits in private Widgets, gemeinsam genutzte Controls
und reine Services aufgeteilt. Manche Build-Methoden bleiben umfangreich, aber
Business-Berechnungen finden dort im Allgemeinen nicht direkt statt. Fehlende
`const`-Instanzen sind im Vergleich zu den Problemen im Data Layer und bei
Listen in späteren Phasen kein relevantes Performance-Thema.

**Empfehlung:** Kein flächendeckendes "const überall ergänzen"-Refactoring
starten. Das würde Unruhe erzeugen, ohne einen gemessenen Engpass zu beheben.

### 4.8 ✅ Direkte JSON-Codegen-Dependencies entfernt

Die Persistenz bleibt bei expliziten Firestore-Mappern, die `Timestamp`,
Migrations-Defaults und storage-spezifische Validierung kapseln. Die ungenutzten
direkten Dependencies `json_annotation` und `json_serializable` wurden nach
erfolgreicher Codegenerierung entfernt.

---

## 5. Phase 2: Android-Plattformcode und Notifications

### 5.1 🔥 Der native aktive Owner wird beim Sign-out nicht gelöscht

Jede Synchronisierung setzt die aktive Firebase-UID in den nativen Preferences:

```kotlin
fun setActiveOwner(userId: String) {
    preferences.edit().putString(ACTIVE_OWNER_KEY, userId).apply()
}
```

Der Listener liest diesen Wert, sobald er eine Zahlung in die Queue einreiht:

```kotlin
val ownerId = preferences.getString(ACTIVE_OWNER_KEY, null) ?: return false
```

Quelle:
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L28-L40).

Wird `_AuthenticatedHome` disposed, entfernt es Observer und Abonnements,
ruft aber nicht `clearActiveOwner()` auf:

```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _captureEventsSubscription.cancel();
  _pendingDraftsSubscription.close();
  super.dispose();
}
```

Quelle: [app_router.dart](../lib/app/app_router.dart#L118-L123).

Der einzige aktuelle Dart-Zweig, der den Owner löscht, liegt innerhalb
des in Phase 1 beschriebenen ungenutzten Providers.

**Auswirkung**

- Wallet-Notifications, die im abgemeldeten Zustand eintreffen, werden weiterhin
  mit der vorherigen UID markiert.
- Ein anonymes Konto, das sich abgemeldet hat, kann Drafts ansammeln, die
  möglicherweise nie wiederherstellbar sind.
- Auf einem gemeinsam genutzten Gerät können Käufe des nächsten Gerätebenutzers
  lokal dem vorherigen Firebase-Owner zugeschrieben werden.
- Eine noch laufende Sync des alten Benutzers kann mit einem neuen Login
  kollidieren, weil das Future selbst nicht abgebrochen wird, wenn
  `_AuthenticatedHome` disposed wird.

Das ist kein nachgewiesenes Firestore-Read-Leck über Benutzergrenzen hinweg.
Queue-Reads werden nach dem aktuell aktiven Owner gefiltert. Es bleibt aber ein
ernsthafter lokaler Datenschutz- und Zuordnungsmangel.

**Mögliche Lösungen**

1. Den Owner nur im Callback des Logout-Buttons löschen.
2. Ihn innerhalb von `AuthController.signOut()` vor dem Firebase-Sign-out
   löschen.
3. Einen App-lebenslangen Auth-/Native-Koordinator ergänzen, der den Owner
   für eine angemeldete UID setzt und ihn löscht, sobald der aufgelöste
   Auth-State null wird.
4. Optionen 2 und 3 kombinieren, für sofortiges Handeln plus einen defensiven
   Fallback.

**Empfohlene Lösung**

Option 4 verwenden. Der Auth-/Native-Koordinator sollte die Source of Truth
sein, während `AuthController.signOut()` den Owner sofort löschen sollte, um das
Zeitfenster zu schließen, bevor der Auth-Stream feuert. Ein Fehler beim
Cleanup darf den Firebase-Sign-out nicht verhindern.

Der Koordinator braucht zudem eine Owner-Generation oder ein Cancellation-Token,
damit eine für UID A gestartete Sync UID A nicht erneut setzen kann, nachdem
die Authentifizierung zu UID B gewechselt hat.

**Erforderliche Tests**

- Angemeldet -> abgemeldet löscht den Owner genau einmal.
- Ein Fehler beim Google-Sign-out löscht dennoch den nativen Owner und
  versucht den Firebase-Sign-out.
- Eine Sync für Benutzer A, die abschließt, nachdem sich Benutzer B
  angemeldet hat, kann Benutzer A nicht als aktiven Owner wiederherstellen.
- Notifications, die im abgemeldeten Zustand eintreffen, werden nicht in die
  Queue eingereiht.

### 5.2 🔥 Aus Notifications abgeleitete Finanzdaten liegen im Klartext und werden gesichert

Die Queue speichert diese Felder in einer gewöhnlichen SQLite-Datenbank:

- Firebase-UID;
- Quell-Notification-Key;
- Händler und normalisierter Händler;
- Betrag in Minor Units;
- Capture- und Vorfalls-Zeitstempel;
- Sync-Status.

Siehe
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L108-L125).

Die aktive UID wird ebenfalls in gewöhnlichen `SharedPreferences` gespeichert,
unter
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L23-L26).

Das App-Manifest setzt weder `android:allowBackup="false"`,
`android:fullBackupContent` noch `android:dataExtractionRules`:

```xml
<application
    android:label="${appName}"
    android:name="${applicationName}"
    android:icon="@mipmap/launcher_icon">
```

Quelle: [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L2-L6).

Folglich nehmen die Datenbank und die Preferences am Standard-Backup-Verhalten
von Android teil, sofern nicht Plattform- oder Geräterichtlinien dies verhindern.

**Bedrohungsmodell**

- Ein Geräte-Backup kann Händler- und Betragshistorie außerhalb der
  Zugriffskontrollen von Firestore enthalten.
- Zugriff über gerootete Geräte, Forensik oder Debug-Backups kann die Queue
  direkt auslesen.
- Synchronisierte Datensätze bleiben erhalten, wodurch die Exposition mit der
  Zeit wächst.
- Das Löschen der App-Authentifizierung entfernt alte Owner-Zeilen nicht.

**Mögliche Lösungen**

1. Android-Backup für die gesamte App deaktivieren.
2. Backup aktiviert lassen, aber die Queue-Datenbank und die
   Active-Owner-Preferences über Backup- und Data-Extraction-XML-Regeln
   ausschließen.
3. Queue-Storage unter `noBackupFilesDir` ablegen.
4. Die Datenbank mit einem durch Android Keystore geschützten Key
   verschlüsseln.
5. Beibehaltene Felder minimieren und quittierte Zeilen löschen.

**Empfohlene Lösung**

Defense in Depth anwenden:

1. Die Datenbank und die Owner-Preference sofort sowohl aus dem alten
   `fullBackupContent` als auch aus den `dataExtractionRules` von Android 12+
  ausschließen. Das gesamte App-Backup zu deaktivieren ist sinnvoll, weil
  Firestore bereits die Source of Truth ist.
2. Die Queue mit einer gepflegten SQLCipher-Integration und einem durch
   Android Keystore geschützten Key verschlüsseln.
3. Quittierte Zeilen nach einer kurzen, dokumentierten Kulanzfrist für Retries
   löschen.
4. Owner-spezifische lokale Zeilen löschen, wenn die Produktrichtlinie zur
   Kontoentfernung dies verlangt.

**Abnahmekriterien**

- Die Android-Backup-Inspektion enthält weder Queue-Zeilen noch die aktive UID.
- Das Auslesen der Rohdatenbank zeigt keinen Händler- oder Betrags-Klartext.
- Ein Retention-Test belegt, dass quittierte Zeilen planmäßig entfernt werden.
- Eine Key-Invalidierung schlägt fail closed fehl und führt zu einem
  wiederherstellbaren, datenschutzsicheren Zustand.

### 5.3 ⚠️ Debug-Logging legt rohe Zahlungsdetails offen

Debugfähige Builds loggen den Notification-Key, Zeitstempel, Titel,
Text, Big Text, Untertext und Summary:

```kotlin
if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE == 0) return

Log.d(
    DIAGNOSTIC_TAG,
    """
    key=${notification.key}
    title=${extras.getCharSequence(Notification.EXTRA_TITLE)}
    text=${extras.getCharSequence(Notification.EXTRA_TEXT)}
    bigText=${extras.getCharSequence(Notification.EXTRA_BIG_TEXT)}
    """.trimIndent(),
)
```

Quelle:
[GoogleWalletNotificationListener.kt](../android/app/src/main/kotlin/ch/stutz/app/GoogleWalletNotificationListener.kt#L56-L73).

Der Release-Build-Guard ist gut, aber Debug-Builds laufen häufig auf echten
Geräten mit echten Wallet-Notifications. Logcat kann von Dev-Tools,
Bug-Reports oder geteilten Support-Logs erfasst werden.

**Empfohlene Lösung**

Rohes Logging entfernen. Falls Diagnosen nötig sind, nur nicht-sensible
Parser-Metadaten loggen, zum Beispiel:

```text
wallet_notification parserVersion=2 parsed=true hasTitle=true
```

Keine Notification-Keys, Händler, Beträge, Zeitstempel, UIDs oder
Rohtext loggen. Einen Test oder eine statische Prüfung ergänzen, die
sicherstellt, dass verbotene Felder nicht im Diagnose-Logging auftauchen.

### 5.4 ⚠️ Synchronisierte Zeilen werden markiert, nicht entfernt

Das Acknowledgement-Update setzt `synced_at`:

```kotlin
database.writableDatabase.update(
    TABLE_DRAFTS,
    values,
    "owner_id = ? AND draft_id IN ($placeholders)",
    arrayOf(ownerId, *draftIds.toTypedArray()),
)
```

Quelle:
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L89-L103).

Kein Code löscht alte synchronisierte Zeilen. Die Queue fungiert damit als
undeklarierter zweiter Store für die Finanzhistorie.

**Mögliche Richtlinien**

- Sofort nach der Firestore-Quittierung löschen.
- Für eine kurze feste Dauer aufbewahren, etwa 24 Stunden, dann bereinigen.
- Nur opake Deduplizierungs-Hashes aufbewahren und Händler-/Betragsfelder
  entfernen.

**Empfohlene Richtlinie**

Vollständige Zeilen nach der Quittierung löschen. Das Firestore-Insert ist
bereits idempotent, und die lokale Queue dient der Zustellung, nicht der
Archivierung. Falls Replay-Schutz eine längere Retention verlangt, nur den
minimalen Hash und den Ablaufzeitpunkt aufbewahren.

### 5.5 ⚠️ Eine redundante globale Eindeutigkeitsbeschränkung kann einen anderen Owner unterdrücken

Das Schema deklariert beides:

```sql
source_dedupe_key TEXT NOT NULL UNIQUE,
...
UNIQUE (owner_id, source_dedupe_key)
```

Quelle:
[NotificationCaptureQueue.kt](../android/app/src/main/kotlin/ch/stutz/app/NotificationCaptureQueue.kt#L112-L124).

Die spaltenweite `UNIQUE`-Beschränkung gilt global, wodurch die zusammengesetzte,
owner-bezogene Beschränkung redundant wird. Falls Android denselben
Notification-Key für einen späteren Owner wiederverwendet, verwirft
`CONFLICT_IGNORE` den Draft dieses Owners stillschweigend.

**Empfohlene Lösung**

Datenbankversion 3 erstellen, die die spaltenweite Eindeutigkeit entfernt und
nur `UNIQUE(owner_id, source_dedupe_key)` beibehält. Einen Migrationstest mit
zwei Ownern und demselben Quellschlüssel ergänzen.

### 5.6 ⚠️ SQLite-Arbeit läuft synchron auf dem Plattform-Thread

`MainActivity` ruft Reads und Writes der Queue direkt aus dem
MethodChannel-Handler auf:

```kotlin
"acknowledgeSyncedDrafts" -> {
    captureQueue.acknowledgeSyncedDrafts(draftIds)
    result.success(null)
}

"listUnsyncedDrafts" -> result.success(
    captureQueue.listUnsyncedDrafts().map { draft -> /* ... */ },
)
```

Quelle: [MainActivity.kt](../android/app/src/main/kotlin/ch/stutz/app/MainActivity.kt#L44-L82).

Kleine Queues sind in der Regel schnell, aber eine unbegrenzt wachsende
Queue kann den Android-Main-Thread blockieren. SQLite- und
Mapping-Exceptions werden zudem nicht in stabile, App-spezifische
Plattform-Fehlercodes übersetzt. Flutters Embedding kann eine uncaught
Handler-Exception als generische `PlatformException` weiterreichen; Aufrufer
können Corruption, Storage-Erschöpfung und ungültigen Input nicht
unterscheiden.

**Empfohlene Lösung**

- Queue-I/O auf einem einzelnen `Dispatchers.IO`-Coroutine-Scope oder
  dedizierten Executor ausführen.
- Ergebnisse auf dem Main-Thread zurückgeben.
- Erwartete Storage-Exceptions abfangen und stabile Codes wie
  `queue_read_failed`, `queue_write_failed` und `queue_corrupt` verwenden.
- Fehlerdetails frei von Payment-Daten halten.
- Den Scope/Executor beim Destroy der Activity abbrechen.

### 5.7 ⚠️ Die Erfassung aktiver Notifications kann Erfolg melden, obwohl kein Listener existiert

Die statische Funktion ist ein No-op, wenn `activeInstance` null ist, während
`MainActivity` weiterhin Erfolg zurückgibt:

```kotlin
fun captureActiveNotifications() {
    activeInstance?.captureActiveNotificationsInternal()
}
```

Quelle:
[GoogleWalletNotificationListener.kt](../android/app/src/main/kotlin/ch/stutz/app/GoogleWalletNotificationListener.kt#L81-L83).

Dadurch kann ein angeforderter Scan erfolgreich erscheinen, während der
Notification-Listener-Service getrennt ist.

**Empfohlene Lösung:** Einen booleschen oder strukturierten Status vom nativen
Aufruf zurückgeben und `listener_unavailable` gesondert von `permission_denied`
darstellen. Eine spätere Listener-Verbindung löst bereits einen Scan aus,
daher handelt es sich hier um Reliability-Feedback, nicht zwingend um
Datenverlust.

### 5.8 ✅ Listener-Konfiguration und Parser-Verhalten sind solide

Der Service ist durch
`android.permission.BIND_NOTIFICATION_LISTENER_SERVICE` geschützt, filtert das
Google-Wallet-Package, verwirft Group-Summary-Notifications und
führt event-getriebene statt pollende Arbeit aus. Es wird kein
eigener Wake Lock erworben.

Der Parser verwendet korrekt `BigDecimal`, verwirft nicht-positive Werte und
verlangt eine exakte Zwei-Dezimalstellen-Umwandlung:

```kotlin
val amount = BigDecimal(amountText.replace(',', '.'))
    .setScale(2, RoundingMode.UNNECESSARY)
return amount.movePointRight(2).longValueExact()
```

Quelle:
[GoogleWalletNotificationListener.kt](../android/app/src/main/kotlin/ch/stutz/app/GoogleWalletNotificationListener.kt#L152-L171).

`EventChannel.onCancel` löscht den Callback, und `onDestroy` bietet einen
zweiten Cleanup-Pfad in
[MainActivity.kt](../android/app/src/main/kotlin/ch/stutz/app/MainActivity.kt#L16-L42).

Diese Entscheidungen sollten beibehalten werden.

### 5.9 ⚠️ Die Debug-Wakelock-Aktivierung wird nicht awaited

Der Start ruft `WakelockPlus.enable()` auf, ohne zu warten oder
Plugin-Fehler zu behandeln:

```dart
if (kDebugMode) {
  WakelockPlus.enable();
}
```

Quelle: [main.dart](../lib/main.dart#L15-L17).

Das betrifft nur Debug-Builds und ist für den Akkuverbrauch in Production
irrelevant.
Es kann dennoch einen uncaught asynchronen Plugin-Fehler in der Entwicklung
erzeugen und macht das Startverhalten von einem nicht wesentlichen Plugin
abhängig.

**Empfohlene Lösung:** Entfernen und stattdessen auf die bestehende
scrcpy-Dev-Task setzen, oder mit explizitem Error Handling über
`unawaited` und einem geschwärzten Debug-Log aufrufen.

---

## 6. Phase 3: Firebase-Integration und Data Layer

### 6.1 🔥 Persistiertes Geld verwendet binäre Gleitkommazahlen

Finanzwerte werden im persistierten Modell als `double` dargestellt:

```dart
const factory AppTransaction({
  required String id,
  required String expenseNodeId,
  required double amount,
  required DateTime dateTime,
  String? note,
}) = _AppTransaction;
```

Quelle:
[app_transaction.dart](../lib/features/transactions/domain/entities/app_transaction.dart#L7-L14).

Dasselbe Muster erscheint in:

- `ExpenseNode.plannedAmount` unter
  [expense_node.dart](../lib/features/budget/domain/entities/expense_node.dart#L10-L21);
- `IncomeSource.amount` unter
  [income_source.dart](../lib/features/budget/domain/entities/income_source.dart#L9-L17);
- `TransactionMonthSummary.categoryTotals` unter
  [transaction_month_summary.dart](../lib/features/transactions/domain/entities/transaction_month_summary.dart#L3-L12).

Monatsaggregate erhöhen diese Doubles direkt:

```dart
'categoryTotals': {
  t.expenseNodeId: FieldValue.increment(t.amount),
},
```

Quelle:
[transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L153-L161).

**Warum das wichtig ist**

Dezimalbrüche wie CHF 0,10 lassen sich nicht exakt als binäre Gleitkommazahl
darstellen. Das bekannte Beispiel:

```text
0.1 + 0.2 = 0.30000000000000004
```

Die Formatierung kann den Rest verbergen, aber persistierte Kategoriesummen,
Subtraktion, Nullentfernungslogik, Gleichheit, Backups und Reconciliation
operieren weiterhin darauf. Das aktuelle `_setMonthSummary` entfernt Einträge
nur, wenn `value <= 0`, sodass ein kleiner positiver Rest bestehen bleiben
kann, wenn eine Kategorie eigentlich auf null zurückkehren sollte.

Das heißt nicht, dass bei jeweils zehn Transaktionen sichtbar fünf Rappen
verloren gehen. Der eigentliche Mangel ist, dass die arithmetische Korrektheit
von binärer Näherung und Operationsreihenfolge abhängt – für ein Ledger
ist das ungeeignet.

**Empfohlenes Zielmodell**

```dart
@freezed
abstract class AppTransaction with _$AppTransaction {
  const factory AppTransaction({
    required String id,
    required String expenseNodeId,
    required int amountMinor,
    required DateTime dateTime,
    String? note,
  }) = _AppTransaction;
}
```

Ganzzahlige CHF-Minor-Units verwenden für:

- Transaktionsbeträge;
- Einkommensbeträge;
- geplante Ausgabenbeträge;
- Kategoriesummen;
- monatliche und jährliche Summen;
- alle bei Update/Delete angewendeten Deltas.

Nur für ein visuelles Verhältnis in `double` umwandeln, niemals für
persistiertes Geld.

**Die jährliche Umlage erfordert eine Produktentscheidung**

Ein Jahresbetrag lässt sich möglicherweise nicht gleichmäßig durch 12 teilen.
CHF 100.00 sind zum Beispiel 10.000 Rappen, und `10.000 / 12` ist keine
Ganzzahl. Eine Richtlinie wählen und dokumentieren:

1. Jahresbeträge exakt belassen und nur einen gerundeten Monatsschätzwert
   anzeigen.
2. Jedes monatliche Äquivalent mit einer benannten Regel runden, etwa
   kaufmännisch (half-up).
3. Restrappen bei der Erstellung monatlicher Zuweisungen auf die Monate
   verteilen.

Option 1 passt am besten zum aktuellen Planungsmodell, da Jahresausgaben keine
tatsächlich wiederkehrenden Transaktionsbuchungen sind.

**Migrationsplan**

1. Ein verifiziertes `scope=all`-Backup erstellen, nicht nur ein
   Transaktions-Backup.
2. Jedes finanzielle Feld scannen und nicht-endliche, negative oder
   außerhalb des Bereichs liegende Werte ablehnen, bevor überhaupt geschrieben
   wird.
3. Quellwerte mit einer expliziten Regel wie `round(value * 100)`
   umwandeln und jede gerundete Abweichung protokollieren.
4. `transactionMonths` aus migrierten Transaktions-Quelldokumenten neu
   aufbauen; nicht lediglich bestehende abgeleitete Summen multiplizieren.
5. Einen Reconciliation-Report pro Benutzer erstellen, der aus Transaktionen
   abgeleitete Summen vor und nach der Migration vergleicht.
6. Bei Bedarf ein temporäres Dual-Read-Deployment unterstützen, falls alte und
   neue App-Versionen gleichzeitig vorkommen können.
7. Regeln für das neue Ganzzahl-Schema erst deployen, wenn kompatible
   Clients verfügbar sind.
8. Legacy-Reads entfernen, nachdem die Migration verifiziert wurde.

**Abnahmekriterien**

- Kein persistiertes Finanzfeld verwendet `double`.
- Das Wiederholen von Add/Update/Delete führt zu exakten
  ganzzahligen Summen.
- Jede Monatssumme entspricht einer frischen Reduktion ihrer
  Transaktionsdokumente.
- Tests zur jährlichen Umlage decken nicht teilbare Rappenbeträge ab.

### 6.2 🔥 Firestore-Regeln prüfen Ownership, nicht Schemata

Das gesamte Regelwerk lautet derzeit:

```javascript
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null
    && request.auth.uid == userId;
}
```

Quelle: [firestore.rules](../firestore.rules#L1-L9).

Das verhindert korrekt, dass Alice Bobs Pfad liest oder beschreibt. Es erlaubt
Alices Client aber weiterhin, unter Alices Pfad jede beliebige Form zu
schreiben, einschließlich:

- negativer, gebrochener oder nicht-endlicher Beträge;
- fehlender Transaktionsdaten oder Kategorie-IDs;
- beliebiger Transaktionsmonatszählungen und -summen;
- ungültiger Enum-Namen;
- verwaister Kategorieverweise;
- Draft-State-Übergängen von `discarded` zurück zu `pending`;
- unbekannter Collections und Felder;
- ungültiger Händlerregeln.

Der Rule-Test belegt nur Ownership und Writes in eine
`budgets`-Collection, die die App gar nicht verwendet:
[firestore.rules.test.js](../test/firestore.rules.test.js#L31-L58).

**Warum UI-Validierung nicht ausreicht**

- Alte App-Versionen können weiterhin alte Schemata schreiben.
- Ein kompromittierter oder modifizierter Client umgeht die Flutter-Validierung.
- Fehler im Repository-Code laufen mit denselben Firebase-Berechtigungen wie
  gültige UI-Vorgänge.
- Abgeleitete Monatssummen werden derzeit vom Client verwaltet.

**Mögliche Architekturen**

#### Option A: Vertrauenswürdiges Ledger-Mutations-Backend

Clients rufen eine Cloud Function oder eine andere vertrauenswürdige API für
Add/Update/Delete und Draft-Bestätigung auf. Das Backend schreibt die
Quelltransaktion und die abgeleitete Summe atomar mit Admin-Rechten.
Client-Regeln lehnen Writes in `transactionMonths` ab.

Vorteile:

- stärkste Aggregatintegrität;
- zentrale Idempotenzschlüssel;
- einfachere Security Rules für abgeleitete Dokumente;
- konsistente Validierung über App-Versionen hinweg.

Abwägungen:

- Backend-Deployment- und Betriebskosten;
- Offline-Writes brauchen eine dauerhafte Command-Queue und einen klaren
  Pending-State;
- mehr Infrastruktur als direkte Firestore-Writes.

#### Option B: Direkte Client-Transaktions-Writes, keine persistierten Summen

Clients schreiben streng validierte Quelltransaktionen. Dashboard-Summen
werden aus Quelldatensätzen abgefragt oder berechnet.

Vorteile:

- die Source of Truth ist einfach;
- keine Corruption von Summen.

Abwägungen:

- mehr Reads und Client-Berechnung;
- umfangreiche Historien brauchen sorgfältig begrenzte Queries oder
  Firestore-Aggregationsfunktionen.

#### Option C: Direkte Client-Writes plus client-gepflegte Summen

Regeln nutzen strikte Schemata und `getAfter()`-Checks, um
Mehrfachdokument-Writes einzugrenzen.

Vorteile:

- bewahrt die aktuelle Offline-/Client-Architektur.

Abwägungen:

- Regeln werden komplex und schwer nachweisbar;
- die Validierung beliebiger Kategoriesummen-Maps ist fragil;
- Clients kontrollieren weiterhin sowohl Source Data als auch abgeleitete Daten.

**Empfohlene Architektur**

Option A für Transaktions- und Summenmutationen verwenden, falls Stutz für den
produktiven Einsatz vorgesehen ist. Falls Backend-Infrastruktur derzeit
außer Scope liegt, ist Option B sicherer, als vorzugeben, Option C sei
vollständig manipulationssicher.

**Illustrative Regelrichtung**

Das Folgende ist eine Designskizze, kein einsatzbereites vollständiges
Regelwerk:

```javascript
function owns(userId) {
  return request.auth != null && request.auth.uid == userId;
}

function validTransaction(userId) {
  let data = request.resource.data;
  return data.keys().hasOnly(
      ['expenseNodeId', 'amountMinor', 'dateTime', 'note'])
    && data.keys().hasAll(['expenseNodeId', 'amountMinor', 'dateTime'])
    && data.expenseNodeId is string
    && data.expenseNodeId.size() > 0
    && data.amountMinor is int
    && data.amountMinor > 0
    && data.dateTime is timestamp
    && (!('note' in data) || data.note == null || data.note is string)
    && exists(/databases/$(database)/documents/users/$(userId)/expense_nodes/$(data.expenseNodeId));
}

match /users/{userId}/transactions/{transactionId} {
  allow read: if owns(userId);
  allow create, update: if owns(userId) && validTransaction(userId);
  allow delete: if owns(userId);
}

match /users/{userId}/transactionMonths/{monthId} {
  allow read: if owns(userId);
  allow write: if false; // Trusted backend only.
}
```

Äquivalente Schemata und Übergangsprüfungen sind für Expense Nodes, Einkommen,
Drafts und Händlerregeln erforderlich. Ein abschließendes Catch-all sollte
unbekannte Pfade ablehnen.

**Erforderliche Emulator-Testmatrix**

- Eigener Read gelingt; benutzerübergreifender und nicht authentifizierter
  Zugriff schlagen fehl;
- fehlende, zusätzliche und falsch typisierte Felder schlagen fehl;
- Null- und negative Beträge schlagen fehl;
- gebrochene Minor-Unit-Beträge schlagen fehl;
- nicht existierende und nicht-variable Kategorieverweise schlagen fehl;
- unzulässige Draft-State-Übergänge schlagen fehl;
- Clients können keine Summendokumente fälschen;
- gültige Create-/Update-/Delete-Abläufe gelingen weiterhin.

### 6.3 🔥 Das manuelle Anlegen von Transaktionen ist nicht idempotent

Das Repository verwendet einen Batch, der das Transaktionsdokument überschreibt
und immer die Monatssumme erhöht:

```dart
Future<void> addTransaction(AppTransaction t) async {
  final transactionReference = _collection.doc(t.id);
  // ...
  batch.set(transactionReference, TransactionMapper.toDocument(t));
  batch.set(monthReference, {
    'transactionCount': FieldValue.increment(1),
    'categoryTotals': {
      t.expenseNodeId: FieldValue.increment(t.amount),
    },
  }, SetOptions(merge: true));
  await batch.commit();
}
```

Quelle:
[transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L147-L162).

**Konkretes Fehlerbeispiel**

Ausgangszustand:

```text
transaction tx-1: absent
month count: 0
food total: CHF 0.00
```

Die erste Anfrage fügt `tx-1` für CHF 20.00 hinzu:

```text
transaction tx-1: CHF 20.00
month count: 1
food total: CHF 20.00
```

Dieselbe ID wird erneut verarbeitet (Replay):

```text
transaction tx-1: CHF 20.00
month count: 2
food total: CHF 40.00
```

Es existiert nur eine Quelltransaktion, aber das abgeleitete Ledger meldet zwei.

Die UUID-Generierung macht zufällige Kollisionen unwahrscheinlich. Sie löst
nicht das Problem der Replay-Semantik nach einem unsicheren
Netzwerkergebnis, doppelten UI-Befehlen, Tests, Imports oder zukünftigen
Integrationen, die IDs bereitstellen.

**Empfohlenes Verhalten**

Ein Create-Befehl muss unterscheiden zwischen:

1. Dokument fehlt: erstellen und einmal erhöhen;
2. Dokument vorhanden mit identischem Payload: als erfolgreichen Replay
   behandeln;
3. Dokument vorhanden mit abweichendem Payload: als ID-Kollision ablehnen;
4. beabsichtigter Ersatz: den expliziten Update-Pfad verlangen, der alte
   und neue Monats-/Kategorie-Deltas abgleicht.

**Umsetzungsrichtung**

Eine Firestore-Transaktion verwenden, die das Transaktionsdokument liest,
bevor irgendwelche Writes erfolgen. Bei einem fehlenden Dokument die
Monatssumme lesen, die Quelle anlegen und das exakte Delta anwenden. Bei
einem vorhandenen Dokument die kanonischen Felder vergleichen und
zurückkehren oder werfen, ohne die Summe anzufassen.

Nach der Minor-Units-Migration sollten alle Vergleiche und Deltas
ganzzahlig basiert sein.

**Erforderliche Tests**

- Erste Erstellung erhöht einmal;
- exakter Replay ist ein No-op und gelingt;
- widersprüchlicher Replay wirft einen Fehler und bewahrt sowohl Quelle
  als auch Summe;
- gleichzeitige Erstellungen mit einer ID erzeugen eine Quelle und eine
  Erhöhung;
- ein Replay nach einem unklaren Transportfehler gleicht korrekt ab.

### 6.4 ✅ Die Bestätigung importierter Drafts ist bereits idempotent

Das Draft-Repository prüft den Status vor dem Schreiben:

```dart
if (draft.status == TransactionDraftStatus.saved) {
  final savedTransactionId = draft.savedTransactionId;
  if (savedTransactionId == null) {
    throw StateError(/* ... */);
  }
  return savedTransactionId;
}
```

Quelle:
[transaction_draft_repository.dart](../lib/features/notification_import/data/transaction_draft_repository.dart#L91-L103).

Da Draft-Status, importierte Transaktion, Summe und Händlerregel in einer
Firestore-Transaktion geschrieben werden, sieht ein normaler Replay
`saved` und kehrt zurück, ohne erneut zu erhöhen.

**Verbleibende Lücke bei Defense in Depth:** Falls permissive
Regeln es einem anderen Client erlauben, `import_<draftId>` zu erstellen,
während der Draft noch `pending` ist, kann die Bestätigung dieses Dokument
überschreiben. Strikte Regeln und ein Kollisions-Read am
Transaktionsdokument sollten davor schützen.

### 6.5 🔥 Anonyme Benutzer können ihr Ledger dauerhaft verlieren

Das Sign-out-Symbol des Budget-Screens ruft die Abmeldung sofort auf:

```dart
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await ref.read(authControllerProvider.notifier).signOut();
  },
)
```

Quelle:
[budget_planning_screen.dart](../lib/features/budget/presentation/budget_planning_screen.dart#L54-L62).

Anonyme Firebase-Konten haben kein dem Benutzer bekanntes Login. Sobald die
lokale Auth-Session entfernt ist, kann der Benutzer diese UID oder sein
verschachteltes Firestore-Ledger im Allgemeinen nicht wiederherstellen. Eine
Neuinstallation hat dasselbe Wiederherstellungsproblem.

**Empfohlener Produktablauf**

Wenn `FirebaseAuth.currentUser.isAnonymous` wahr ist:

1. Erklären, dass die aktuellen Daten zu einem temporären Konto gehören.
2. "Google-Konto verknüpfen" als primäre Aktion anbieten.
3. `linkWithCredential` verwenden, nicht `signInWithCredential`, damit die UID
   und bestehende Firestore-Daten mit dem Konto verbunden bleiben.
4. Einen getesteten Export vor jeder destruktiven Abmeldung anbieten, falls die
   Kontoverknüpfung abgelehnt wird.
5. Eine explizite Bestätigung verlangen, dass der Zugriff dauerhaft verloren
   gehen kann.

`credential-already-in-use` als bewusstes Konto-Merge-Problem behandeln;
nicht stillschweigend die UID wechseln und dabei eines der beiden Ledgers
verwaisen lassen.

### 6.6 🔥 Ein Fehler beim Google-Sign-out verhindert den Firebase-Sign-out

Die aktuelle Reihenfolge lautet:

```dart
Future<void> signOut() async {
  await _googleSignIn.signOut();
  await _auth.signOut();
}
```

Quelle: [auth_service.dart](../lib/features/auth/data/auth_service.dart#L65-L68).

Wirft die Google-Bereinigung einen Fehler, wird der Firebase-Sign-out nie
versucht. Die UI meldet einen Fehler, aber der Benutzer bleibt in der App
authentifiziert, deren Daten er eigentlich schließen wollte.

**Empfohlene Richtlinie**

Der Firebase-Sign-out ist der entscheidende Schritt. Die Google-Bereinigung
versuchen, jeden Fehler abfangen und schwärzen und danach immer den
Firebase-Sign-out versuchen. Nur ein Fehler beim Firebase-Sign-out sollte
bedeuten, dass die App-Session aktiv bleibt.

Die native Owner-Löschung muss Teil desselben App-Befehls sein, wie in
Phase 2 beschrieben.

**Erforderlicher Test:** Den Google-Sign-out so konfigurieren, dass er einen
Fehler wirft, und prüfen, dass der Firebase-Sign-out und die native
Owner-Bereinigung dennoch ausgeführt werden.

### 6.7 ⚠️ Die Runtime-Validierung stoppt an uneinheitlichen Grenzen

`ExpenseNode` hat eine nützliche Methode `validateForWrite()`, und
Budget-Mutationen rufen sie auf. Andere Financial Entities haben keine
gleichwertige Write-Validierung.

`TransactionDraftConfirmation` verlässt sich nur auf Assertions:

```dart
const TransactionDraftConfirmation({
  required this.amountMinor,
  required this.dateTime,
  required this.expenseNodeId,
  this.note,
}) : assert(amountMinor > 0),
     assert(expenseNodeId != '');
```

Quelle:
[transaction_draft_confirmation.dart](../lib/features/notification_import/domain/entities/transaction_draft_confirmation.dart#L1-L15).

Assertions sind in Release-Builds deaktiviert. `AppTransaction` und
`IncomeSource` erlauben ebenfalls ungültige Werte, wenn sie außerhalb der
aktuellen UI-Formulare konstruiert werden.

**Empfohlene Lösung**

- Runtime-Validierung an der Application-/Domain-Mutation Boundary ergänzen.
- Leere IDs, ungültige Daten, nicht-positive Beträge, überlange Notizen und
  nicht unterstützte Kategoriebeziehungen ablehnen.
- Typisierte Validation Exceptions werfen, die der Presentation-Code in
  sichere Meldungen übersetzen kann.
- Alle sicherheitsrelevanten Checks in Firestore-Regeln oder dem
  vertrauenswürdigen Backend wiederholen.

Die Validierung sollte geschichtet sein:

```text
input formatter -> form feedback -> domain command validation
                -> backend/rules validation -> resilient read mapping
```

### 6.8 ⚠️ Ein fehlerhaftes Dokument kann einen kompletten Stream oder eine Query scheitern lassen

Repositories bilden Dokumentlisten direkt ab. Beispiele:

- Expense-Streams in
  [expense_node_repository.dart](../lib/features/budget/data/expense_node_repository.dart#L31-L38);
- Income-Streams in
  [income_source_repository.dart](../lib/features/budget/data/income_source_repository.dart#L23-L26);
- Transaktionsmonat-Summenstreams in
  [transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L40-L49).

Der Transaction-Mapper führt zudem eine ungeprüfte Notiz-Umwandlung durch:

```dart
note: data['note'] as String?,
```

Quelle: [transaction_mapper.dart](../lib/features/transactions/data/transaction_mapper.dart#L40-L47).

Ein einziger ungültiger Notiztyp kann beim Mapping einen Fehler werfen und ein
gesamtes Transaktions-Laden in einen Error State versetzen.

**Fehlerhafte Finanzdatensätze nicht stillschweigend überspringen.** Stilles Filtern würde
Summen als gültig erscheinen lassen und dabei Quelldaten verbergen.

**Empfohlener Ansatz**

Ein abgleichsfähiges Ergebnis zurückgeben:

```text
LedgerReadResult<T>
  validRecords
  malformedDocumentIds
  redactedIssueTypes
```

Die UI kann gültige Datensätze plus eine deutliche Warnung anzeigen, dass
einige Daten repariert werden müssen. Geschwärzte Diagnosen senden und einen
administrativen Reparaturpfad bereitstellen. Strikte Regeln sollten neue
fehlerhafte Datensätze verhindern, während Legacy-Daten bereinigt werden.

### 6.9 ⚠️ Das Löschen von Kategorien nutzt eine race-anfällige Check-then-Delete-Sequenz

Das Repository prüft auf Kinder, prüft auf referenzierende Transaktionen und
führt dann eine separate Löschung durch:

```dart
final childSnapshot = await _collection
    .where('parentId', isEqualTo: id)
    .limit(1)
    .get();

final transactionSnapshot = await _firestore
    // ...
    .where('expenseNodeId', isEqualTo: id)
    .limit(1)
    .get();

await _collection.doc(id).delete();
```

Quelle:
[expense_node_repository.dart](../lib/features/budget/data/expense_node_repository.dart#L50-L70).

Ein anderer Client kann ein Kind oder eine Transaktion erstellen, nachdem die
Prüfungen erfolgt sind, aber bevor die Löschung stattfindet. Firestore-Client-
Transaktionen machen beliebige Collection-Abfragen nicht zu einer bequemen
Invariantengrenze.

**Mögliche Lösungen**

1. Vertrauenswürdige Backend-Transaktion mit kontrollierten
   Referenz-/Index-Datensätzen.
2. Explizite Referenzzähler-Dokumente transaktional pflegen.
3. Kategorien archivieren, statt sie zu löschen.
4. Kategorienamen in Transaktionen einfrieren (Snapshot) und Löschung
   zulassen.

**Empfohlene Lösung**

Kategorien mit Feldern wie `archivedAt` und `isSelectable` archivieren.
Historische IDs auflösbar halten, archivierte Kategorien aus neuen
Transaktionsauswahlen ausschließen und Berichtsbezeichnungen bewahren. Dies ist
in der Regel ein besseres Modell für die Finanzhistorie als das endgültige
Löschen.

### 6.10 ⚠️ Der Client kontrolliert die abgeleiteten Monatssummen

Der Client schreibt sowohl Quelltransaktionen als auch Summendokumente. Obwohl
der normale Add-/Update-/Delete-Code Batches oder
Firestore-Transaktionen verwendet, erlauben die Regeln jedem Owner-Client, beliebige
Summen zu schreiben. Fehler, alte Versionen und modifizierte Clients können
daher Summen von Quelldatensätzen desynchronisieren.

`_monthCount` und `_setMonthSummary` klammern ungültige Werte, statt zu
beweisen, dass eine Summe ihren Quellen entspricht:
[transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L240-L290).

**Empfohlene Lösung:** Transaktionsdokumente als Source of Truth behandeln.
Die Summenpflege in vertrauenswürdigen Code verlagern und das bestehende
Migrations-/Rebuild-Skript als Reconciliation-Tool beibehalten. Einen
Verifizierungsjob planen oder bereitstellen, der jede Summe mit einer frischen
Quellreduktion vergleicht.

### 6.11 ✅ Query-Eingrenzung und Atomizität bei Update/Delete sind allgemein gut

Positive Entscheidungen des Data Layer:

- der Transaktionsverlauf verwendet Cursor-Pagination;
- die direkte Monatsnavigation fragt ein begrenztes Datumsintervall ab;
- Dashboard-Summaries fragen ein ausgewähltes Jahr ab;
- Kategoriedetail-Queries kombinieren Kategorie- und Datumsgrenzen;
- Transaktions-Update und -Delete lesen die alte Quelle und gleichen
  betroffene Monats-/Kategoriesummen in Firestore-Transaktionen ab;
- Zürcher Monatsgrenzen sind zentralisiert;
- ein zusammengesetzter Kategorie-/Datumsindex ist deklariert;
- der Notification-Upload quittiert SQLite erst, nachdem alle
  Firestore-Upserts erfolgreich waren.

Diese Verhaltensweisen sollten beibehalten werden, während die
Geldrepräsentation und die Write-Autorität geändert werden.

---

## 7. Phase 4: Performance, UI/UX und Android-Accessibility

### 7.1 ⚠️ Der Kategorie-Drilldown lädt einen unbegrenzten Zeitraum und rendert ihn

Das Repository führt eine unbegrenzte Kategorie-/Datums-Query aus:

```dart
final snapshot = await _collection
    .where('expenseNodeId', isEqualTo: categoryId)
    .where('dateTime', isGreaterThanOrEqualTo: periodStart)
    .where('dateTime', isLessThan: periodEnd)
    .orderBy('dateTime', descending: true)
    .get();
```

Quelle:
[transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart#L132-L145).

Die Detailansicht fügt dann jede Zeile ungebremst in eine `Column` ein:

```dart
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // ...
    ...transactions.map(_TransactionRow.new),
  ],
);
```

Quelle:
[dashboard_category_detail_screen.dart](../lib/features/dashboard/presentation/dashboard_category_detail_screen.dart#L445-L507).

Monatliche Datensätze sind möglicherweise überschaubar, aber eine stark
genutzte Jahreskategorie kann unbegrenzt wachsen. Jeder Datensatz wird auf
einmal abgerufen, gemappt, gehalten und gebaut.

**Empfohlene Lösung**

1. Eine Repository-Cursor-API mit fester Seitengröße hinzufügen.
2. Den Seiten-Cursor sowie den Lade-/Fehlerfußzeilenstatus in einem
   `AsyncNotifier.family` speichern.
3. Transaktionen mit `ListView.builder`, `SliverList` oder der Sliver-Struktur
   der enthaltenden Seite rendern.
4. Die Datums-/Kategoriesortierung in der Abfrage beibehalten.
5. Einen wiederholbaren Load-more-Zustand und einen Test mit mehreren Seiten
   hinzufügen.

### 7.2 ⚠️ Jede Verlaufsseite verarbeitet alle gehaltenen Transaktionen erneut

Nach jeder Seite führt der Notifier alle geladenen Datensätze zusammen und ruft
`TransactionGrouper.groupByDay` über die vollständige gehaltene Liste auf:

```dart
final transactions = _mergeTransactions(
  current.rawTransactions,
  docs.map(TransactionMapper.fromDocument).toList(),
);

state = AsyncData(
  current.copyWith(
    rawTransactions: transactions,
    groupedDays: _groupTransactions(transactions, categories),
    // ...
  ),
);
```

Quelle:
[transaction_service.dart](../lib/features/transactions/application/transaction_service.dart#L148-L188).

Der Grouper sortiert vor der Gruppierung, sodass jede Seite Arbeit im
Verhältnis zu allen bisher geladenen Datensätzen ausführt, statt nur zur
neuen Seite. Über viele Seiten hinweg wächst die kumulative Arbeit deutlich
schneller als ein einzelner linearer Durchlauf.

**Mögliche Lösungen**

- Seitengruppen inkrementell in die älteste/neueste Tagesgrenze zusammenführen.
- Transaktionen in einer geordneten Map, indiziert nach lokalem Kalenderdatum,
  halten.
- Jeweils einen ausgewählten Monat abfragen und cachen, statt ein beliebig
  großes Verlaufsfenster zu halten.

**Empfohlene Lösung**

Da die Monatsnavigation eine primäre Interaktion ist, Monatsfenster-Queries
als App-Cache-Einheit verwenden. Den ausgewählten Monat und die
unmittelbaren Nachbarn pflegen und nur bei Bedarf innerhalb eines ungewöhnlich
großen Monats paginieren. Das reduziert den Speicherverbrauch und macht die
direkte Monatsnavigation zum natürlichen Datenmodell.

Falls die globale Pagination beibehalten wird, eine inkrementelle
Gruppierungsmethode mit Tests für eine Seite ergänzen, die ihren ersten/letzten
Tag mit einer bestehenden Gruppe teilt.

### 7.3 ⚠️ Der Budgetbaum wird vollständig statt lazy gerendert

`BudgetPlanningScreen` umschließt alle Abschnitte mit einer
`SingleChildScrollView`, und der Ausgabenbaum erzeugt rekursiv verschachtelte
Columns:
[budget_planning_screen.dart](../lib/features/budget/presentation/budget_planning_screen.dart#L27-L49)
und
[expense_item_row.dart](../lib/features/budget/presentation/widgets/expense_item_row.dart#L128-L160).

Das ist für kleine persönliche Budgets akzeptabel, aber ein beliebig tiefer
oder breiter Baum baut jedes erweiterte Nachfahren-Widget auf einmal.

**Empfohlene Lösung:** Vor dem Refactoring profilieren. Falls reale
Datensätze Frame- oder Speicherdruck zeigen, sichtbare erweiterte Knoten in
eine Liste abflachen und mit einer `SliverList` rendern. Den
Erweiterungszustand nach Knoten-ID bewahren. Das hat niedrigere Priorität als
das unbegrenzte Transaktionsdetail, da persönliche Kategoriebäume normalerweise
deutlich kleiner sind als Transaktionshistorien.

### 7.4 ⚠️ Sheets bleiben während Mutationen schließbar

Aufrufer versuchen, das Schließen während des Speicherns zu deaktivieren:

```dart
onClose: isSaving ? null : () => Navigator.pop(context),
```

Quelle:
[add_transaction_dialog.dart](../lib/features/transactions/presentation/add_transaction_dialog.dart#L140-L146)
und
[transaction_draft_review_sheet.dart](../lib/features/notification_import/presentation/transaction_draft_review_sheet.dart#L227-L233).

`AppBottomSheet` interpretiert null jedoch als "das Standard-Pop verwenden":

```dart
onPressed: onClose ?? () => Navigator.pop(context),
```

Quelle: [app_bottom_sheet.dart](../lib/shared/widgets/app_bottom_sheet.dart#L71-L78).

Tippen auf die Barriere, Wischen nach unten und die Android-Zurück-Taste werden
durch den Mutationsstatus ebenfalls nicht deaktiviert.

**Fehlerszenario**

1. Der Benutzer tippt auf Speichern.
2. Der Firestore-Write beginnt.
3. Der Benutzer schließt das Sheet oder wischt es nach unten weg.
4. Der Write gelingt später.
5. Die UI wirkte abgebrochen, aber der Finanzdatensatz wurde angelegt.

**Empfohlene Lösung**

- Die mehrdeutige nullable `onClose`-Semantik durch ein explizites `canClose`
  ersetzen.
- Transaktionalen Sheet-Inhalt in `PopScope(canPop: !isSaving)` einbetten.
- Den Close-Button während des Speicherns deaktivieren.
- Bei Formular-Sheets `isDismissible: false` und `enableDrag: false` setzen,
  oder den Dismiss-Status der Route dynamisch über einen Controller offenlegen.
- Auswahl-/Info-Sheets weiterhin schließbar lassen.

Das Standard-Navigator-Zurückverhalten ist ansonsten angemessen; das Fehlen
eines globalen `PopScope` ist an sich kein Mangel.

### 7.5 ⚠️ Das Touch Target für Pending Drafts ist 28 px hoch

Der eigentliche `InkWell` der Anzeige enthält ein 28-mal-28-Pixel großes
visuelles Ziel:

```dart
child: SizedBox(
  width: count < 10 ? 28 : null,
  height: 28,
  // ...
),
```

Quelle:
[pending_transaction_drafts_indicator.dart](../lib/features/notification_import/presentation/pending_transaction_drafts_indicator.dart#L16-L49).

Sein äußeres Padding ist nur horizontal, sodass der tippbare Bereich nicht das
48-mal-48-Material-Accessibility-Ziel erfüllt.

**Empfohlene Lösung:** Das 28-px-visuelle Badge beibehalten, aber es innerhalb
einer 48-mal-48-`SizedBox` zentrieren, die den `InkWell` und die Semantik
besitzt. Einen Widget-Test ergänzen, der die Hit-Test-Größe prüft.

### 7.6 ⚠️ Manche Controls brauchen stärkere Semantik und Feedback

Die Pending-Drafts-Anzeige hat ein nützliches `Semantics`-Label, und
viele Icon-Buttons haben Tooltips. Lücken bleiben bestehen:

- das Sign-out-Symbol hat keinen Tooltip unter
  [budget_planning_screen.dart](../lib/features/budget/presentation/budget_planning_screen.dart#L54-L62);
- der Finanzfortschritt wird primär durch Farbe und knappen Text vermittelt;
- abgekürzte CHF-Werte werden von Screenreadern möglicherweise nicht natürlich
  ausgesprochen;
- das globale Theme entfernt Splash- und Highlight-Feedback:

```dart
splashFactory: NoSplash.splashFactory,
highlightColor: Colors.transparent,
```

Quelle: [app_theme.dart](../lib/core/theme/app_theme.dart#L91-L95).

Das Entfernen jeglichen Pressed-State-Feedbacks schwächt die
Android-Bedienbarkeit und kann eine langsame Aktion unreaktiv erscheinen lassen.

**Empfohlene Lösung**

- Materials Standard-Interaktions-Feedback wiederherstellen oder eine dezente
  themenbezogene `overlayColor` verwenden.
- Tooltips zu jedem reinen Icon-Command ergänzen.
- Semantische Labels wie "20 Franken 50 ausgegeben, 40 Prozent des Budgets" um
  Fortschrittszusammenfassungen ergänzen.
- Die TalkBack-Traversierung, große Schrift bei 200 % und den Kontrast sowohl
  im normalen als auch im Über-Budget-Zustand prüfen.

### 7.7 ⚠️ Die Cloud-Anzeige meldet den Netzwerk-Interface-Status als Sync-Status

`connectivity_plus` wird wie folgt verwendet:

```dart
return Connectivity().onConnectivityChanged;
// ...
return results.contains(ConnectivityResult.none);
```

Quelle:
[connectivity_provider.dart](../lib/core/connectivity/connectivity_provider.dart#L6-L23).

Die UI sagt dann:

```text
Du bist offline. Daten werden lokal gespeichert.
```

Quelle: [cloud_status_icon.dart](../lib/shared/widgets/cloud_status_icon.dart#L10-L18).

WLAN- oder Mobilfunkverfügbarkeit belegt nicht, dass Firestore erreichbar ist
oder dass Writes synchronisiert sind. Ein Captive Portal, ein
DNS-Fehler, ein blockierter Endpunkt, ein abgelaufener Auth-State oder ein
Backend-Ausfall können alle "online" erscheinen.

**Empfohlenes State-Modell**

Den Backend-State darstellen statt nur den Interface-Status:

```text
synced
pendingWrites
fromCache
operationFailed
unknown
```

Firestore-Snapshot-Metadaten (`hasPendingWrites`, `isFromCache`) und
Mutationsergebnisse verwenden. Konnektivität kann ein sekundärer Hinweis
bleiben, nicht die Source of Truth. Den Text so ändern, dass er niemals
verspricht, Daten seien sicher gespeichert oder synchronisiert, ohne
Backend-Beleg.

### 7.8 ⚠️ Die Betragseingabe akzeptiert mehr als zwei Dezimalstellen

`parsePositiveAmount` akzeptiert jeden endlichen positiven `double`, und die
Transaktions- und Draft-Felder verwenden nur eine Dezimaltastatur. Für die
Draft-Bestätigung führt die UI Folgendes aus:

```dart
amountMinor: (amount * 100).round(),
```

Quelle:
[transaction_draft_review_sheet.dart](../lib/features/notification_import/presentation/transaction_draft_review_sheet.dart#L174-L191).

Eine Eingabe wie `1.999` wird akzeptiert und für einen Draft stillschweigend
auf CHF 2.00 gerundet; manuelle Transaktionen persistieren `1.999` derzeit als
Double. Eine Dezimaltastatur ist keine Eingabebeschränkung.

**Empfohlene Lösung**

Währungstext direkt in Minor Units parsen, ohne zuvor in `double`
umzuwandeln:

```dart
int? parsePositiveMinorUnits(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(normalized);
  if (match == null) return null;

  final major = int.tryParse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  final minor = int.tryParse(fraction);
  if (major == null || minor == null) return null;

  final value = major * 100 + minor;
  return value > 0 ? value : null;
}
```

Für Firestore-Ganzzahlen und das Produkt geeignete Überlaufgrenzen ergänzen.
Denselben Parser in allen Income-, Expense-, Transaktions- und
Draft-Formularen verwenden.

### 7.9 ⚠️ Fonts werden zur Laufzeit nachgeladen, sofern nicht gecacht

Das Theme baut Manrope und Inter über `google_fonts` in
[app_theme.dart](../lib/core/theme/app_theme.dart#L50-L89), aber `pubspec.yaml`
bündelt keine Font-Assets.

Das erzeugt Start- und Offline-Variabilität: Das erste Rendering kann
Fallback-Metriken verwenden, der Netzwerkabruf kann fehlschlagen, und das
Textlayout kann sich zwischen Läufen unterscheiden.

**Empfohlene Lösung:** Die exakten Font-Dateien bündeln, sie in
`pubspec.yaml` deklarieren und den Runtime-Abruf deaktivieren. Den
Willkommens-, Dashboard- und Formular-Screen im Flugmodus nach dem Löschen
der App-Daten testen.

### 7.10 ✅ Zentrale Android-UI-Muster sind allgemein solide

Positive Implementierungsdetails:

- der Transaktionsverlauf verwendet eine lazy aufgebaute positionierte Liste;
- die Haupt-Tabs bleiben in einem `IndexedStack` gemountet, wodurch
  Scroll- und Erweiterungszustand erhalten bleiben;
- Formulare verwenden Dezimaltastaturen und Checks auf positive Werte;
- modaler Inhalt reagiert auf Tastatur-Insets;
- die meisten Standard-Buttons verwenden Material-Komponenten mit
  passenden Standardgrößen;
- die Datumseingabe ist auf einen definierten Bereich beschränkt;
- die Monatsnavigation bietet Tooltips und explizite Lade-/Fehlerzustände;
- Formular-Controller werden von Hooks oder State-Objekten mit sauberem
  Dispose verwaltet.

Diese sind es wert, erhalten zu bleiben, während die oben genannten
spezifischen Mängel behoben werden.

---

## 8. Phase 5: Test Coverage und -qualität

### 8.1 ✅ Die Tests sind verhaltensorientiert

Die Suite wird nicht von trivialen Assertions dominiert. Sie deckt ab:

- Budgetberechnungen und jährliche/monatliche Umrechnung;
- Baumkonstruktion, Sortierung, fehlende Elternteile, Duplikate und Zyklen;
- Betragsparsing, einschließlich null, negativ, ungültig und nicht-endlicher
  Werte;
- Firestore-Mapper-Konvertierung und fehlerhafte Felder;
- Transaktionsgruppierung und Zürcher Monatsgrenzen;
- Transaktions-Pagination und direktes Laden von Monatsfenstern;
- Riverpod-Mutationserfolg und Error State;
- Auth-Routing und Onboarding-Persistenz;
- Reihenfolge von Notification-Upload-vor-Acknowledgement;
- Sync-Koaleszenz;
- Händlerkategorie-Vorschläge;
- Draft-Prüfung und gemeinsam genutztes Widget-Verhalten;
- Backup-Kodierung, Manifeste, Prüfsummen und Migrationsberechnungen;
- beobachtete Wallet-Notification-Parsing-Formate.

Der aktuelle Flutter-Testlauf bestand 140 Tests. Backup- und Migrations-Unit-
Suiten bestanden ebenfalls.

### 8.2 🔥 Risikogewichtete Coverage ist unzureichend

Die Gesamt-Line-Coverage liegt bei 61,32 %, aber der Gesamtprozentsatz
verbirgt die wichtige Lücke:

| Produktionsdatei | Gemessene Line Coverage |
| --- | ---: |
| `transaction_repository.dart` | 0,67 % |
| `transaction_draft_repository.dart` | 2,63 % |
| `auth_service.dart` | 8,00 % |
| `notification_capture_method_channel.dart` | 13,16 % |
| `app_router.dart` | 23,89 % |

Diese Dateien tragen die Atomizität von Transaktion/Quellsumme, die
Draft-Bestätigung, den Sign-out, das native Protokoll-Mapping und den
Owner-Lifecycle. Reine Rechner sind gut getestet, während die finanzielle
Mutation Boundary nahezu ungetestet ist.

**Empfehlung:** Risikobasierte Coverage-Ziele verwenden. Eine globale
80-%-Schwelle bringt weniger als eine nahezu vollständige
Branch Coverage für Ledger-Mutation und Auth-/Native-Lifecycle-Code zu
verlangen.

### 8.3 ⚠️ Repository-Tests ersetzen die konkreten Repositories durch Fakes

Application-Notifier-Tests verwenden handgeschriebene Fake-Repositories, zum
Beispiel in
[transaction_mutations_test.dart](../test/features/transactions/application/transaction_mutations_test.dart#L70-L113).

Das ist angemessen, um Notifier-State und Invalidierung zu verifizieren. Es
kann nicht die tatsächliche Firestore-Batch-/Transaktionsimplementierung,
Feldpfade, Merge-Verhalten, Retries oder Aggregatdeltas verifizieren.

**Empfohlene Testschichten**

1. Reine Unit-Tests für Rechner, Mapper und Delta-Funktionen.
2. Provider-Tests mit kleinen Fakes für das Verhalten des App-States.
3. Firestore-Emulator-Integrationstests für konkrete Repositories und Regeln.
4. Kotlin-JVM-/Robolectric- oder Instrumentierungstests für die Queue
   und den Channel.
5. Ein kleiner End-to-End-Android-Ablauf für Capture -> Queue ->
   Dart -> Firestore-Draft -> Bestätigung.

Mockito oder Mocktail ist optional. Handgeschriebene Fakes sind für die
kleinen Interfaces in diesem Repository oft klarer. Was fehlt, ist
konkretes Testen an der Systemgrenze, nicht ein bestimmtes Mocking-Paket.

### 8.4 ⚠️ Rule-Tests validieren nur Isolation

Der Rule-Test erstellt `users/alice/budgets/main`, prüft, dass Alice darauf
zugreifen kann, und prüft, dass Bob/nicht authentifizierte Kontexte das
nicht können. Das ist nützlich, aber nicht mehr ausreichend, sobald
Collection-Schemata eingeführt werden.

Quelle: [firestore.rules.test.js](../test/firestore.rules.test.js#L24-L58).

Tabellengesteuerte Tests für jede Collection und Operation ergänzen. Jeder
"Allow"-Test sollte nahe gelegene "Deny"-Fälle haben für:

- falschen Typ;
- fehlendes Feld;
- zusätzliches Feld;
- ungültiges Enum;
- Null-/negativen Betrag;
- nicht existierende Kategorie;
- Mutation eines unveränderlichen Felds;
- unzulässigen Statuswechsel;
- direkten Write auf die Monatssumme.

### 8.5 ⚠️ Das native Queue-Verhalten hat keine automatisierte Coverage

Die Kotlin-Suite testet nur `GoogleWalletNotificationParser`. Sie testet
nicht:

- Queue-Verhalten ohne aktiven Owner;
- Owner-Isolation;
- doppelte Notification-Keys über Owner hinweg;
- Acknowledgement und Retention;
- Schemamigration von Datenbankversion 1 auf 2;
- Datenbank-Corruption/Fehlerabbildung;
- MethodChannel-Argument- und Exception-Verhalten;
- EventChannel-Listener-Austausch und -Abbruch.

Der versuchte lokale Gradle-Lauf lief nicht, weil die
Task-Konfiguration bei einem laufwerksübergreifenden Flutter-Plugin-Pfad
fehlschlug. Dieses Umgebungsproblem sollte lokal behoben werden, aber CI unter
Linux sollte die native Suite auch unabhängig ausführen, damit die
Workstation-Konfiguration Regressionen nicht verbergen kann.

### 8.6 Empfohlene risikoreiche Testmatrix

#### Transaktions-Repository

| Szenario | Erwartetes Ergebnis |
| --- | --- |
| Neue ID | Eine Transaktion, Zähler +1, exaktes Kategorie-Delta. |
| Exakter Replay | Erfolg ohne zusätzliche Summenänderung. |
| Widersprüchliche ID | Typisierter Kollisionsfehler; keine Writes. |
| Update in derselben Kategorie/demselben Monat | Zähler unverändert; Summe ändert sich um das exakte Delta. |
| Update in eine andere Kategorie | Alte Summe sinkt, neue Summe steigt. |
| Update in einen anderen Monat | Alter Zähler -1, neuer Zähler +1, beide Summen abgeglichen. |
| Delete einer bestehenden Transaktion | Quelle entfernt und Summe einmal verringert. |
| Delete einer fehlenden Transaktion | Idempotenter No-op. |
| Gleichzeitige Creates | Genau ein akzeptierter Create. |

#### Draft-Repository

| Szenario | Erwartetes Ergebnis |
| --- | --- |
| Ausstehende Bestätigung | Draft gespeichert, eine importierte Quelle, ein Summen-Delta, eine Regelaktualisierung. |
| Replay eines gespeicherten Drafts | Gibt gespeicherte ID ohne Writes zurück. |
| Bestätigung eines verworfenen Drafts | Abgelehnt. |
| Fehlende gespeicherte ID | Reconciliation-Fehler wird angezeigt. |
| Bestehende widersprüchliche importierte Quelle | Abgelehnt ohne Aggregatmutation. |
| Ungültige Release-Modus-Bestätigung | Durch Runtime-Validierung abgelehnt. |

#### Auth und nativer Owner

| Szenario | Erwartetes Ergebnis |
| --- | --- |
| Normaler Sign-out | Nativer Owner gelöscht, Firebase abgemeldet, Google bereinigt. |
| Google-Bereinigung schlägt fehl | Nativer Owner gelöscht und Firebase dennoch abgemeldet. |
| Firebase-Sign-out schlägt fehl | UI bleibt authentifiziert und zeigt wiederholbaren Fehler. |
| Sign-out-Anfrage eines anonymen Kontos | Verknüpfungs-/Export-Warnung wird vor destruktiver Aktion angezeigt. |
| Benutzerwechsel während der Sync | Alte Sync kann alten Owner nicht wiederherstellen. |

#### UI und Accessibility

| Szenario | Erwartetes Ergebnis |
| --- | --- |
| Speichern läuft | Schließen, Wischen, Barriere und Zurück können nicht dismissen. |
| Draft-Badge | Touch Target ist mindestens 48 mal 48 logische Pixel. |
| Betrag mit 3 Dezimalstellen | Inline-Validierung lehnt ihn ab. |
| TalkBack | Betrags-/Fortschrittssemantik ist sinnvoll und geordnet. |
| 200 % Textskalierung | Kein abgeschnittenes Betrags-, Aktions- oder Navigationslabel. |

---

## 9. Phase 6: CI/CD und Release-Engineering

### 9.1 ✅ Das zentrale Flutter-Quality-Gate ist solide

Der Test-Job läuft bei Pushes und Pull Requests auf `main` und führt aus:

- Abhängigkeitsauflösung;
- Formatierungsprüfung;
- statische Analyse;
- Riverpod-/Freezed-Generierung;
- Verifizierung des Diffs generierter Dateien;
- Flutter-Tests;
- npm-Installation;
- Firestore-Regeltests.

Quelle: [deploy_android.yml](../.github/workflows/deploy_android.yml#L18-L43).

APK- und AAB-Builds hängen beide von diesem Test-Job ab, und Pull Requests
erzeugen keine Release-Binärdateien. Release-Signierung, Verkleinerung
(Shrinking), GitHub-Release-Upload und Play-Internal-Track-Upload sind
konfiguriert.

### 9.2 ⚠️ Bestehende Test-Suiten sind keine CI-Gates

Das Repository definiert:

```json
"test:backup": "node --test test/firestore-backup.test.js",
"test:backup:emulator": "...",
"test:migration": "node --test test/migrate-transaction-months.test.js"
```

Quelle: [package.json](../package.json#L5-L12).

Der Workflow führt nur `test:rules` aus. Er lässt aus:

- Backup-Unit-Tests;
- Backup-Emulator-Integrationstests;
- Transaktionsmonat-Migrationstests;
- Android-/Kotlin-Unit-Tests.

Das erlaubt es einem Release, CI zu bestehen, selbst wenn die
Backup-/Wiederherstellungssicherheit oder das Wallet-Parsing kaputt ist.

**Empfohlene Lösung:** Alle schnellen Unit Suites zu jedem Pull Request
ergänzen. Die Backup-Emulator-Integration bei Pull Requests ausführen, wenn
die Laufzeit vertretbar bleibt, oder zumindest bei `main` und Release-Tags.
`./android/gradlew testDebugUnitTest` bei jedem Pull Request ausführen.

### 9.3 ⚠️ Es gibt keine Coverage-Schwelle

CI führt `flutter test` aus, nicht `flutter test --coverage`, und prüft nicht
die Coverage kritischer Dateien. Die aktuellen 61,32 % Gesamt-Coverage und
die nahezu null Repository-Coverage erzeugen daher einen grünen Build.

**Empfohlene Lösung**

- LCOV in CI generieren.
- Eine angemessene globale Untergrenze erzwingen, um Regressionen zu
  verhindern.
- Wichtiger: explizite Untergrenzen für Ledger-Repositories, Auth und das
  native Gateway erzwingen.
- Branch-/Szenario-Coverage als Ziel behandeln; keine bedeutungslosen Zeilen
  nur ergänzen, um einen Prozentsatz zu erfüllen.

### 9.4 ⚠️ Flutter- und Gradle-Dependencies werden nicht effektiv gecacht

Der Workflow cacht npm über `actions/setup-node`, aber das Java-Setup hat
keinen Gradle-Cache, und `subosito/flutter-action` aktiviert seine
Cache-Option nicht:
[deploy_android.yml](../.github/workflows/deploy_android.yml#L20-L34).

Build-Jobs wiederholen Setup und Dependency-Downloads unabhängig
voneinander.

**Empfohlene Lösung**

```yaml
- uses: actions/setup-java@v4
  with:
    distribution: zulu
    java-version: '17'
    cache: gradle

- uses: subosito/flutter-action@v2
  with:
    flutter-version: '<pinned-version>'
    cache: true
```

Zudem Workflow-Concurrency ergänzen, damit ein neuerer Commit einen
veralteten, laufenden Lauf auf demselben Branch abbricht.

### 9.5 ⚠️ Der Workflow nutzt einen nicht gepinnten Flutter-Stable-Channel

Jeder Job gibt nur `channel: 'stable'` an. Ein neues Flutter-Stable-Release
kann daher den Compiler, das Android-Tooling, die generierte Ausgabe oder
Defaults ohne einen Repository-Commit ändern.

**Empfohlene Lösung:** Flutter über eine repository-eigene Versionsdatei
oder eine exakte `flutter-version` pinnen. Bewusst in einem eigenen Pull
Request upgraden und die Generierung sowie die vollständige Validierungsmatrix
ausführen.

### 9.6 ⚠️ Getaggte Releases können teilweise veröffentlicht werden

`release_github` hängt nur von `build_apk` ab, während der Play-Upload nur von
`build_aab` abhängt. Falls der AAB-Build fehlschlägt, aber der APK-Build
gelingt, kann für den Tag dennoch ein GitHub-Release veröffentlicht werden.

Quelle:
[deploy_android.yml](../.github/workflows/deploy_android.yml#L132-L176).

**Empfohlene Lösung:** Ein Promotion-Gate ergänzen, das von beiden
signierten Builds abhängt. Beide Release-Ziele sollten Artefakte erst
konsumieren, nachdem APK und AAB bestanden haben. Das erzeugt eine kohärente
Release-Entscheidung.

### 9.7 ⚠️ Der Umgang mit Signaturmaterial kann gehärtet werden

Die Build-Jobs dekodieren den Keystore, die Google-Services-Datei und die
Key-Properties in das Dateisystem des Runners. Ein dateibasierter Keystore
wird von Gradle benötigt, und gehostete GitHub-Runner sind flüchtig, daher ist
das nicht automatisch eine Schwachstelle. Härtungsmöglichkeiten bleiben:

- Secrets über `env` statt über direkte Ausdrucksinterpolation in die Shell
  übergeben;
- `printf` statt `echo` für exakten Inhalt verwenden;
- Workflow-Permissions standardmäßig auf `contents: read` beschränken und
  nur für den GitHub-Release-Job anheben;
- Signaturdateien in einem `always()`-Cleanup-Schritt löschen;
- sicherstellen, dass Artefakte nur APK-/AAB-Pfade hochladen;
- Third-Party-Actions auf überprüfte Commit-SHAs pinnen, für eine
  stärkere Supply-Chain-Kontrolle.

### 9.8 ⚠️ Natives und Skript-Linting fehlen

Die Flutter-Formatierung und -Analyse prüfen weder Kotlin- noch Node-Skripte.
Es gibt keinen ktlint-/detekt- oder JavaScript-Lint-Schritt.

**Empfohlene Lösung:** Eine minimale deterministische
Kotlin-Formatierungs-/Lint-Task sowie eine Node-Lint-Konfiguration für
administrative Skripte ergänzen. Das hinter der Arbeit an finanzieller
Korrektheit einordnen; stilistisches CI sollte kritische Integritätsfixes
nicht verzögern.

### 9.9 ⚠️ Direkte Dependencies haben verfügbare Updates

Für die folgenden direkten Production-Dependencies sind Updates verfügbar:

| Package | Aktuell | Auflösbar | Neueste | Constraint blockiert die auflösbare Version? |
| --- | ---: | ---: | ---: | --- |
| `cloud_firestore` | 6.1.2 | 6.9.0 | 6.9.0 | Nein |
| `connectivity_plus` | 7.0.0 | 7.3.1 | 7.3.1 | Nein |
| `firebase_auth` | 6.1.4 | 6.6.1 | 6.6.1 | Nein |
| `firebase_core` | 4.4.0 | 4.14.0 | 4.14.0 | Nein |
| `flutter_riverpod` | 3.0.3 | 3.3.2 | 3.4.3 | Ja |
| `google_fonts` | 8.0.2 | 8.2.1 | 8.2.1 | Nein |
| `hooks_riverpod` | 3.0.3 | 3.3.2 | 3.4.3 | Ja |
| `intl` | 0.20.2 | 0.20.2 | 0.20.3 | Nein |
| `riverpod_annotation` | 3.0.3 | 4.0.3 | 4.0.7 | Ja |
| `shared_preferences` | 2.5.4 | 2.5.5 | 2.5.5 | Nein |
| `uuid` | 4.5.2 | 4.6.0 | 4.6.0 | Nein |
| `wakelock_plus` | 1.4.0 | 1.6.1 | 1.8.0 | Nein |

**Empfohlene Upgrade-Strategie**

1. Zunächst ungenutzte Dependencies entfernen.
2. Firebase-Packages als eine getestete Kompatibilitätsgruppe upgraden.
3. Riverpod-Annotationen, Runtime-Packages, Generator und Lint-Plugin
   gemeinsam upgraden.
4. Code neu generieren und einen sauberen generierten Diff verlangen.
5. Dependency-Upgrades nicht mit der Money-Schema-Migration kombinieren.

---

## 10. Priorisierter Aktionsplan

### Priorität 1: Kontoübergangs- und Notification-Privacy-Risiko eindämmen

Das ist die kleinste Änderung mit hoher Wirkung und sollte sofort erfolgen.

Deliverables:

1. Native Ownership vor dem Sign-out löschen und immer dann, wenn die
   Authentifizierung zu null aufgelöst wird.
2. Verhindern, dass eine alte Sync einen veralteten Owner wiederherstellt.
3. Rohes Notification-Logging entfernen.
4. Queue-Daten und Active-Owner-Preferences vom Android-Backup ausschließen.
5. Die redundante globale Deduplizierungsbeschränkung entfernen.
6. Tests für Owner-Wechsel und Capture im abgemeldeten Zustand ergänzen.

Definition von "erledigt":

- keine Notification-Queues im abgemeldeten Zustand;
- kein Draft des Owners A kann unter Owner B gelesen oder hochgeladen werden;
- die Backup-Inspektion enthält keine Queue-/Owner-Daten;
- Debug-Logs enthalten keine Zahlungsinhalte.

### Priorität 2: Das ganzzahlige Money-Schema definieren und migrieren

Deliverables:

1. CHF-Minor-Unit- und Jahresumlage-Regeln dokumentieren.
2. Alle persistierten/Quell-/Aggregat-Finanzfelder auf Ganzzahlen umstellen.
3. Striktes Direkt-zu-Minor-Unit-Eingabeparsing ergänzen.
4. Eine Dry-Run-Migration mit Validierung und Abweichungsbericht bauen.
5. Summen aus Quelltransaktionen neu aufbauen.
6. Prä-/Post-Summen jedes Benutzers aus einem verifizierten Backup abgleichen.

Definition von "erledigt":

- persistiertes Geld enthält keine Double-Werte;
- jede Monatssumme entspricht exakt ihrer Quellreduktion;
- die Migration ist wiederholbar und erzeugt einen abgenommenen
  Reconciliation-Report.

### Priorität 3: Eine vertrauenswürdige Transaktions-Write-Boundary etablieren

Deliverables:

1. Vertrauenswürdige Backend-Summen oder ausschließlich quellenbasierte
   Client-Writes wählen.
2. Das manuelle Anlegen idempotent machen.
3. ID-Kollisionen und unzulässige Ersetzungen ablehnen.
4. Collection-spezifische Regeln deployen.
5. Kategorien archivieren statt race-anfällig endgültig zu löschen.
6. Emulator-Tests für jede Mutation und jeden Ablehnungsfall ergänzen.

Definition von "erledigt":

- Replays können Summen nicht zweimal ändern;
- Clients können keine beliebigen Summen schreiben;
- fehlerhafte oder unautorisierte Ledger-Writes werden abgelehnt;
- alle Quell-/Summenmutationen sind reproduzierbar getestet.

### Priorität 4: Anonyme Konten schützen und den Sign-out korrigieren

Deliverables:

1. Anonyme Benutzer vor der Abmeldung erkennen.
2. Google-Credential-Verknüpfung implementieren, die die UID bewahrt.
3. Explizite Warnung vor dauerhaftem Verlust sowie Export-/
   Wiederherstellungsrichtlinie bereitstellen.
4. Den Firebase-Sign-out garantieren, auch wenn die Google-Bereinigung
   fehlschlägt.
5. Tests für Kontokollision und Fehlerpfade ergänzen.

Definition von "erledigt":

- ein Benutzer kann nicht versehentlich ein anonymes Ledger aufgeben;
- der Sign-out schließt die Firebase-Session immer, wenn Firebase verfügbar
  ist;
- die native Owner-Bereinigung ist Teil desselben für den Benutzer sichtbaren
  Vorgangs.

### Priorität 5: Tests für kritische Pfade und Release-Gates verbindlich machen

Deliverables:

1. Konkrete Firestore-Repository-Emulator-Tests ergänzen.
2. SQLite-Queue- und MethodChannel-Tests ergänzen.
3. Kotlin-, Backup-, Migrations-, Rule-, Flutter- und Generierungschecks
   in CI gaten.
4. Risikogewichtete Coverage-Schwellen ergänzen.
5. Flutter pinnen und Flutter-/Gradle-Caches aktivieren.
6. Beide signierten Artefakte verlangen, bevor ein Tag veröffentlicht wird.

Definition von "erledigt":

- ein Mangel bei Transaktions-Reconciliation, Backup, Migration,
  Wallet-Parsing oder Regeln lässt CI fehlschlagen;
- kritische Mutationsdateien haben eine sinnvolle Branch Coverage;
- getaggte Releases werden als eine kohärente APK-/AAB-Einheit befördert.

## 11. Sekundäres Verbesserungs-Backlog

Nachdem die fünf produktionsblockierenden Punkte in Arbeit sind, diese in
dieser Reihenfolge angehen:

1. Kategoriedetail-Transaktionen paginieren.
2. Das Dismissen von Sheets während finanzieller Mutationen verhindern.
3. Interface-bezogene Konnektivität durch den Firestore-Sync-State ersetzen.
4. Das Touch Target für Pending Drafts vergrößern und die
   TalkBack-Semantik vervollständigen.
5. Fonts bündeln und sichtbares Material-Interaktions-Feedback
   wiederherstellen.
6. Verlaufsseiten inkrementell gruppieren oder auf Monatsfenster-Caching
   umstellen.
7. Belastbares Reporting und Reparaturwerkzeuge für fehlerhafte
   Datensätze ergänzen.
8. Synchronisierte Notification-Zeilen bereinigen und die verbleibende
   Queue verschlüsseln.
9. Große Kategoriebäume profilieren, bevor eine Sliver-Neufassung
    umgesetzt wird.

## 12. Checkliste für Finance-Grade

Stutz sollte erst dann als Finance-Grade gelten, wenn alle folgenden Punkte
zutreffen:

- [ ] Alles persistierte Geld verwendet ganzzahlige Minor Units mit
      dokumentierter Rundung.
- [ ] Jeder Transaktionsbefehl ist idempotent.
- [ ] Abgeleitete Aggregate werden vom Backend verwaltet oder automatisiert
  gegen die Source Data abgeglichen.
- [ ] Firestore-Regeln validieren jedes Collection-Schema und jeden
      Übergang.
- [ ] Anonyme Benutzer haben einen getesteten Verknüpfungs-/Export-/
      Wiederherstellungspfad.
- [ ] Der Sign-out löscht Firebase und native Ownership auch unter
      Fehlerbedingungen.
- [ ] Notification-Daten sind vom Backup ausgeschlossen, verschlüsselt,
      geschwärzt und laufen ab.
- [ ] Fehlerhafte Datensätze erzeugen eine sichtbare Reconciliation-Warnung
      statt eines leeren oder fehlgeschlagenen Ledgers.
- [ ] Kritische Repositories und native Grenzen haben Integrationstests.
- [ ] CI führt jede finanzielle, Firebase-, native, Backup- und
      Migrations-Suite aus.
- [ ] Release-Artefakte werden mit gepinntem Tooling gebaut und gemeinsam
  veröffentlicht.
- [ ] Accessibility-Tests decken Touch Targets, TalkBack und große Schrift
      ab.

## 13. Abschließende Einschätzung

Die App hat eine gute Grundlage und braucht keine architektonische
Neufassung. Die richtige Strategie besteht darin, ihre Feature-Grenzen und
reinen Domain-Services zu bewahren, während die finanziellen und
plattformbezogenen Grenzen gestärkt werden.

Die wichtigste Verschiebung ist konzeptioneller Natur: Transaktionsdokumente
müssen als auditierbare Source of Truth behandelt werden, und jede Summe,
jeder Replay, jeder Kontoübergang und jeder lokale Notification-Datensatz
braucht einen expliziten Integritätslebenszyklus. Sobald ganzzahliges Geld,
idempotente vertrauenswürdige Writes, strikte Regeln, geschützte
Kontoübergänge und risikofokussierte Tests vorhanden sind, ist die
verbleibende Performance- und UX-Arbeit inkrementell statt strukturell.
