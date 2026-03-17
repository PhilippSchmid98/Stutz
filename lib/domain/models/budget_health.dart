import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_health.freezed.dart';

/// Summary of the user's financial health: income vs. planned expenses.
@freezed
abstract class BudgetHealth with _$BudgetHealth {
  const BudgetHealth._();

  const factory BudgetHealth({
    required double income,
    required double expenses,
  }) = _BudgetHealth;

  double get balance => income - expenses;
  bool get isDeficit => balance < 0;
}
