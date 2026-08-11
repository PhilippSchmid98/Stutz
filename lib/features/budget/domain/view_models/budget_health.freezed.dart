// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_health.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetHealth {

 double get income; double get expenses;
/// Create a copy of BudgetHealth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetHealthCopyWith<BudgetHealth> get copyWith => _$BudgetHealthCopyWithImpl<BudgetHealth>(this as BudgetHealth, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetHealth&&(identical(other.income, income) || other.income == income)&&(identical(other.expenses, expenses) || other.expenses == expenses));
}


@override
int get hashCode => Object.hash(runtimeType,income,expenses);

@override
String toString() {
  return 'BudgetHealth(income: $income, expenses: $expenses)';
}


}

/// @nodoc
abstract mixin class $BudgetHealthCopyWith<$Res>  {
  factory $BudgetHealthCopyWith(BudgetHealth value, $Res Function(BudgetHealth) _then) = _$BudgetHealthCopyWithImpl;
@useResult
$Res call({
 double income, double expenses
});




}
/// @nodoc
class _$BudgetHealthCopyWithImpl<$Res>
    implements $BudgetHealthCopyWith<$Res> {
  _$BudgetHealthCopyWithImpl(this._self, this._then);

  final BudgetHealth _self;
  final $Res Function(BudgetHealth) _then;

/// Create a copy of BudgetHealth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? income = null,Object? expenses = null,}) {
  return _then(_self.copyWith(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetHealth].
extension BudgetHealthPatterns on BudgetHealth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetHealth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetHealth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetHealth value)  $default,){
final _that = this;
switch (_that) {
case _BudgetHealth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetHealth value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetHealth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double income,  double expenses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetHealth() when $default != null:
return $default(_that.income,_that.expenses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double income,  double expenses)  $default,) {final _that = this;
switch (_that) {
case _BudgetHealth():
return $default(_that.income,_that.expenses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double income,  double expenses)?  $default,) {final _that = this;
switch (_that) {
case _BudgetHealth() when $default != null:
return $default(_that.income,_that.expenses);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetHealth extends BudgetHealth {
  const _BudgetHealth({required this.income, required this.expenses}): super._();
  

@override final  double income;
@override final  double expenses;

/// Create a copy of BudgetHealth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetHealthCopyWith<_BudgetHealth> get copyWith => __$BudgetHealthCopyWithImpl<_BudgetHealth>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetHealth&&(identical(other.income, income) || other.income == income)&&(identical(other.expenses, expenses) || other.expenses == expenses));
}


@override
int get hashCode => Object.hash(runtimeType,income,expenses);

@override
String toString() {
  return 'BudgetHealth(income: $income, expenses: $expenses)';
}


}

/// @nodoc
abstract mixin class _$BudgetHealthCopyWith<$Res> implements $BudgetHealthCopyWith<$Res> {
  factory _$BudgetHealthCopyWith(_BudgetHealth value, $Res Function(_BudgetHealth) _then) = __$BudgetHealthCopyWithImpl;
@override @useResult
$Res call({
 double income, double expenses
});




}
/// @nodoc
class __$BudgetHealthCopyWithImpl<$Res>
    implements _$BudgetHealthCopyWith<$Res> {
  __$BudgetHealthCopyWithImpl(this._self, this._then);

  final _BudgetHealth _self;
  final $Res Function(_BudgetHealth) _then;

/// Create a copy of BudgetHealth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? expenses = null,}) {
  return _then(_BudgetHealth(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
