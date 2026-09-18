# Stutz: Checkliste zur Umsetzung des Application Audits

**Grundlage:** [Application Audit vom 10. September 2026](application-audit-2026-09-10.de.md)  
**Zweck:** Fortschritt, Nachweise und Release-Freigabe für die im Audit priorisierten Verbesserungen nachvollziehbar dokumentieren.  
**Letzte Aktualisierung:** 18. September 2026

## Verwendung und Status

Die Fortschrittsboards sind die verbindliche Tracking-Quelle. Jede Zeile ist
ein eigenständig lieferbares Arbeitspaket. Status, Fortschritt, Aktualisierung,
nächster Schritt und Evidenz werden bei jeder relevanten Änderung gepflegt.
Die darunterliegenden Checkboxen sind die operative Detailabnahme.

Ein Arbeitspaket darf nur den Status `Erledigt` erhalten, wenn die zugehörigen
Abnahmepunkte abgehakt und ein prüfbarer Nachweis verlinkt oder benannt sind.
Ein erfolgreiches lokales Build allein ist kein Abschlusskriterium für eine
daten- oder sicherheitsrelevante Massnahme.

| Status | Bedeutung |
|---|---|
| `Nicht begonnen` | Noch keine umsetzungsreife Arbeit vorhanden. |
| `In Arbeit` | Implementierung, Migration oder Tests laufen. |
| `Blockiert` | Externer oder fachlicher Entscheid fehlt; Blocker eintragen. |
| `Bereit zur Pruefung` | Implementiert, lokal validiert, Review steht aus. |
| `Erledigt` | Review, erforderliche Tests und Nachweis liegen vor. |

| Arbeitsstrom | Fortschritt | Status | Letzte Aktualisierung | Verantwortlich | Zieldatum | Blocker |
|---|---:|---|---|---|---|---|
| Prioritaet 1: Konto und Notification Privacy | 100 % | Bereit zur Pruefung | 16.09.2026 |  |  | Android-Backup inspizieren, Debug-Log-Review und PR-Evidenz dokumentieren. |
| Prioritaet 2: Ganzzahliges Money-Schema | 0 % | Nicht begonnen | 16.09.2026 |  |  |  |
| Prioritaet 3: Trusted Write-Boundary | 0 % | Nicht begonnen | 16.09.2026 |  |  |  |
| Prioritaet 4: Anonyme Konten und Sign-out | 0 % | Nicht begonnen | 16.09.2026 |  |  |  |
| Prioritaet 5: Kritische Tests und Release-Gates | 0 % | Nicht begonnen | 16.09.2026 |  |  |  |

**Pflegeregeln:** Fortschritt wird als Anzahl erledigter Arbeitspakete im
jeweiligen Prioritätsboard berechnet. `Blockiert` benötigt einen konkreten
Blocker und einen nächsten Schritt. `Bereit zur Pruefung` benötigt PR und
lokale Testevidenz. Die Übersichtszeile wird beim Aktualisieren eines
Arbeitspakets mitgezogen.

---

## Prioritaet 1: Kontouebergang und Notification Privacy

**Ziel:** Daten aus der lokalen Notification-Capture duerfen bei Sign-out,
Owner-Wechsel und Backup weder weiterverarbeitet noch offengelegt werden.

### Fortschrittsboard

