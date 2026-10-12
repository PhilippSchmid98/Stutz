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

 int get monthlyIncomeMinor; int get yearlyIncomeMinor; int get fixedMonthlyExpensesMinor; int get fixedYearlyExpensesMinor; int get variableMonthlyExpensesMinor; int get variableYearlyExpensesMinor;
/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSummaryCopyWith<BudgetSummary> get copyWith => _$BudgetSummaryCopyWithImpl<BudgetSummary>(this as BudgetSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSummary&&(identical(other.monthlyIncomeMinor, monthlyIncomeMinor) || other.monthlyIncomeMinor == monthlyIncomeMinor)&&(identical(other.yearlyIncomeMinor, yearlyIncomeMinor) || other.yearlyIncomeMinor == yearlyIncomeMinor)&&(identical(other.fixedMonthlyExpensesMinor, fixedMonthlyExpensesMinor) || other.fixedMonthlyExpensesMinor == fixedMonthlyExpensesMinor)&&(identical(other.fixedYearlyExpensesMinor, fixedYearlyExpensesMinor) || other.fixedYearlyExpensesMinor == fixedYearlyExpensesMinor)&&(identical(other.variableMonthlyExpensesMinor, variableMonthlyExpensesMinor) || other.variableMonthlyExpensesMinor == variableMonthlyExpensesMinor)&&(identical(other.variableYearlyExpensesMinor, variableYearlyExpensesMinor) || other.variableYearlyExpensesMinor == variableYearlyExpensesMinor));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyIncomeMinor,yearlyIncomeMinor,fixedMonthlyExpensesMinor,fixedYearlyExpensesMinor,variableMonthlyExpensesMinor,variableYearlyExpensesMinor);

@override
String toString() {
  return 'BudgetSummary(monthlyIncomeMinor: $monthlyIncomeMinor, yearlyIncomeMinor: $yearlyIncomeMinor, fixedMonthlyExpensesMinor: $fixedMonthlyExpensesMinor, fixedYearlyExpensesMinor: $fixedYearlyExpensesMinor, variableMonthlyExpensesMinor: $variableMonthlyExpensesMinor, variableYearlyExpensesMinor: $variableYearlyExpensesMinor)';
}


}

