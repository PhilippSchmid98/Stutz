import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/notification_import/domain/services/merchant_category_rule_id.dart';

void main() {
  test('merchant rule IDs are deterministic and Firestore-path safe', () {
    final id = merchantCategoryRuleId('muller / cafe');

    expect(id, merchantCategoryRuleId('muller / cafe'));
    expect(id, isNot(contains('/')));
  });
}
