# Stutz: Checkliste zur Umsetzung des Application Audits

**Grundlage:** [Application Audit vom 10. September 2026](application-audit-2026-09-10.de.md)  
**Zweck:** Fortschritt, Nachweise und Release-Freigabe für die im Audit priorisierten Verbesserungen nachvollziehbar dokumentieren.  
**Letzte Aktualisierung:** 13. Oktober 2026

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
| Prioritaet 1: Konto und Notification Privacy | 100 % | Erledigt | 30.09.2026 |  |  |  |
| Prioritaet 2: Ganzzahliges Money-Schema | 100 % | Erledigt | 13.10.2026 |  |  |  |
| Prioritaet 3: Trusted Write-Boundary | 33 % | In Arbeit | 13.10.2026 |  |  | Architekturentscheidung, Regeln, Kategoriearchivierung und Emulator-Abnahme stehen aus. |
| Prioritaet 4: Anonyme Konten und Sign-out | 100 % | Erledigt | 30.09.2026 |  |  |  |
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
| P1-01 | Native Ownership bei Sign-out und Auth-State `null` bereinigen. | 100 % | Erledigt |  |  | 30.09.2026 |  | Commit `05ce662`; [P1-Abnahmenachweis](p1-notification-privacy-evidence-2026-09-30.de.md). |
| P1-02 | Race verhindern, bei dem ein alter Sync einen veralteten Owner setzt. | 100 % | Erledigt |  |  | 30.09.2026 |  | Abbruchtest in der Dart-Synchronisationssuite; [P1-Abnahmenachweis](p1-notification-privacy-evidence-2026-09-30.de.md). |
| P1-03 | Zahlungsinhalte aus nativen Debug-Logs entfernen oder schwaerzen. | 100 % | Erledigt |  |  | 30.09.2026 |  | Sentinel-Logtest und statischer Review; [P1-Abnahmenachweis](p1-notification-privacy-evidence-2026-09-30.de.md). |
| P1-04 | Queue und Owner-Preferences vom Android-Backup ausschliessen. | 100 % | Erledigt |  |  | 30.09.2026 |  | Debug-/Release-Manifest und Backup-Regeln geprueft; [P1-Abnahmenachweis](p1-notification-privacy-evidence-2026-09-30.de.md). |
| P1-05 | Globale Deduplizierungsbeschraenkung entfernen und Owner-Isolation sichern. | 100 % | Erledigt |  |  | 30.09.2026 |  | Schema-v3-Migration und Owner-Deduplizierung getestet; [P1-Abnahmenachweis](p1-notification-privacy-evidence-2026-09-30.de.md). |
| P1-06 | Owner-Wechsel- und Capture-im-abgemeldeten-Zustand-Tests liefern. | 100 % | Erledigt |  |  | 30.09.2026 |  | 4 Dart- und 11 Android-Tests bestanden; [P1-Abnahmenachweis](p1-notification-privacy-evidence-2026-09-30.de.md). |

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
- [x] Android-Backup-Inspektion dokumentiert, dass Queue- und Owner-Daten
  nicht enthalten sind.
- [x] Debug-Log-Review dokumentiert, dass keine Zahlungsinhalte ausgegeben
  werden.

### Abnahme

- [x] Keine Notification-Queue existiert im abgemeldeten Zustand.
- [x] Kein Draft von Owner A ist fuer Owner B lesbar oder hochladbar.
- [x] Backup und Logs erfuellen die Privacy-Anforderungen.
- [x] Implementierungscommit, Testergebnisse und Abnahmenachweis sind
  verlinkt.

**Evidenz / Entscheidung / Rest-Risiko:** Prioritaet 1 wurde am 30.09.2026
abgenommen. `flutter analyze`, die fokussierte Dart-Synchronisationssuite
(4 Tests), die vollstaendige Android-JVM-Suite (11 Tests), der
Sentinel-Logtest sowie die frisch erzeugten Debug- und Release-Manifeste
bestanden. Details und die Grenze der geraetelosen Abnahme stehen im
[P1-Abnahmenachweis](p1-notification-privacy-evidence-2026-09-30.de.md).
Verschluesselung und Retention quittierter Queue-Zeilen sind nicht Bestandteil
von Prioritaet 1 und verbleiben im sekundaeren Backlog.

