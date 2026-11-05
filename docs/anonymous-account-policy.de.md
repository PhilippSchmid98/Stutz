# Richtlinie fuer anonyme Konten

Stand: 30. September 2026

## Zweck

Anonyme Firebase-Konten sind temporaere Gastkonten. Ihre Daten sind an eine
Firebase-UID gebunden, fuer die der Benutzer keine wiederverwendbaren
Anmeldedaten besitzt. Eine Abmeldung oder Neuinstallation kann den Zugriff auf
diese UID deshalb dauerhaft beenden.

## Schutz vor der Abmeldung

Vor der Abmeldung eines Gastkontos zeigt Stutz eine Verlustwarnung mit genau
drei Entscheidungen:

1. **Mit Google sichern und abmelden:** Das Google-Credential wird mit
   `linkWithCredential` an das bestehende Gastkonto gebunden. Die Firebase-UID
   und damit das Ledger bleiben unveraendert. Erst danach wird abgemeldet.
2. **Trotzdem abmelden:** Der Benutzer bestaetigt den moeglichen dauerhaften
   Zugriffsverlust und wird ohne Kontoverknuepfung abgemeldet.
3. **Abbrechen:** Der Benutzer bleibt mit dem Gastkonto angemeldet.

## Bereits verwendetes Google-Konto

Ist das gewaehlte Google-Credential bereits mit einem anderen Firebase-Konto
verknuepft, wechselt Stutz nicht zu diesem Konto und fuehrt keinen automatischen
Ledger-Merge aus. Das Gastkonto bleibt aktiv und unveraendert. Angeboten werden
ausschliesslich:

- ein anderes Google-Konto auswaehlen;
- den Vorgang abbrechen.

## Kein Export oder nachtraeglicher Recovery-Pfad

Stutz bietet fuer diesen Ablauf keinen Export und keine Wiederherstellung eines
aufgegebenen Gastkontos an. Die administrativen Firestore-Backup-Werkzeuge sind
kein Benutzerexport und werden in der App nicht angeboten.

Eine Abmeldung loescht die Firestore-Dokumente des Gastkontos nicht automatisch.
Ohne die zugehoerige Firebase-Session oder eine vorherige Google-Verknuepfung
existiert jedoch kein unterstuetzter Weg, den Zugriff wiederherzustellen. Auch
der Support kann eine verlorene anonyme UID nicht einem neuen Konto zuordnen.

## Fehlerverhalten

- Ein abgebrochener Google-Picker veraendert das Gastkonto nicht.
- Ein Link- oder Kollisionsfehler meldet den Benutzer nicht ab.
- Ein fehlgeschlagener Firebase-Sign-out laesst die Session aktiv und kann
  erneut versucht werden.
- Native Owner-Bereinigung und Google-Cleanup duerfen den entscheidenden
  Firebase-Sign-out nicht blockieren.