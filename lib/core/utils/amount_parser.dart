double? parsePositiveAmount(String value) {
  final amount = double.tryParse(value.trim().replaceAll(',', '.'));
  if (amount == null || !amount.isFinite || amount <= 0) return null;
  return amount;
}

String? positiveAmountValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Pflichtfeld';
  return parsePositiveAmount(value) == null
      ? 'Bitte einen gültigen Betrag eingeben'
      : null;
}