---

## Prioritaet 2: Ganzzahliges Money-Schema definieren und migrieren

**Ziel:** Geld wird vom UI bis zu Firestore-Aggregaten ausschliesslich in
ganzzahligen Minor Units verarbeitet; historische Daten werden verifizierbar
migriert.

### Fortschrittsboard

| ID | Arbeitspaket | Fortschritt | Status | Verantwortlich | Zieldatum | Letzte Aktualisierung | Naechster Schritt | Evidenz / PR / Blocker |
|---|---|---:|---|---|---|---|---|---|
| P2-01 | CHF-Minor-Unit- und Jahresumlage-Regeln dokumentieren. | 100 % | Erledigt |  |  | 09.10.2026 |  | [Money-Schema](money-schema.de.md). |
| P2-02 | Persistierte, Quell- und Aggregat-Finanzfelder auf Ganzzahlen migrieren. | 100 % | Erledigt |  |  | 13.10.2026 |  | Produktiv migriert; Post-Migrations-Backup und leerer Verifikations-Dry-Run abgenommen. |
| P2-03 | Striktes Direkt-zu-Minor-Unit-Parsing implementieren. | 100 % | Erledigt |  |  | 09.10.2026 |  | Parser, Formatter, Formulare und Grenzwerttests umgestellt. |
| P2-04 | Dry-Run-Migration mit Validierung und Abweichungsreport bereitstellen. | 100 % | Erledigt |  |  | 09.10.2026 |  | `migrate:money-minor-units`; 13 Unit- und 1 Emulator-Test bestanden. |
| P2-05 | Summen aus Quelltransaktionen neu aufbauen. | 100 % | Erledigt |  |  | 09.10.2026 |  | Integer-Summary-Rebuild, Legacy-Cleanup und leere Wiederholung getestet. |
| P2-06 | Prae-/Post-Summen je Benutzer gegen verifiziertes Backup abgleichen. | 100 % | Erledigt |  |  | 13.10.2026 |  | 531 Quellen, 0 Wert- und 0 Summary-Abweichungen; alle 5 Migrationsmarker gueltig. |

### Umsetzung

- [x] CHF-Minor-Unit-Regeln, erlaubte Praezision und Rundung dokumentieren.
- [x] Regeln fuer Jahresumlagen und deren Rundung dokumentieren.
- [x] Persistierte Finanzfelder auf Ganzzahlen umstellen.
- [x] Quellmodelle und Domain-Modelle auf Ganzzahlen umstellen.
- [x] Aggregat- und Summary-Felder auf Ganzzahlen umstellen.
- [x] Direkt-zu-Minor-Unit-Parsing fuer Eingaben implementieren.
- [x] Eingaben mit mehr als zwei Dezimalstellen, ungueltiger Syntax oder
  nicht positiven Betraegen ablehnen.
- [x] Dry-Run-Migration mit Validierung und Abweichungsbericht bauen.
- [x] Monatssummen aus den Quelltransaktionen neu aufbauen.
- [x] Prae-/Post-Summen je Benutzer aus einem verifizierten Backup abgleichen.

### Tests und Nachweise

- [x] Unit-Tests fuer Parsing, Rundung und Grenzwerte ergaenzen.
- [x] Migrations-Dry-Run gegen eine repraesentative Emulator-Kopie ausfuehren.
- [x] Emulator-Reconciliation-Report mit Anzahl, Summe und Abweichungen je Benutzer
  abnehmen.
- [x] Wiederholung des Dry-Runs liefert dasselbe Ergebnis oder einen
  explizit leeren Delta-Report.
- [x] Firestore-Emulator-Stichprobe bestaetigt, dass persistiertes Geld keine
  `double`-Werte mehr enthaelt.

### Abnahme

- [x] Persistiertes Geld enthaelt keine `double`-Werte.
- [x] Jede Monatssumme entspricht exakt der Reduktion ihrer
  Quelltransaktionen.
- [x] Die Migration ist wiederholbar und ihr Reconciliation-Report ist
  abgenommen.
- [x] Produktionsmigration, Backup-Integritaetspruefung, Apply und
  Post-Apply-Verifikation sind dokumentiert.

