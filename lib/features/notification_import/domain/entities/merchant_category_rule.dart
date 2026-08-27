/// A category selected explicitly by the user for a normalized merchant name.
class MerchantCategoryRule {
  final String normalizedMerchant;
  final String categoryId;
  final int confirmationCount;

  const MerchantCategoryRule({
    required this.normalizedMerchant,
    required this.categoryId,
    this.confirmationCount = 1,
  }) : assert(normalizedMerchant != ''),
       assert(categoryId != ''),
       assert(confirmationCount > 0);
}
