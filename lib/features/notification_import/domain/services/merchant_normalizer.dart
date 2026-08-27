/// Produces a stable value for exact merchant-category rule lookups.
class MerchantNormalizer {
  const MerchantNormalizer();

  String normalize(String merchant) {
    return merchant.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