**Evidenz / Entscheidung / Rest-Risiko:** App-Domain, Formulare, Mapper,
Repositories und Aggregationen verwenden ganzzahlige Rappen. Legacy-Felder
werden nur gelesen und bei jedem Write entfernt. Jahreswerte bleiben exakt;
monatliche Schaetzungen werden nach Aggregation half-away-from-zero gerundet.
Die Migrationssuite bestand mit 13 Unit-Tests und einem All-Scope-
Emulator-End-to-End-Test inklusive Backup-Verifikation, Reconciliation und
leerem Folgeplan. Die Produktionsmigration vom 13.10.2026 lief mit 5 Nutzern,
531 Transaktionen, 14 Monaten und 0 Rundungsanpassungen durch. Der anschliessende
Dry-Run enthielt 0 Restoperationen. Der Vergleich des Prae- mit dem
Post-Migrations-Backup bestaetigte 0 Wert- und Summary-Abweichungen sowie
gueltige Migrationsmarker fuer alle 5 Nutzer.

---

## Prioritaet 3: Vertrauenswuerdige Transaktions-Write-Boundary

**Ziel:** Transaktionen bleiben die auditierbare Source of Truth; Replays,
Kollisionen und manipulierte Client-Writes koennen Ledger-Summen nicht
korrumpieren.

### Fortschrittsboard

| ID | Arbeitspaket | Fortschritt | Status | Verantwortlich | Zieldatum | Letzte Aktualisierung | Naechster Schritt | Evidenz / PR / Blocker |
|---|---|---:|---|---|---|---|---|---|
| P3-01 | Write-Architektur: Backend-Summen oder quellenbasierte Client-Writes entscheiden. | 0 % | Nicht begonnen |  |  | 16.09.2026 |  |  |
| P3-02 | Manuelles Anlegen idempotent machen. | 100 % | Bereit zur Pruefung |  |  | 13.10.2026 | Gesamtvalidierung und Review. | Repository-Test: identischer Replay ist ein No-op ohne Summary-Delta. |
| P3-03 | ID-Kollisionen und unzulaessige Ersetzungen ablehnen. | 100 % | Bereit zur Pruefung |  |  | 13.10.2026 | Gesamtvalidierung und Review. | Repository-Test: abweichender Replay wirft und bewahrt Quelle sowie Summary. |
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

- [x] Manuelles Anlegen einer Transaktion idempotent machen.
- [x] Replays mit gleicher Command-/Transaktions-ID erkennen.
- [x] ID-Kollisionen und unzulaessige Ersetzungen explizit ablehnen.
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
| P4-01 | Anonyme Benutzer vor Sign-out erkennen. | 100 % | Erledigt |  |  | 30.09.2026 |  | Reaktiver Account-Status und geschuetzter Logout-Button; Widgettests bestanden. |
| P4-02 | Google-Credential-Verknuepfung mit UID-Erhalt implementieren. | 100 % | Erledigt |  |  | 30.09.2026 |  | `linkWithCredential`, UID-Pruefung und erneute Account-Auswahl implementiert. |
| P4-03 | Verlustwarnung und Recovery-Entscheidung ohne Export umsetzen. | 100 % | Erledigt |  |  | 30.09.2026 |  | [Richtlinie fuer anonyme Konten](anonymous-account-policy.de.md); kein Export oder Merge. |
| P4-04 | Firebase-Sign-out bei Fehler der Google-Bereinigung garantieren. | 100 % | Erledigt |  |  | 30.09.2026 |  | Google-Fehler wird geschwaerzt; Firebase wird immer versucht; 6 fokussierte Auth-Tests bestanden. |
| P4-05 | Native Owner-Bereinigung in den sichtbaren Sign-out integrieren. | 100 % | Erledigt |  |  | 30.09.2026 |  | Owner-Cleanup vor Auth-Sign-out und Auth-Null-Fallback; [P1-Abnahmenachweis](p1-notification-privacy-evidence-2026-09-30.de.md). |
| P4-06 | Kollisionen und Fehlerpfade testen. | 100 % | Erledigt |  |  | 30.09.2026 |  | UID-Erhalt, Abbruch, Kollision, alternatives Konto, Cleanup- und Retry-Pfade getestet. |

### Umsetzung

- [x] Anonyme Benutzer vor einer Abmeldung erkennen.
- [x] Google-Credential-Verknuepfung implementieren, die die bestehende UID
  beibehält.
