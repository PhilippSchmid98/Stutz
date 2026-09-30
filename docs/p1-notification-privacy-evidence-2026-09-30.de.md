# P1-Abnahmenachweis: Konto und Notification Privacy

Abnahme: 30. September 2026

## Umfang

Dieser Nachweis schliesst Prioritaet 1 der
[Application-Audit-Checkliste](application-audit-improvement-checklist.de.md)
ab. Geprueft wurden Owner-Lifecycle, Owner-Isolation, der Abbruch veralteter
Synchronisierungen, Android-Backup-Konfiguration und natives Logging im
Notification-Capture-Pfad.

Die zugrunde liegende Implementierung wurde mit Commit
`05ce6628bdd2e65dff09572b8fdaa8fbc72fbdcd` eingefuehrt. Die automatisierten
Privacy-Abnahmetests wurden am 30.09.2026 ergaenzt.

## Backup-Abnahme

Die von Gradle frisch erzeugten Debug- und Release-Manifeste wurden nach
`app:processDebugManifest app:processReleaseManifest` geprueft. Beide Varianten
enthalten:

```text
allowBackup=false
fullBackupContent=@xml/backup_rules
dataExtractionRules=@xml/data_extraction_rules
```

`NotificationPrivacyTest` prueft zusaetzlich:

- `FLAG_ALLOW_BACKUP` ist im Android-Laufzeitmodell nicht gesetzt;
- das Manifest verweist auf beide Regeldateien;
- `backup_rules.xml` schliesst `notification_capture.db` und
  `notification_capture.xml` aus;
- `data_extraction_rules.xml` schliesst beide Dateien sowohl von Cloud-Backups
  als auch von Device-Transfers aus.

Damit ist Backup fail-closed deaktiviert. Die zusaetzlichen Ausschlussregeln
bleiben als Defense in Depth aktiv. Ein physisches Android-Geraet war bei der
Abnahme nicht verbunden; statt eines geraetespezifischen Backup-Archivs wurden
die effektiven Debug- und Release-Build-Manifeste sowie die kompilierten
Android-Ressourcen geprueft.

## Log-Abnahme

`NotificationPrivacyTest` fuehrt den nativen
`GoogleWalletNotificationListener` mit eindeutigen Sentinel-Werten fuer
Haendler, Betrag, Kartenbezeichnung und Notification-Key aus. Anschliessend
wird der komplette von Robolectric erfasste Android-Logpuffer geprueft. Keiner
der Sentinel-Werte wird ausgegeben.

Eine statische Suche im nativen Produktionscode fand keine Payment-Logs. Die
verbleibenden `Log.e`-Aufrufe liegen im generierten Flutter-Plugin-Registrant
und melden ausschliesslich Fehler bei der Plugin-Registrierung.

## Testergebnisse

| Check | Ergebnis |
|---|---|
| `flutter analyze` | Bestanden, keine Diagnosen. |
| Fokussierte Dart-Synchronisationssuite | 4 bestanden, 0 fehlgeschlagen. |
| `android\\gradlew.bat -p android app:testDebugUnitTest` | 11 bestanden, 0 fehlgeschlagen. |
| `NotificationCaptureQueueTest` | 4 bestanden, 0 fehlgeschlagen. |
| `GoogleWalletNotificationParserTest` | 5 bestanden, 0 fehlgeschlagen. |
| `NotificationPrivacyTest` | 2 bestanden, 0 fehlgeschlagen. |
| Debug-/Release-Manifest-Merge | Bestanden; Backup in beiden Varianten deaktiviert. |

## Entscheidung und Restrisiko

Prioritaet 1 ist abgenommen. Die Queue nimmt ohne aktiven Owner keine Drafts
an, Sign-out loescht Owner und dessen Queue, Owner-spezifische
Deduplizierung ist migriert, ein abgebrochener alter Sync kann keinen
veralteten Owner wiederherstellen, Backup ist deaktiviert und der native
Capture-Pfad loggt keine Zahlungsinhalte.

Nicht Teil von Prioritaet 1 sind die Verschluesselung der verbleibenden
SQLite-Queue und die automatische Loeschung quittierter Zeilen. Beide Punkte
bleiben im sekundaeren Verbesserungs-Backlog offen. Der kombinierte
Finance-Grade-Gate-Punkt fuer Backup, Verschluesselung, Schwaerzung und
Retention bleibt deshalb ungeprueft.