| ID | Arbeitspaket | Fortschritt | Status | Verantwortlich | Zieldatum | Letzte Aktualisierung | Naechster Schritt | Evidenz / PR / Blocker |
|---|---|---:|---|---|---|---|---|---|
| P1-01 | Native Ownership bei Sign-out und Auth-State `null` bereinigen. | 100 % | Bereit zur Pruefung |  |  | 16.09.2026 | Review und PR-Evidenz verlinken. | `flutter analyze`; `NotificationCaptureQueueTest` bestanden. |
| P1-02 | Race verhindern, bei dem ein alter Sync einen veralteten Owner setzt. | 100 % | Bereit zur Pruefung |  |  | 16.09.2026 | Review und PR-Evidenz verlinken. | Dart-Test fuer abgebrochenen Owner-Sync bestanden. |
| P1-03 | Zahlungsinhalte aus nativen Debug-Logs entfernen oder schwaerzen. | 100 % | Bereit zur Pruefung |  |  | 16.09.2026 | Debug-Log-Review dokumentieren. | Rohes Notification-Logging entfernt; `flutter analyze` bestanden. |
| P1-04 | Queue und Owner-Preferences vom Android-Backup ausschliessen. | 100 % | Bereit zur Pruefung |  |  | 16.09.2026 | Android-Backup inspizieren und Nachweis verlinken. | `allowBackup=false`, Backup- und Data-Extraction-Regeln hinzugefuegt. |
| P1-05 | Globale Deduplizierungsbeschraenkung entfernen und Owner-Isolation sichern. | 100 % | Bereit zur Pruefung |  |  | 16.09.2026 | Review und PR-Evidenz verlinken. | Schema v3 und Migrationstest fuer zwei Owner bestanden. |
| P1-06 | Owner-Wechsel- und Capture-im-abgemeldeten-Zustand-Tests liefern. | 100 % | Bereit zur Pruefung |  |  | 16.09.2026 | Testergebnisse im PR verlinken. | Dart-Suite: 4 bestanden; `NotificationCaptureQueueTest` bestanden. |

### Umsetzung

- [x] Native Ownership vor dem Sign-out loeschen.
- [x] Native Ownership loeschen, sobald der Auth-State zu `null` wird.
- [x] Verhindern, dass eine laufende alte Synchronisierung einen veralteten
  Owner erneut setzt.
- [x] Rohes Notification-Logging mit Zahlungsinhalten entfernen oder
  wirksam schwaerzen.
- [x] SQLite-Queue und Active-Owner-Preferences vom Android-Backup
  ausschliessen.
- [x] Redundante globale Deduplizierungsbeschraenkung entfernen und die
  Owner-Grenze bei der Deduplizierung beibehalten.

### Tests und Nachweise

- [x] Test: Capture im abgemeldeten Zustand erzeugt keine Queue-Zeile.
- [x] Test: Sign-out entfernt den aktiven nativen Owner und die zugehoerige
  Queue.
- [x] Test: Ein Owner-Wechsel kann keine Zeile von Owner A unter Owner B
  lesen oder hochladen.
- [x] Test: Ein verspätet endender Sync kann den alten Owner nicht
  wiederherstellen.
- [ ] Android-Backup-Inspektion dokumentiert, dass Queue- und Owner-Daten
  nicht enthalten sind.
- [ ] Debug-Log-Review dokumentiert, dass keine Zahlungsinhalte ausgegeben
  werden.

### Abnahme

- [x] Keine Notification-Queue existiert im abgemeldeten Zustand.
- [x] Kein Draft von Owner A ist fuer Owner B lesbar oder hochladbar.
- [ ] Backup und Logs erfuellen die Privacy-Anforderungen.
- [ ] Pull Request, Testergebnisse und ggf. Backup-Nachweis sind verlinkt.

**Evidenz / Entscheidung / Rest-Risiko:** `flutter analyze`, die fokussierte
Dart-Synchronisationssuite (4 Tests) und
`NotificationCaptureQueueTest` wurden am 16.09.2026 erfolgreich ausgefuehrt.
Android-Backup-Inspektion, dokumentierter Debug-Log-Review und PR-Review stehen
noch aus. Verschluesselung und Retention quittierter Queue-Zeilen sind nicht
Bestandteil von Prioritaet 1 und verbleiben im sekundaeren Backlog.

---

## Prioritaet 2: Ganzzahliges Money-Schema definieren und migrieren

**Ziel:** Geld wird vom UI bis zu Firestore-Aggregaten ausschliesslich in
ganzzahligen Minor Units verarbeitet; historische Daten werden verifizierbar
migriert.

### Fortschrittsboard

