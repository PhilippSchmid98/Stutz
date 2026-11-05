import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/utils/amount_parser.dart';

void main() {
  test('parses positive amounts directly into minor units', () {
    expect(parsePositiveMinorUnits(' 42,50 '), 4250);
    expect(parsePositiveMinorUnits('1'), 100);
    expect(parsePositiveMinorUnits('1.2'), 120);
    expect(parsePositiveMinorUnits('0.01'), 1);
  });

  test('rejects invalid precision, signs, zero, and out-of-range amounts', () {
    expect(parsePositiveMinorUnits('invalid'), isNull);
    expect(parsePositiveMinorUnits('0'), isNull);
    expect(parsePositiveMinorUnits('-10'), isNull);
    expect(parsePositiveMinorUnits('+10'), isNull);
    expect(parsePositiveMinorUnits('1.999'), isNull);
    expect(parsePositiveMinorUnits('Infinity'), isNull);
    expect(parsePositiveMinorUnits('1000000000.00'), isNull);
  });

  test('validates required and positive amount input consistently', () {
    expect(positiveAmountValidator(''), 'Pflichtfeld');
    expect(positiveAmountValidator('  '), 'Pflichtfeld');
    expect(
      positiveAmountValidator('0'),
      'Bitte einen gültigen Betrag eingeben',
    );
    expect(positiveAmountValidator('12,50'), isNull);
  });

  test('formats signed minor units without floating-point conversion', () {
    expect(formatMinorUnits(1), '0.01');
    expect(formatMinorUnits(4250), '42.50');
    expect(formatChfMinor(-4250), '-42.50 CHF');
  });

  test('rounds annual estimates half away from zero', () {
    expect(annualToMonthlyEstimateMinor(10000), 833);
    expect(annualToMonthlyEstimateMinor(10002), 834);
    expect(annualToMonthlyEstimateMinor(-10002), -834);
  });

  test('converts finite legacy major-unit values at the read boundary', () {
    expect(legacyMajorToMinorUnits(12.05), 1205);
    expect(legacyMajorToMinorUnits(0, allowZero: true), 0);
    expect(() => legacyMajorToMinorUnits(double.nan), throwsFormatException);
    expect(() => legacyMajorToMinorUnits(-1), throwsFormatException);
  });

  test('prefers canonical stored minor units and supports legacy reads', () {
    expect(storedMinorUnits(minorValue: 1205, legacyMajorValue: 99), 1205);
    expect(storedMinorUnits(minorValue: null, legacyMajorValue: 12.05), 1205);
    expect(
      () => storedMinorUnits(minorValue: 12.5, legacyMajorValue: null),
      throwsFormatException,
    );
  });
}
