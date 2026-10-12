// Factory helpers for creating domain model instances in tests.
// Use named parameters to override only what a specific test needs.

import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

IncomeSource makeIncome({
  String id = 'i1',
  String name = 'Salary',
  int amountMinor = 5000,
  PaymentInterval interval = PaymentInterval.monthly,
  IncomeGroup group = IncomeGroup.main,
}) {
  return IncomeSource(
    id: id,
    name: name,
    amountMinor: amountMinor,
    interval: interval,
    group: group,
  );
}

ExpenseNode makeExpense({
  String id = 'e1',
  String? parentId,
  String name = 'Groceries',
  int? plannedAmountMinor = 300,
  ExpenseType? type = ExpenseType.variable,
  PaymentInterval? interval = PaymentInterval.monthly,
  List<ExpenseNode> children = const [],
  int sortOrder = 0,
}) {
  return ExpenseNode(
    id: id,
    parentId: parentId,
    name: name,
    plannedAmountMinor: plannedAmountMinor,
    type: type,
    interval: interval,
    children: children,
    sortOrder: sortOrder,
  );
}

AppTransaction makeTransaction({
  String id = 't1',
  String expenseNodeId = 'e1',
  int amountMinor = 50,
  DateTime? dateTime,
  String? note,
}) {
  return AppTransaction(
    id: id,
    expenseNodeId: expenseNodeId,
    amountMinor: amountMinor,
    dateTime: dateTime ?? DateTime(2025, 6, 15),
    note: note,
  );
}
