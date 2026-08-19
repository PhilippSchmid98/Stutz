import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/utils/amount_parser.dart';

void main() {
  test('parses positive decimal amounts with comma separators', () {
    expect(parsePositiveAmount(' 42,50 '), 42.5);
  });

  test('rejects invalid, zero, negative, and non-finite amounts', () {
    expect(parsePositiveAmount('invalid'), isNull);
    expect(parsePositiveAmount('0'), isNull);
    expect(parsePositiveAmount('-10'), isNull);
    expect(parsePositiveAmount('Infinity'), isNull);
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
}
