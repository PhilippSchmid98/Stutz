import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/transactions/domain/entities/transaction_month_summary.dart';

import '../../../../helpers/test_data.dart';

void main() {
  test('combines deltas when an edit stays in the same category', () {
    final deltas = categoryDeltasForTransactionUpdate(
      makeTransaction(expenseNodeId: 'groceries', amount: 80),
      makeTransaction(expenseNodeId: 'groceries', amount: 125),
    );

    expect(deltas, {'groceries': 45.0});
  });

  test(
    'reverses the old category and adds the new category on recategorizing',
    () {
      final deltas = categoryDeltasForTransactionUpdate(
        makeTransaction(expenseNodeId: 'groceries', amount: 80),
        makeTransaction(expenseNodeId: 'tech', amount: 125),
      );

      expect(deltas, {'groceries': -80.0, 'tech': 125.0});
    },
  );
}
