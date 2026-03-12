import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/core/enums/enums.dart';

part 'income_source.freezed.dart';

@freezed
abstract class IncomeSource with _$IncomeSource {
  const factory IncomeSource({
    required String id,
    required String name,
    required double amount,
    @Default(PaymentInterval.monthly) PaymentInterval interval,
    @Default(IncomeGroup.main) IncomeGroup group,
  }) = _IncomeSource;
}
