import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';

void main() {
  group('IncomeSource', () {
    test('constructor assigns values', () {
      final source = IncomeSource(
        id: '1',
        name: 'Job',
        amount: 1000,
        interval: PaymentInterval.monthly,
        group: IncomeGroup.main,
      );
      expect(source.id, '1');
      expect(source.name, 'Job');
      expect(source.amount, 1000);
    });

    test('default interval is monthly', () {
      final s = IncomeSource(id: '1', name: 'X', amount: 100);
      expect(s.interval, PaymentInterval.monthly);
    });

    test('default group is main', () {
      final s = IncomeSource(id: '1', name: 'X', amount: 100);
      expect(s.group, IncomeGroup.main);
    });

    test('Freezed equality: same values are equal', () {
      final a = IncomeSource(id: '1', name: 'Job', amount: 1000);
      final b = IncomeSource(id: '1', name: 'Job', amount: 1000);
      expect(a, equals(b));
    });

    test('copyWith creates modified copy', () {
      final original = IncomeSource(id: '1', name: 'Old', amount: 100);
      final modified = original.copyWith(name: 'New');
      expect(modified.name, 'New');
      expect(modified.id, '1');
      expect(original.name, 'Old');
    });

    test('monthlyAmount: monthly interval returns amount as-is', () {
      final s = IncomeSource(
        id: '1',
        name: 'X',
        amount: 3000,
        interval: PaymentInterval.monthly,
      );
      expect(s.monthlyAmount, 3000.0);
    });

    test('monthlyAmount: yearly interval divides by 12', () {
      final s = IncomeSource(
        id: '1',
        name: 'X',
        amount: 2400,
        interval: PaymentInterval.yearly,
      );
      expect(s.monthlyAmount, 200.0);
    });
  });
}
