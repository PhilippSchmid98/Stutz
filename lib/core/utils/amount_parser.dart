double? parsePositiveAmount(String value) {
  final amount = double.tryParse(value.trim().replaceAll(',', '.'));
  if (amount == null || !amount.isFinite || amount <= 0) return null;
  return amount;
}
