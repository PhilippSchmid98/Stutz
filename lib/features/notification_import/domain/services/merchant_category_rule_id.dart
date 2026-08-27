import 'dart:convert';

/// Creates a Firestore-safe deterministic ID for an exact merchant rule.
String merchantCategoryRuleId(String normalizedMerchant) {
  return base64Url.encode(utf8.encode(normalizedMerchant)).replaceAll('=', '');
}