- [x] Explizite Warnung vor dauerhaftem Datenverlust fuer nicht verknuepfte
  anonyme Konten implementieren.
- [x] Produktentscheidung dokumentieren: kein Export, kein automatischer
  Kontowechsel und kein Ledger-Merge.
- [x] Firebase-Sign-out garantieren, auch wenn die Google-Bereinigung
  fehlschlaegt.
- [x] Native Owner-Bereinigung in denselben sichtbaren Sign-out-Vorgang
  integrieren.

### Tests und Nachweise

- [x] Test: Google-Verknuepfung bewahrt UID und Ledger-Zugriff.
- [x] Test: Credential-Kollision wird eindeutig behandelt und kommuniziert.
- [x] Test: Fehler bei Google-Sign-out verhindert Firebase-Sign-out nicht.
- [x] Test: Fehlerpfad bereinigt nativen Owner und hinterlaesst keinen
  eingeloggten Firebase-State.
- [x] UX-Tests bestaetigen Verlustwarnung, Abbruch, bewusste Abmeldung und
  Google-Sicherung ohne Exportangebot.

### Abnahme

- [x] Ein Benutzer kann nicht versehentlich ein anonymes Ledger aufgeben.
- [x] Der Sign-out schliesst die Firebase-Session immer, wenn Firebase
  verfuegbar ist.
- [x] Die native Owner-Bereinigung ist Teil desselben sichtbaren Vorgangs.
- [x] Fehlerpfade, UX-Entscheidung und Testnachweise sind dokumentiert.

**Evidenz / Entscheidung / Rest-Risiko:** `AuthSignOutCoordinator` behandelt
die Google-Bereinigung als Best Effort, protokolliert nur eine geschwaerzte
Diagnose und ruft anschliessend immer Firebase-Sign-out auf. Ein
Firebase-Fehler bleibt fuer den Aufrufer sichtbar. `AuthController` bereinigt
den nativen Owner zuerst; ein nativer Cleanup-Fehler blockiert den
Firebase-Sign-out nicht, und bei einem Firebase-Fehler wird der freiwillige
Sign-out-Marker zurueckgesetzt. Drei Service- und drei Controller-Tests
bestanden am 30.09.2026. Der anonyme Logout erkennt den Account-Typ, warnt vor
Zugriffsverlust und bietet Google-Sicherung, bewusste Abmeldung oder Abbruch.
`linkWithCredential` muss dieselbe UID liefern. Bei
`credential-already-in-use` bleibt das Gastkonto aktiv; erlaubt sind nur ein
anderes Google-Konto oder Abbruch. Die Service-, Controller- und Widgettests
decken UID-Erhalt, Picker-Abbruch, Kollision, erneute Auswahl und Retry ab.
Gemäss [Richtlinie fuer anonyme Konten](anonymous-account-policy.de.md) gibt es
bewusst keinen Export, keinen automatischen Kontowechsel und keinen Merge.

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
| 9 | Veralteten Sync-Code und ungenutzte direkte JSON-Codegen-Dependencies entfernen. | Erledigt |  | Bereinigung abgeschlossen; kein weiterer Refactoring-Arbeitsstrang offen. |
| 10 | Grosse Kategoriebäume profilieren, dann ueber Sliver-Neufassung entscheiden. | Nicht begonnen |  |  |

---

## Finance-Grade Release-Gate

Diese Liste ist die finale Freigabepruefung. Sie wird erst als bestanden
markiert, wenn alle Nachweise aus den priorisierten Arbeitsstroemen in einem
Release-Review vorliegen.

- [x] Alles persistierte Geld verwendet ganzzahlige Minor Units mit
  dokumentierter Rundung.
- [ ] Jeder Transaktionsbefehl ist idempotent.
- [ ] Abgeleitete Aggregate werden vom Backend verwaltet oder automatisiert
  gegen die Source Data abgeglichen.
- [ ] Firestore-Regeln validieren jedes Collection-Schema und jeden Uebergang.
- [x] Anonyme Benutzer haben einen getesteten Verknuepfungs- und Warnpfad;
  der bewusste Verzicht auf Export und nachtraegliche Wiederherstellung ist
  dokumentiert.
- [x] Der Sign-out loescht Firebase und native Ownership auch unter
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