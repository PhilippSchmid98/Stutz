import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/data/expense_node_mapper.dart';
import 'package:stutz/features/budget/data/income_source_mapper.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

void main() {
  test('expense node mapper converts a flat document payload', () {
    final node = ExpenseNodeMapper.fromData('node-1', {
      'parentId': 'root',
      'name': 'Food',
      'plannedAmount': 250,
      'interval': 'monthly',
      'type': 'variable',
      'sortOrder': 2,
    });

    expect(node.id, 'node-1');
    expect(node.parentId, 'root');
    expect(node.plannedAmount, 250);
    expect(node.interval, PaymentInterval.monthly);
    expect(node.type, ExpenseType.variable);
    expect(ExpenseNodeMapper.toDocument(node)['children'], isNull);
  });

  test('income mapper rejects a malformed amount', () {
    expect(
      () => IncomeSourceMapper.fromData('income-1', {'amount': 'not-a-number'}),
      throwsFormatException,
    );
  });

  test('income mapper preserves supported enum values', () {
    final income = IncomeSourceMapper.fromData('income-1', {
      'name': 'Bonus',
      'amount': 1200,
      'interval': 'yearly',
      'group': 'additional',
    });

    expect(income.interval, PaymentInterval.yearly);
    expect(income.group, IncomeGroup.additional);
    expect(IncomeSourceMapper.toDocument(income)['amount'], 1200);
  });
}
