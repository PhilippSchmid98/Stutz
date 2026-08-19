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

 double get monthlyIncome; double get monthlyExpenses; double get fixedExpenses; double get variableExpenses;
/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSummaryCopyWith<BudgetSummary> get copyWith => _$BudgetSummaryCopyWithImpl<BudgetSummary>(this as BudgetSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSummary&&(identical(other.monthlyIncome, monthlyIncome) || other.monthlyIncome == monthlyIncome)&&(identical(other.monthlyExpenses, monthlyExpenses) || other.monthlyExpenses == monthlyExpenses)&&(identical(other.fixedExpenses, fixedExpenses) || other.fixedExpenses == fixedExpenses)&&(identical(other.variableExpenses, variableExpenses) || other.variableExpenses == variableExpenses));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyIncome,monthlyExpenses,fixedExpenses,variableExpenses);

@override
String toString() {
  return 'BudgetSummary(monthlyIncome: $monthlyIncome, monthlyExpenses: $monthlyExpenses, fixedExpenses: $fixedExpenses, variableExpenses: $variableExpenses)';
}


}

/// @nodoc
abstract mixin class $BudgetSummaryCopyWith<$Res>  {
  factory $BudgetSummaryCopyWith(BudgetSummary value, $Res Function(BudgetSummary) _then) = _$BudgetSummaryCopyWithImpl;
@useResult
$Res call({
 double monthlyIncome, double monthlyExpenses, double fixedExpenses, double variableExpenses
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
@pragma('vm:prefer-inline') @override $Res call({Object? monthlyIncome = null,Object? monthlyExpenses = null,Object? fixedExpenses = null,Object? variableExpenses = null,}) {
  return _then(_self.copyWith(
monthlyIncome: null == monthlyIncome ? _self.monthlyIncome : monthlyIncome // ignore: cast_nullable_to_non_nullable
as double,monthlyExpenses: null == monthlyExpenses ? _self.monthlyExpenses : monthlyExpenses // ignore: cast_nullable_to_non_nullable
as double,fixedExpenses: null == fixedExpenses ? _self.fixedExpenses : fixedExpenses // ignore: cast_nullable_to_non_nullable
as double,variableExpenses: null == variableExpenses ? _self.variableExpenses : variableExpenses // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double monthlyIncome,  double monthlyExpenses,  double fixedExpenses,  double variableExpenses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.monthlyIncome,_that.monthlyExpenses,_that.fixedExpenses,_that.variableExpenses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double monthlyIncome,  double monthlyExpenses,  double fixedExpenses,  double variableExpenses)  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary():
return $default(_that.monthlyIncome,_that.monthlyExpenses,_that.fixedExpenses,_that.variableExpenses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double monthlyIncome,  double monthlyExpenses,  double fixedExpenses,  double variableExpenses)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.monthlyIncome,_that.monthlyExpenses,_that.fixedExpenses,_that.variableExpenses);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetSummary extends BudgetSummary {
  const _BudgetSummary({required this.monthlyIncome, required this.monthlyExpenses, required this.fixedExpenses, required this.variableExpenses}): super._();
  

@override final  double monthlyIncome;
@override final  double monthlyExpenses;
@override final  double fixedExpenses;
@override final  double variableExpenses;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSummaryCopyWith<_BudgetSummary> get copyWith => __$BudgetSummaryCopyWithImpl<_BudgetSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSummary&&(identical(other.monthlyIncome, monthlyIncome) || other.monthlyIncome == monthlyIncome)&&(identical(other.monthlyExpenses, monthlyExpenses) || other.monthlyExpenses == monthlyExpenses)&&(identical(other.fixedExpenses, fixedExpenses) || other.fixedExpenses == fixedExpenses)&&(identical(other.variableExpenses, variableExpenses) || other.variableExpenses == variableExpenses));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyIncome,monthlyExpenses,fixedExpenses,variableExpenses);

@override
String toString() {
  return 'BudgetSummary(monthlyIncome: $monthlyIncome, monthlyExpenses: $monthlyExpenses, fixedExpenses: $fixedExpenses, variableExpenses: $variableExpenses)';
}


}

/// @nodoc
abstract mixin class _$BudgetSummaryCopyWith<$Res> implements $BudgetSummaryCopyWith<$Res> {
  factory _$BudgetSummaryCopyWith(_BudgetSummary value, $Res Function(_BudgetSummary) _then) = __$BudgetSummaryCopyWithImpl;
@override @useResult
$Res call({
 double monthlyIncome, double monthlyExpenses, double fixedExpenses, double variableExpenses
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
@override @pragma('vm:prefer-inline') $Res call({Object? monthlyIncome = null,Object? monthlyExpenses = null,Object? fixedExpenses = null,Object? variableExpenses = null,}) {
  return _then(_BudgetSummary(
monthlyIncome: null == monthlyIncome ? _self.monthlyIncome : monthlyIncome // ignore: cast_nullable_to_non_nullable
as double,monthlyExpenses: null == monthlyExpenses ? _self.monthlyExpenses : monthlyExpenses // ignore: cast_nullable_to_non_nullable
as double,fixedExpenses: null == fixedExpenses ? _self.fixedExpenses : fixedExpenses // ignore: cast_nullable_to_non_nullable
as double,variableExpenses: null == variableExpenses ? _self.variableExpenses : variableExpenses // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