| ID | Arbeitspaket | Fortschritt | Status | Verantwortlich | Zieldatum | Letzte Aktualisierung | Naechster Schritt | Evidenz / PR / Blocker |
|---|---|---:|---|---|---|---|---|---|
| P2-01 | CHF-Minor-Unit- und Jahresumlage-Regeln dokumentieren. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P2-02 | Persistierte, Quell- und Aggregat-Finanzfelder auf Ganzzahlen migrieren. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P2-03 | Striktes Direkt-zu-Minor-Unit-Parsing implementieren. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P2-04 | Dry-Run-Migration mit Validierung und Abweichungsreport bereitstellen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P2-05 | Summen aus Quelltransaktionen neu aufbauen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P2-06 | Prae-/Post-Summen je Benutzer gegen verifiziertes Backup abgleichen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |

### Umsetzung

- [ ] CHF-Minor-Unit-Regeln, erlaubte Praezision und Rundung dokumentieren.
- [ ] Regeln fuer Jahresumlagen und deren Rundung dokumentieren.
- [ ] Persistierte Finanzfelder auf Ganzzahlen umstellen.
- [ ] Quellmodelle und Domain-Modelle auf Ganzzahlen umstellen.
- [ ] Aggregat- und Summary-Felder auf Ganzzahlen umstellen.
- [ ] Direkt-zu-Minor-Unit-Parsing fuer Eingaben implementieren.
- [ ] Eingaben mit mehr als zwei Dezimalstellen, ungueltiger Syntax oder
  nicht positiven Betraegen ablehnen.
- [ ] Dry-Run-Migration mit Validierung und Abweichungsbericht bauen.
- [ ] Monatssummen aus den Quelltransaktionen neu aufbauen.
- [ ] Prae-/Post-Summen je Benutzer aus einem verifizierten Backup abgleichen.

### Tests und Nachweise

- [ ] Unit-Tests fuer Parsing, Rundung und Grenzwerte ergaenzen.
- [ ] Migrations-Dry-Run gegen eine repräsentative Kopie ausfuehren.
- [ ] Reconciliation-Report mit Anzahl, Summe und Abweichungen je Benutzer
  abnehmen.
- [ ] Wiederholung des Dry-Runs liefert dasselbe Ergebnis oder einen
  explizit leeren Delta-Report.
- [ ] Firestore-Stichprobe bestaetigt, dass persistiertes Geld keine
  `double`-Werte mehr enthaelt.

### Abnahme

- [ ] Persistiertes Geld enthaelt keine `double`-Werte.
- [ ] Jede Monatssumme entspricht exakt der Reduktion ihrer
  Quelltransaktionen.
- [ ] Die Migration ist wiederholbar und ihr Reconciliation-Report ist
  abgenommen.
- [ ] Migrationsplan, Backup-Referenz, Report und Freigabe sind verlinkt.

**Evidenz / Entscheidung / Rest-Risiko:**

---

## Prioritaet 3: Vertrauenswuerdige Transaktions-Write-Boundary

**Ziel:** Transaktionen bleiben die auditierbare Source of Truth; Replays,
Kollisionen und manipulierte Client-Writes koennen Ledger-Summen nicht
korrumpieren.

### Fortschrittsboard

| ID | Arbeitspaket | Fortschritt | Status | Verantwortlich | Zieldatum | Letzte Aktualisierung | Naechster Schritt | Evidenz / PR / Blocker |
|---|---|---:|---|---|---|---|---|---|
| P3-01 | Write-Architektur: Backend-Summen oder quellenbasierte Client-Writes entscheiden. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P3-02 | Manuelles Anlegen idempotent machen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P3-03 | ID-Kollisionen und unzulaessige Ersetzungen ablehnen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P3-04 | Collection-spezifische Regeln deployen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P3-05 | Kategorien archivieren statt race-anfaellig endgueltig zu loeschen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P3-06 | Emulator-Tests fuer Mutation und Ablehnungsfaelle liefern. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |

