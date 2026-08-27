import 'package:stutz/features/notification_import/domain/entities/merchant_category_rule.dart';
import 'package:stutz/features/notification_import/domain/services/merchant_normalizer.dart';

/// Suggests only categories explicitly confirmed for the same merchant.
class MerchantCategorySuggester {
  final MerchantNormalizer _normalizer;

  const MerchantCategorySuggester({
    MerchantNormalizer normalizer = const MerchantNormalizer(),
  }) : _normalizer = normalizer;

  String? suggestCategoryId({
    required String merchant,
    required Iterable<MerchantCategoryRule> rules,
  }) {
    final normalizedMerchant = _normalizer.normalize(merchant);
    if (normalizedMerchant.isEmpty) return null;

    for (final rule in rules) {
      if (rule.normalizedMerchant == normalizedMerchant) {
        return rule.categoryId;
      }
    }
    return null;
  }
}