/// @nodoc
abstract mixin class $BudgetSummaryCopyWith<$Res>  {
  factory $BudgetSummaryCopyWith(BudgetSummary value, $Res Function(BudgetSummary) _then) = _$BudgetSummaryCopyWithImpl;
@useResult
$Res call({
 int monthlyIncomeMinor, int yearlyIncomeMinor, int fixedMonthlyExpensesMinor, int fixedYearlyExpensesMinor, int variableMonthlyExpensesMinor, int variableYearlyExpensesMinor
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
@pragma('vm:prefer-inline') @override $Res call({Object? monthlyIncomeMinor = null,Object? yearlyIncomeMinor = null,Object? fixedMonthlyExpensesMinor = null,Object? fixedYearlyExpensesMinor = null,Object? variableMonthlyExpensesMinor = null,Object? variableYearlyExpensesMinor = null,}) {
  return _then(_self.copyWith(
monthlyIncomeMinor: null == monthlyIncomeMinor ? _self.monthlyIncomeMinor : monthlyIncomeMinor // ignore: cast_nullable_to_non_nullable
as int,yearlyIncomeMinor: null == yearlyIncomeMinor ? _self.yearlyIncomeMinor : yearlyIncomeMinor // ignore: cast_nullable_to_non_nullable
as int,fixedMonthlyExpensesMinor: null == fixedMonthlyExpensesMinor ? _self.fixedMonthlyExpensesMinor : fixedMonthlyExpensesMinor // ignore: cast_nullable_to_non_nullable
as int,fixedYearlyExpensesMinor: null == fixedYearlyExpensesMinor ? _self.fixedYearlyExpensesMinor : fixedYearlyExpensesMinor // ignore: cast_nullable_to_non_nullable
as int,variableMonthlyExpensesMinor: null == variableMonthlyExpensesMinor ? _self.variableMonthlyExpensesMinor : variableMonthlyExpensesMinor // ignore: cast_nullable_to_non_nullable
as int,variableYearlyExpensesMinor: null == variableYearlyExpensesMinor ? _self.variableYearlyExpensesMinor : variableYearlyExpensesMinor // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int monthlyIncomeMinor,  int yearlyIncomeMinor,  int fixedMonthlyExpensesMinor,  int fixedYearlyExpensesMinor,  int variableMonthlyExpensesMinor,  int variableYearlyExpensesMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.monthlyIncomeMinor,_that.yearlyIncomeMinor,_that.fixedMonthlyExpensesMinor,_that.fixedYearlyExpensesMinor,_that.variableMonthlyExpensesMinor,_that.variableYearlyExpensesMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int monthlyIncomeMinor,  int yearlyIncomeMinor,  int fixedMonthlyExpensesMinor,  int fixedYearlyExpensesMinor,  int variableMonthlyExpensesMinor,  int variableYearlyExpensesMinor)  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary():
return $default(_that.monthlyIncomeMinor,_that.yearlyIncomeMinor,_that.fixedMonthlyExpensesMinor,_that.fixedYearlyExpensesMinor,_that.variableMonthlyExpensesMinor,_that.variableYearlyExpensesMinor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int monthlyIncomeMinor,  int yearlyIncomeMinor,  int fixedMonthlyExpensesMinor,  int fixedYearlyExpensesMinor,  int variableMonthlyExpensesMinor,  int variableYearlyExpensesMinor)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.monthlyIncomeMinor,_that.yearlyIncomeMinor,_that.fixedMonthlyExpensesMinor,_that.fixedYearlyExpensesMinor,_that.variableMonthlyExpensesMinor,_that.variableYearlyExpensesMinor);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetSummary extends BudgetSummary {
  const _BudgetSummary({required this.monthlyIncomeMinor, required this.yearlyIncomeMinor, required this.fixedMonthlyExpensesMinor, required this.fixedYearlyExpensesMinor, required this.variableMonthlyExpensesMinor, required this.variableYearlyExpensesMinor}): super._();
  

@override final  int monthlyIncomeMinor;
@override final  int yearlyIncomeMinor;
@override final  int fixedMonthlyExpensesMinor;
@override final  int fixedYearlyExpensesMinor;
@override final  int variableMonthlyExpensesMinor;
@override final  int variableYearlyExpensesMinor;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSummaryCopyWith<_BudgetSummary> get copyWith => __$BudgetSummaryCopyWithImpl<_BudgetSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSummary&&(identical(other.monthlyIncomeMinor, monthlyIncomeMinor) || other.monthlyIncomeMinor == monthlyIncomeMinor)&&(identical(other.yearlyIncomeMinor, yearlyIncomeMinor) || other.yearlyIncomeMinor == yearlyIncomeMinor)&&(identical(other.fixedMonthlyExpensesMinor, fixedMonthlyExpensesMinor) || other.fixedMonthlyExpensesMinor == fixedMonthlyExpensesMinor)&&(identical(other.fixedYearlyExpensesMinor, fixedYearlyExpensesMinor) || other.fixedYearlyExpensesMinor == fixedYearlyExpensesMinor)&&(identical(other.variableMonthlyExpensesMinor, variableMonthlyExpensesMinor) || other.variableMonthlyExpensesMinor == variableMonthlyExpensesMinor)&&(identical(other.variableYearlyExpensesMinor, variableYearlyExpensesMinor) || other.variableYearlyExpensesMinor == variableYearlyExpensesMinor));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyIncomeMinor,yearlyIncomeMinor,fixedMonthlyExpensesMinor,fixedYearlyExpensesMinor,variableMonthlyExpensesMinor,variableYearlyExpensesMinor);

@override
String toString() {
  return 'BudgetSummary(monthlyIncomeMinor: $monthlyIncomeMinor, yearlyIncomeMinor: $yearlyIncomeMinor, fixedMonthlyExpensesMinor: $fixedMonthlyExpensesMinor, fixedYearlyExpensesMinor: $fixedYearlyExpensesMinor, variableMonthlyExpensesMinor: $variableMonthlyExpensesMinor, variableYearlyExpensesMinor: $variableYearlyExpensesMinor)';
}


}

/// @nodoc
abstract mixin class _$BudgetSummaryCopyWith<$Res> implements $BudgetSummaryCopyWith<$Res> {
  factory _$BudgetSummaryCopyWith(_BudgetSummary value, $Res Function(_BudgetSummary) _then) = __$BudgetSummaryCopyWithImpl;
@override @useResult
$Res call({
 int monthlyIncomeMinor, int yearlyIncomeMinor, int fixedMonthlyExpensesMinor, int fixedYearlyExpensesMinor, int variableMonthlyExpensesMinor, int variableYearlyExpensesMinor
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
@override @pragma('vm:prefer-inline') $Res call({Object? monthlyIncomeMinor = null,Object? yearlyIncomeMinor = null,Object? fixedMonthlyExpensesMinor = null,Object? fixedYearlyExpensesMinor = null,Object? variableMonthlyExpensesMinor = null,Object? variableYearlyExpensesMinor = null,}) {
  return _then(_BudgetSummary(
monthlyIncomeMinor: null == monthlyIncomeMinor ? _self.monthlyIncomeMinor : monthlyIncomeMinor // ignore: cast_nullable_to_non_nullable
as int,yearlyIncomeMinor: null == yearlyIncomeMinor ? _self.yearlyIncomeMinor : yearlyIncomeMinor // ignore: cast_nullable_to_non_nullable
as int,fixedMonthlyExpensesMinor: null == fixedMonthlyExpensesMinor ? _self.fixedMonthlyExpensesMinor : fixedMonthlyExpensesMinor // ignore: cast_nullable_to_non_nullable
as int,fixedYearlyExpensesMinor: null == fixedYearlyExpensesMinor ? _self.fixedYearlyExpensesMinor : fixedYearlyExpensesMinor // ignore: cast_nullable_to_non_nullable
as int,variableMonthlyExpensesMinor: null == variableMonthlyExpensesMinor ? _self.variableMonthlyExpensesMinor : variableMonthlyExpensesMinor // ignore: cast_nullable_to_non_nullable
as int,variableYearlyExpensesMinor: null == variableYearlyExpensesMinor ? _self.variableYearlyExpensesMinor : variableYearlyExpensesMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
