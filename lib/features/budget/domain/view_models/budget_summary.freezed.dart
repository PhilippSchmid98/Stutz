// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetSummary {

 double get averageMonthlyIncome; double get fixedMonthlyExpenses; double get fixedYearlyExpenses; double get variableMonthlyExpenses; double get variableYearlyExpenses;
/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSummaryCopyWith<BudgetSummary> get copyWith => _$BudgetSummaryCopyWithImpl<BudgetSummary>(this as BudgetSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSummary&&(identical(other.averageMonthlyIncome, averageMonthlyIncome) || other.averageMonthlyIncome == averageMonthlyIncome)&&(identical(other.fixedMonthlyExpenses, fixedMonthlyExpenses) || other.fixedMonthlyExpenses == fixedMonthlyExpenses)&&(identical(other.fixedYearlyExpenses, fixedYearlyExpenses) || other.fixedYearlyExpenses == fixedYearlyExpenses)&&(identical(other.variableMonthlyExpenses, variableMonthlyExpenses) || other.variableMonthlyExpenses == variableMonthlyExpenses)&&(identical(other.variableYearlyExpenses, variableYearlyExpenses) || other.variableYearlyExpenses == variableYearlyExpenses));
}


@override
int get hashCode => Object.hash(runtimeType,averageMonthlyIncome,fixedMonthlyExpenses,fixedYearlyExpenses,variableMonthlyExpenses,variableYearlyExpenses);

@override
String toString() {
  return 'BudgetSummary(averageMonthlyIncome: $averageMonthlyIncome, fixedMonthlyExpenses: $fixedMonthlyExpenses, fixedYearlyExpenses: $fixedYearlyExpenses, variableMonthlyExpenses: $variableMonthlyExpenses, variableYearlyExpenses: $variableYearlyExpenses)';
}


}

/// @nodoc
abstract mixin class $BudgetSummaryCopyWith<$Res>  {
  factory $BudgetSummaryCopyWith(BudgetSummary value, $Res Function(BudgetSummary) _then) = _$BudgetSummaryCopyWithImpl;
@useResult
$Res call({
 double averageMonthlyIncome, double fixedMonthlyExpenses, double fixedYearlyExpenses, double variableMonthlyExpenses, double variableYearlyExpenses
});




}
/// @nodoc
class _$BudgetSummaryCopyWithImpl<$Res>
    implements $BudgetSummaryCopyWith<$Res> {
  _$BudgetSummaryCopyWithImpl(this._self, this._then);

  final BudgetSummary _self;
  final $Res Function(BudgetSummary) _then;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? averageMonthlyIncome = null,Object? fixedMonthlyExpenses = null,Object? fixedYearlyExpenses = null,Object? variableMonthlyExpenses = null,Object? variableYearlyExpenses = null,}) {
  return _then(_self.copyWith(
averageMonthlyIncome: null == averageMonthlyIncome ? _self.averageMonthlyIncome : averageMonthlyIncome // ignore: cast_nullable_to_non_nullable
as double,fixedMonthlyExpenses: null == fixedMonthlyExpenses ? _self.fixedMonthlyExpenses : fixedMonthlyExpenses // ignore: cast_nullable_to_non_nullable
as double,fixedYearlyExpenses: null == fixedYearlyExpenses ? _self.fixedYearlyExpenses : fixedYearlyExpenses // ignore: cast_nullable_to_non_nullable
as double,variableMonthlyExpenses: null == variableMonthlyExpenses ? _self.variableMonthlyExpenses : variableMonthlyExpenses // ignore: cast_nullable_to_non_nullable
as double,variableYearlyExpenses: null == variableYearlyExpenses ? _self.variableYearlyExpenses : variableYearlyExpenses // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetSummary].
extension BudgetSummaryPatterns on BudgetSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetSummary value)  $default,){
final _that = this;
switch (_that) {
case _BudgetSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetSummary value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double averageMonthlyIncome,  double fixedMonthlyExpenses,  double fixedYearlyExpenses,  double variableMonthlyExpenses,  double variableYearlyExpenses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.averageMonthlyIncome,_that.fixedMonthlyExpenses,_that.fixedYearlyExpenses,_that.variableMonthlyExpenses,_that.variableYearlyExpenses);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double averageMonthlyIncome,  double fixedMonthlyExpenses,  double fixedYearlyExpenses,  double variableMonthlyExpenses,  double variableYearlyExpenses)  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary():
return $default(_that.averageMonthlyIncome,_that.fixedMonthlyExpenses,_that.fixedYearlyExpenses,_that.variableMonthlyExpenses,_that.variableYearlyExpenses);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double averageMonthlyIncome,  double fixedMonthlyExpenses,  double fixedYearlyExpenses,  double variableMonthlyExpenses,  double variableYearlyExpenses)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.averageMonthlyIncome,_that.fixedMonthlyExpenses,_that.fixedYearlyExpenses,_that.variableMonthlyExpenses,_that.variableYearlyExpenses);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetSummary extends BudgetSummary {
  const _BudgetSummary({required this.averageMonthlyIncome, required this.fixedMonthlyExpenses, required this.fixedYearlyExpenses, required this.variableMonthlyExpenses, required this.variableYearlyExpenses}): super._();
  

@override final  double averageMonthlyIncome;
@override final  double fixedMonthlyExpenses;
@override final  double fixedYearlyExpenses;
@override final  double variableMonthlyExpenses;
@override final  double variableYearlyExpenses;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSummaryCopyWith<_BudgetSummary> get copyWith => __$BudgetSummaryCopyWithImpl<_BudgetSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSummary&&(identical(other.averageMonthlyIncome, averageMonthlyIncome) || other.averageMonthlyIncome == averageMonthlyIncome)&&(identical(other.fixedMonthlyExpenses, fixedMonthlyExpenses) || other.fixedMonthlyExpenses == fixedMonthlyExpenses)&&(identical(other.fixedYearlyExpenses, fixedYearlyExpenses) || other.fixedYearlyExpenses == fixedYearlyExpenses)&&(identical(other.variableMonthlyExpenses, variableMonthlyExpenses) || other.variableMonthlyExpenses == variableMonthlyExpenses)&&(identical(other.variableYearlyExpenses, variableYearlyExpenses) || other.variableYearlyExpenses == variableYearlyExpenses));
}


