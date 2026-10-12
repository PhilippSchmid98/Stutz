import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

void main() {
  group('IncomeSource', () {
    test('constructor assigns values', () {
      final source = IncomeSource(
        id: '1',
        name: 'Job',
        amountMinor: 1000,
        interval: PaymentInterval.monthly,
        group: IncomeGroup.main,
      );
      expect(source.id, '1');
      expect(source.name, 'Job');
      expect(source.amountMinor, 1000);
    });

    test('default interval is monthly', () {
      final s = IncomeSource(id: '1', name: 'X', amountMinor: 100);
      expect(s.interval, PaymentInterval.monthly);
    });

    test('default group is main', () {
      final s = IncomeSource(id: '1', name: 'X', amountMinor: 100);
      expect(s.group, IncomeGroup.main);
    });

    test('Freezed equality: same values are equal', () {
      final a = IncomeSource(id: '1', name: 'Job', amountMinor: 1000);
      final b = IncomeSource(id: '1', name: 'Job', amountMinor: 1000);
      expect(a, equals(b));
    });

    test('copyWith creates modified copy', () {
      final original = IncomeSource(id: '1', name: 'Old', amountMinor: 100);
      final modified = original.copyWith(name: 'New');
      expect(modified.name, 'New');
      expect(modified.id, '1');
      expect(original.name, 'Old');
    });

    test('monthly estimate returns a monthly amount as-is', () {
      final s = IncomeSource(
        id: '1',
        name: 'X',
        amountMinor: 3000,
        interval: PaymentInterval.monthly,
      );
      expect(s.monthlyEstimateMinor, 3000);
    });

    test('monthly estimate rounds a yearly amount', () {
      final s = IncomeSource(
        id: '1',
        name: 'X',
        amountMinor: 2400,
        interval: PaymentInterval.yearly,
      );
      expect(s.monthlyEstimateMinor, 200);
    });
  });
}
