import 'package:stutz/domain/models/models.dart';

extension IncomeLogic on IncomeSource {
  /// Gibt den monatlichen Betrag zurück.
  /// Rechnet 'Yearly' Beträge automatisch durch 12.
  double get monthlyAmount {
    if (interval == 'Yearly') {
      return amount / 12;
    }
    // Gehe von 'Monthly' aus (oder Fallback)
    return amount;
  }
}

extension ExpenseLogic on ExpenseNode {
  /// Berechnet rekursiv die monatlichen Gesamtkosten für diesen Knoten
  /// inklusive aller Unterkategorien (Kinder).
  double get totalMonthlyCalculated {
    // 1. Eigener Betrag (umgerechnet auf Monat)
    // FALL 1: Es ist eine Gruppe (hat Kinder)
    if (isGroup) {
      return children.fold<double>(
        0.0,
        (sum, child) => sum + child.totalMonthlyCalculated,
      );
    }

    // FALL 2: Es ist ein Blatt (keine Kinder) -> Berechne eigenen Wert
    // Falls plannedAmount null ist (sollte bei Blatt nicht passieren, aber sicher ist sicher), nimm 0.0
    final amount = plannedAmount ?? 0.0;

    if (interval == 'Yearly') {
      return amount / 12;
    }
    return amount;
  }
}
