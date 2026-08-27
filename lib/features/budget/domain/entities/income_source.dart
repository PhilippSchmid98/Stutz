import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

part 'income_source.freezed.dart';

@freezed
abstract class IncomeSource with _$IncomeSource {
  const IncomeSource._();

  const factory IncomeSource({
    required String id,
    required String name,
    required double amount,
    @Default(PaymentInterval.monthly) PaymentInterval interval,
    @Default(IncomeGroup.main) IncomeGroup group,
  }) = _IncomeSource;

  /// Monthly-equivalent amount — yearly incomes are divided by 12.
  double get monthlyAmount =>
      interval == PaymentInterval.yearly ? amount / 12 : amount;
}
