import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

part 'income_source.freezed.dart';

@freezed
abstract class IncomeSource with _$IncomeSource {
  const IncomeSource._();

  const factory IncomeSource({
    required String id,
    required String name,
    required int amountMinor,
    @Default(PaymentInterval.monthly) PaymentInterval interval,
    @Default(IncomeGroup.main) IncomeGroup group,
  }) = _IncomeSource;

  int get monthlyEstimateMinor => interval == PaymentInterval.yearly
      ? annualToMonthlyEstimateMinor(amountMinor)
      : amountMinor;
}
