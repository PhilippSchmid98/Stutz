// Datei: test/helpers/test_data.dart
//
// Factory helpers for creating domain model instances in tests.
// Use named parameters to override only what a specific test needs.

import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';

IncomeSource makeIncome({
  String id = 'i1',
  String name = 'Salary',
  double amount = 5000,
  PaymentInterval interval = PaymentInterval.monthly,
  IncomeGroup group = IncomeGroup.main,
}) {
  return IncomeSource(
    id: id,
    name: name,
    amount: amount,
    interval: interval,
    group: group,
  );
}

ExpenseNode makeExpense({
  String id = 'e1',
  String? parentId,
  String name = 'Groceries',
  double? plannedAmount = 300,
  ExpenseType? type = ExpenseType.variable,
  PaymentInterval? interval = PaymentInterval.monthly,
  List<ExpenseNode> children = const [],
  int sortOrder = 0,
}) {
  return ExpenseNode(
    id: id,
    parentId: parentId,
    name: name,
    plannedAmount: plannedAmount,
    type: type,
    interval: interval,
    children: children,
    sortOrder: sortOrder,
  );
}

AppTransaction makeTransaction({
  String id = 't1',
  String expenseNodeId = 'e1',
  double amount = 50,
  DateTime? dateTime,
  String? note,
}) {
  return AppTransaction(
    id: id,
    expenseNodeId: expenseNodeId,
    amount: amount,
    dateTime: dateTime ?? DateTime(2025, 6, 15),
    note: note,
  );
}
