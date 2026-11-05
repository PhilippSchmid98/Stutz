# Ganzzahliges Money-Schema

Stand: 9. Oktober 2026

## Einheit und Grenzen

Alle CHF-Werte werden als ganzzahlige Rappen gespeichert und verarbeitet.
`1` entspricht CHF 0.01, `100` entspricht CHF 1.00. Der maximale App-Wert ist
`99.999.999.999` Rappen beziehungsweise CHF 999.999.999.99.

Quellwerte wie Transaktionen, Einkommen und geplante Ausgaben muessen positiv
sein. Abgeleitete Summen koennen intern null sein; Kategorien mit einer
Summe kleiner oder gleich null werden aus der Summary-Map entfernt.

## Eingabe und Anzeige

Eingaben werden direkt aus Text in Rappen geparst. Erlaubt sind ganze Franken
oder eine beziehungsweise zwei Dezimalstellen mit Punkt oder Komma. Mehr als
zwei Dezimalstellen, Vorzeichen, nicht positive Werte und Ueberlaeufe werden
abgelehnt. Es findet bei Benutzereingaben keine stille Rundung statt.

Die Anzeige formatiert Integerwerte direkt und konvertiert Geld nie ueber
`double`.

## Jahreswerte

Jahreswerte bleiben exakt als Jahres-Rappenbetrag erhalten. Fuer eine
monatliche Schaetzung werden zuerst alle Jahreswerte des betreffenden Buckets
addiert und danach durch 12 geteilt. Nicht teilbare Rappen werden auf den
naechsten Rappen gerundet; exakt halbe Werte werden von null weg gerundet.
Die monatliche Schaetzung wird nicht persistiert.

## Firestore-Schema

| Collection | Kanonisches Feld |
|---|---|
| `transactions` | `amountMinor: int` |
| `expense_nodes` | `plannedAmountMinor: int?` |
| `incomes` | `amountMinor: int` |
| `transactionMonths` | `categoryTotalsMinor: Map<String, int>` |

Die App liest waehrend des Cutovers weiterhin die alten Felder `amount`,
`plannedAmount` und `categoryTotals`. Neue Writes enthalten ausschliesslich
die kanonischen Integerfelder und entfernen vorhandene Legacy-Felder.

## Legacy-Konvertierung

Legacy-Frankenwerte werden mit `round(value * 100)` in Rappen umgerechnet.
Jede dadurch entstehende Abweichung wird mit Dokumentpfad im
Reconciliation-Report aufgefuehrt. Nicht endliche, negative, fehlende oder
ausserhalb des Wertebereichs liegende Werte stoppen die Migration fuer den
betroffenen Benutzer, bevor dessen Daten geschrieben werden.

`transactionMonths` werden nie aus den bestehenden Summen konvertiert. Sie
werden vollstaendig aus den normalisierten Transaktionsdokumenten neu
aufgebaut.

## Cutover und Rollback

1. Alte schreibende App-Versionen stoppen oder ein erzwungenes Update
   durchsetzen.
2. Ein verifiziertes `scope=all`-Backup ausserhalb des Repositories erstellen.
3. Dry-Run mit Reconciliation-Report ausfuehren und Abweichungen pruefen.
4. Migration mit `--apply` ausfuehren.
5. Der automatische Post-Apply-Check muss einen leeren Operationsplan liefern.
6. Firestore-Stichproben und App-Smoke-Test durchfuehren.
7. Bei einer Abweichung Writes stoppen und das All-Scope-Backup wiederherstellen.

Die Migration ist wiederholbar. Bereits kanonische Dokumente und korrekte
Summaries erzeugen keine weiteren Operationen.