### Architekturentscheidung

- [ ] Entscheiden und dokumentieren: vertrauenswuerdige Backend-Summen oder
  ausschliesslich quellenbasierte Client-Writes.
- [ ] Verantwortung fuer Source-, Aggregat- und Reconciliation-Mutationen
  an der gewaehlten Boundary dokumentieren.
- [ ] Rollback- und Reparaturpfad fuer fehlgeschlagene Mutationen festlegen.

### Umsetzung

- [ ] Manuelles Anlegen einer Transaktion idempotent machen.
- [ ] Replays mit gleicher Command-/Transaktions-ID erkennen.
- [ ] ID-Kollisionen und unzulaessige Ersetzungen explizit ablehnen.
- [ ] Collection-spezifische Firestore-Regeln mit Schema- und
  Uebergangsvalidierung deployen.
- [ ] Direkte Client-Writes auf abgeleitete Summen unterbinden oder nur an
  der vertrauenswuerdigen Boundary erlauben.
- [ ] Kategorien archivieren statt sie race-anfaellig endgueltig zu loeschen.

### Tests und Nachweise

- [ ] Emulator-Test: Create, Update und Delete halten Quelle und Summen
  konsistent.
- [ ] Emulator-Test: Replay veraendert Summen nicht ein zweites Mal.
- [ ] Emulator-Test: ID-Kollision und unzulaessige Ersetzung werden
  abgelehnt.
- [ ] Emulator-Test: unautorisierte, ungueltige und manipulierte Ledger-Writes
  werden abgelehnt.
- [ ] Emulator-Test: Archivierung einer Kategorie bewahrt bestehende
  Transaktionsreferenzen.
- [ ] Reconciliation nach den Mutationstests meldet keine Differenz.

### Abnahme

- [ ] Replays koennen Summen nicht zweimal aendern.
- [ ] Clients koennen keine beliebigen Summen schreiben.
- [ ] Fehlerhafte oder unautorisierte Ledger-Writes werden abgelehnt.
- [ ] Alle Quell- und Summenmutationen sind reproduzierbar getestet.
- [ ] Architekturentscheidung, Rules-Deployment und CI-Nachweis sind
  verlinkt.

**Evidenz / Entscheidung / Rest-Risiko:**

---

## Prioritaet 4: Anonyme Konten schuetzen und Sign-out korrigieren

**Ziel:** Kein anonymes Ledger geht durch einen unklaren Sign-out verloren;
Firebase-Session und native Ownership werden auch bei partiellen Fehlern
zuverlaessig bereinigt.

### Fortschrittsboard

| ID | Arbeitspaket | Fortschritt | Status | Verantwortlich | Zieldatum | Letzte Aktualisierung | Naechster Schritt | Evidenz / PR / Blocker |
|---|---|---:|---|---|---|---|---|---|
| P4-01 | Anonyme Benutzer vor Sign-out erkennen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P4-02 | Google-Credential-Verknuepfung mit UID-Erhalt implementieren. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P4-03 | Verlustwarnung sowie Export- und Wiederherstellungsrichtlinie liefern. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P4-04 | Firebase-Sign-out bei Fehler der Google-Bereinigung garantieren. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P4-05 | Native Owner-Bereinigung in den sichtbaren Sign-out integrieren. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P4-06 | Kollisionen und Fehlerpfade testen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |

### Umsetzung

- [ ] Anonyme Benutzer vor einer Abmeldung erkennen.
- [ ] Google-Credential-Verknuepfung implementieren, die die bestehende UID
  beibehält.
- [ ] Explizite Warnung vor dauerhaftem Datenverlust fuer nicht verknuepfte
  anonyme Konten implementieren.
- [ ] Export- und Wiederherstellungsrichtlinie bereitstellen und verlinken.
- [ ] Firebase-Sign-out garantieren, auch wenn die Google-Bereinigung
  fehlschlaegt.
- [ ] Native Owner-Bereinigung in denselben sichtbaren Sign-out-Vorgang
  integrieren.