@override
int get hashCode => Object.hash(runtimeType,averageMonthlyIncome,fixedMonthlyExpenses,fixedYearlyExpenses,variableMonthlyExpenses,variableYearlyExpenses);

@override
String toString() {
  return 'BudgetSummary(averageMonthlyIncome: $averageMonthlyIncome, fixedMonthlyExpenses: $fixedMonthlyExpenses, fixedYearlyExpenses: $fixedYearlyExpenses, variableMonthlyExpenses: $variableMonthlyExpenses, variableYearlyExpenses: $variableYearlyExpenses)';
}


}

/// @nodoc
abstract mixin class _$BudgetSummaryCopyWith<$Res> implements $BudgetSummaryCopyWith<$Res> {
  factory _$BudgetSummaryCopyWith(_BudgetSummary value, $Res Function(_BudgetSummary) _then) = __$BudgetSummaryCopyWithImpl;
@override @useResult
$Res call({
 double averageMonthlyIncome, double fixedMonthlyExpenses, double fixedYearlyExpenses, double variableMonthlyExpenses, double variableYearlyExpenses
});




}
/// @nodoc
class __$BudgetSummaryCopyWithImpl<$Res>
    implements _$BudgetSummaryCopyWith<$Res> {
  __$BudgetSummaryCopyWithImpl(this._self, this._then);

  final _BudgetSummary _self;
  final $Res Function(_BudgetSummary) _then;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? averageMonthlyIncome = null,Object? fixedMonthlyExpenses = null,Object? fixedYearlyExpenses = null,Object? variableMonthlyExpenses = null,Object? variableYearlyExpenses = null,}) {
  return _then(_BudgetSummary(
averageMonthlyIncome: null == averageMonthlyIncome ? _self.averageMonthlyIncome : averageMonthlyIncome // ignore: cast_nullable_to_non_nullable
as double,fixedMonthlyExpenses: null == fixedMonthlyExpenses ? _self.fixedMonthlyExpenses : fixedMonthlyExpenses // ignore: cast_nullable_to_non_nullable
as double,fixedYearlyExpenses: null == fixedYearlyExpenses ? _self.fixedYearlyExpenses : fixedYearlyExpenses // ignore: cast_nullable_to_non_nullable
as double,variableMonthlyExpenses: null == variableMonthlyExpenses ? _self.variableMonthlyExpenses : variableMonthlyExpenses // ignore: cast_nullable_to_non_nullable
as double,variableYearlyExpenses: null == variableYearlyExpenses ? _self.variableYearlyExpenses : variableYearlyExpenses // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
