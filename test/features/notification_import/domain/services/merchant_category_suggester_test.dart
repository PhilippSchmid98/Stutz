import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/notification_import/domain/entities/merchant_category_rule.dart';
import 'package:stutz/features/notification_import/domain/services/merchant_category_suggester.dart';
import 'package:stutz/features/notification_import/domain/services/merchant_category_rule_id.dart';
import 'package:stutz/features/notification_import/domain/services/merchant_normalizer.dart';

void main() {
  const normalizer = MerchantNormalizer();
  const suggester = MerchantCategorySuggester();

  group('MerchantNormalizer', () {
    test('trims, case-normalizes, and collapses whitespace', () {
      expect(normalizer.normalize('  COOP\n  Pronto  '), 'coop pronto');
    });
  });

  group('MerchantCategorySuggester', () {
    const rules = [
      MerchantCategoryRule(
        normalizedMerchant: 'coop pronto',
        categoryId: 'groceries',
      ),
    ];

    test('returns the explicitly confirmed exact merchant category', () {
      expect(
        suggester.suggestCategoryId(merchant: 'Coop  Pronto', rules: rules),
        'groceries',
      );
    });

    test('does not guess from a similar merchant name', () {
      expect(
        suggester.suggestCategoryId(merchant: 'Coop Pronto AG', rules: rules),
        isNull,
      );
    });

    test('does not suggest a category for an empty merchant', () {
      expect(
        suggester.suggestCategoryId(merchant: '   ', rules: rules),
        isNull,
      );
    });
  });

  test('merchant rule IDs are deterministic and Firestore-path safe', () {
    final id = merchantCategoryRuleId('muller / cafe');

    expect(id, merchantCategoryRuleId('muller / cafe'));
    expect(id, isNot(contains('/')));
  });
}