### Tests und Nachweise

- [ ] Test: Google-Verknuepfung bewahrt UID und Ledger-Zugriff.
- [ ] Test: Credential-Kollision wird eindeutig behandelt und kommuniziert.
- [ ] Test: Fehler bei Google-Sign-out verhindert Firebase-Sign-out nicht.
- [ ] Test: Fehlerpfad bereinigt nativen Owner und hinterlaesst keinen
  eingeloggten Firebase-State.
- [ ] UX-Review bestaetigt Warnung sowie Export-/Wiederherstellungsweg.

### Abnahme

- [ ] Ein Benutzer kann nicht versehentlich ein anonymes Ledger aufgeben.
- [ ] Der Sign-out schliesst die Firebase-Session immer, wenn Firebase
  verfuegbar ist.
- [ ] Die native Owner-Bereinigung ist Teil desselben sichtbaren Vorgangs.
- [ ] Fehlerpfade, UX-Freigabe und Testnachweise sind verlinkt.

**Evidenz / Entscheidung / Rest-Risiko:**

---

## Prioritaet 5: Kritische Tests und Release-Gates verbindlich machen

**Ziel:** Kritische finanzielle, native und Migrationsfehler erreichen kein
Release, weil die zugehoerigen Tests und Artefaktpruefungen verbindlich in CI
ausgefuehrt werden.

### Fortschrittsboard

| ID | Arbeitspaket | Fortschritt | Status | Verantwortlich | Zieldatum | Letzte Aktualisierung | Naechster Schritt | Evidenz / PR / Blocker |
|---|---|---:|---|---|---|---|---|---|
| P5-01 | Firestore-Repository-Emulator-Tests ergaenzen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P5-02 | SQLite-Queue- und MethodChannel-Tests ergaenzen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P5-03 | Kotlin-, Backup-, Migrations-, Rule-, Flutter- und Generierungschecks als CI-Gates konfigurieren. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P5-04 | Risikogewichtete Coverage-Schwellen durchsetzen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P5-05 | Flutter pinnen sowie Flutter- und Gradle-Caches aktivieren. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P5-06 | Signierte APK und AAB vor Tag-Veroeffentlichung gemeinsam verlangen. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |

### Umsetzung

- [ ] Konkrete Firestore-Repository-Emulator-Tests in die Testsuite aufnehmen.
- [ ] SQLite-Queue-Tests aufnehmen.
- [ ] MethodChannel-Tests fuer native Notification-Grenzen aufnehmen.
- [ ] Kotlin-, Backup-, Migrations-, Rule-, Flutter- und
  Code-Generierungschecks in CI als erforderliche Gates konfigurieren.
- [ ] Risikogewichtete Coverage-Schwellen fuer kritische Mutationsdateien
  definieren und durchsetzen.
- [ ] Flutter-Version pinnen.
- [ ] Flutter- und Gradle-Caches in CI aktivieren.
- [ ] APK und AAB als zusammengehoerige signierte Release-Artefakte vor
  Tag-Veröffentlichung verlangen.

### Tests und Nachweise

- [ ] CI-Negativtest: Ein Fehler in Transaction-Reconciliation blockiert den
  Workflow.
- [ ] CI-Negativtest: Ein Fehler in Backup, Migration, Wallet-Parsing oder
  Firestore-Regeln blockiert den Workflow.
- [ ] CI-Negativtest: Fehlgeschlagene Code-Generierung blockiert den Workflow.
- [ ] Coverage-Report zeigt sinnvolle Branch Coverage fuer kritische
  Mutationsdateien.
- [ ] Release-Probe erstellt signierte APK und AAB mit gepinntem Tooling.
- [ ] Release-Probe bestaetigt die gemeinsame Veroeffentlichung beider
  Artefakte.

### Abnahme

- [ ] Fehler bei Reconciliation, Backup, Migration, Wallet-Parsing oder
  Regeln lassen CI fehlschlagen.
