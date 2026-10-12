const int maxMoneyMinorUnits = 99999999999;

final _positiveMoneyPattern = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$');

int? parsePositiveMinorUnits(String value) {
  final match = _positiveMoneyPattern.firstMatch(value.trim());
  if (match == null) return null;

  final major = BigInt.tryParse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  final minor = BigInt.tryParse(fraction);
  if (major == null || minor == null) return null;

  final total = major * BigInt.from(100) + minor;
  if (total <= BigInt.zero || total > BigInt.from(maxMoneyMinorUnits)) {
    return null;
  }
  return total.toInt();
}

int legacyMajorToMinorUnits(num value, {bool allowZero = false}) {
  final major = value.toDouble();
  if (!major.isFinite || major < 0 || (!allowZero && major == 0)) {
    throw const FormatException('Invalid legacy money value');
  }

  final minor = (major * 100).round();
  if ((!allowZero && minor == 0) || minor > maxMoneyMinorUnits) {
    throw const FormatException('Legacy money value is out of range');
  }
  return minor;
}

int? storedMinorUnits({
  required Object? minorValue,
  required Object? legacyMajorValue,
  bool allowZero = false,
}) {
  if (minorValue != null) {
    if (minorValue is! int ||
        minorValue < 0 ||
        (!allowZero && minorValue == 0) ||
        minorValue > maxMoneyMinorUnits) {
      throw const FormatException('Invalid stored minor-unit value');
    }
    return minorValue;
  }
  if (legacyMajorValue == null) return null;
  if (legacyMajorValue is! num) {
    throw const FormatException('Invalid legacy money value');
  }
  return legacyMajorToMinorUnits(legacyMajorValue, allowZero: allowZero);
}

int divideMinorUnitsRounded(int value, int divisor) {
  if (divisor <= 0) throw ArgumentError.value(divisor, 'divisor');

  final quotient = value ~/ divisor;
  final remainder = value.remainder(divisor).abs();
  if (remainder * 2 < divisor) return quotient;
  return quotient + value.sign;
}

int annualToMonthlyEstimateMinor(int yearlyMinor) =>
    divideMinorUnitsRounded(yearlyMinor, 12);

String formatMinorUnits(int value) {
  final absolute = value.abs();
  final major = absolute ~/ 100;
  final minor = (absolute % 100).toString().padLeft(2, '0');
  return '${value.isNegative ? '-' : ''}$major.$minor';
}

String formatChfMinor(int value) => '${formatMinorUnits(value)} CHF';

String? positiveAmountValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Pflichtfeld';
  return parsePositiveMinorUnits(value) == null
      ? 'Bitte einen gültigen Betrag eingeben'
      : null;
}