- [ ] Kritische Mutationsdateien erreichen die definierte Branch Coverage.
- [ ] Getaggte Releases werden als kohaerente APK-/AAB-Einheit befoerdert.
- [ ] Workflow-Links, Logs, Coverage-Report und Release-Probe sind verlinkt.

**Evidenz / Entscheidung / Rest-Risiko:**

---

## Sekundaeres Verbesserungs-Backlog

Diese Punkte erst einplanen, nachdem die fuenf priorisierten Arbeitsstroeme
mindestens `In Arbeit` sind und ihre akuten Risiken einen verantwortlichen
Owner haben.

| Reihenfolge | Massnahme | Status | Verantwortlich | Nachweis / PR |
|---|---|---|---|---|
| 1 | Kategoriedetail-Transaktionen paginieren. | Nicht begonnen |  |  |
| 2 | Dismissen von Sheets waehrend finanzieller Mutationen verhindern. | Nicht begonnen |  |  |
| 3 | Interface-Konnektivitaet durch Firestore-Sync-State ersetzen. | Nicht begonnen |  |  |
| 4 | Pending-Drafts-Touch-Target vergroessern und TalkBack-Semantik ergaenzen. | Nicht begonnen |  |  |
| 5 | Fonts buendeln und sichtbares Material-Interaktions-Feedback wiederherstellen. | Nicht begonnen |  |  |
| 6 | Verlaufsseiten inkrementell gruppieren oder Monatsfenster cachen. | Nicht begonnen |  |  |
| 7 | Reporting und Reparaturwerkzeuge fuer fehlerhafte Datensaetze ergaenzen. | Nicht begonnen |  |  |
| 8 | Synchronisierte Notification-Zeilen bereinigen, Rest-Queue verschluesseln. | Nicht begonnen |  |  |
| 9 | Veralteten Sync-Code und ungenutzte direkte JSON-Codegen-Dependencies entfernen. | Bereit zur Pruefung |  | Phasen 1, 3 und 6 der [Refactoring-Checkliste](overengineering-refactoring-checklist.de.md) lokal validiert. |
| 10 | Grosse Kategoriebäume profilieren, dann ueber Sliver-Neufassung entscheiden. | Nicht begonnen |  |  |

---

## Finance-Grade Release-Gate

Diese Liste ist die finale Freigabepruefung. Sie wird erst als bestanden
markiert, wenn alle Nachweise aus den priorisierten Arbeitsstroemen in einem
Release-Review vorliegen.

- [ ] Alles persistierte Geld verwendet ganzzahlige Minor Units mit
  dokumentierter Rundung.
- [ ] Jeder Transaktionsbefehl ist idempotent.
- [ ] Abgeleitete Aggregate werden vom Backend verwaltet oder automatisiert
  gegen die Source Data abgeglichen.
- [ ] Firestore-Regeln validieren jedes Collection-Schema und jeden Uebergang.
- [ ] Anonyme Benutzer haben einen getesteten Verknuepfungs-, Export- und
  Wiederherstellungspfad.
- [ ] Der Sign-out loescht Firebase und native Ownership auch unter
  Fehlerbedingungen.
- [ ] Notification-Daten sind vom Backup ausgeschlossen, verschluesselt,
  geschwaerzt und laufen ab.
- [ ] Fehlerhafte Datensaetze erzeugen eine sichtbare Reconciliation-Warnung
  statt eines leeren oder fehlgeschlagenen Ledgers.
- [ ] Kritische Repositories und native Grenzen haben Integrationstests.
- [ ] CI fuehrt jede finanzielle, Firebase-, native, Backup- und
  Migrations-Suite aus.
- [ ] Release-Artefakte werden mit gepinntem Tooling gebaut und gemeinsam
  veroeffentlicht.
- [ ] Accessibility-Tests decken Touch Targets, TalkBack und grosse Schrift ab.

| Release | Review-Datum | Freigegeben von | Evidenz | Ergebnis |
|---|---|---|---|---|
|  |  |  |  | Offen |