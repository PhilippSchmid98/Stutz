// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_budget_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthlyBudgetStatus {

 DateTime get month; double get totalPlanned; double get totalSpent;
/// Create a copy of MonthlyBudgetStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyBudgetStatusCopyWith<MonthlyBudgetStatus> get copyWith => _$MonthlyBudgetStatusCopyWithImpl<MonthlyBudgetStatus>(this as MonthlyBudgetStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyBudgetStatus&&(identical(other.month, month) || other.month == month)&&(identical(other.totalPlanned, totalPlanned) || other.totalPlanned == totalPlanned)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent));
}


@override
int get hashCode => Object.hash(runtimeType,month,totalPlanned,totalSpent);

@override
String toString() {
  return 'MonthlyBudgetStatus(month: $month, totalPlanned: $totalPlanned, totalSpent: $totalSpent)';
}


}

/// @nodoc
abstract mixin class $MonthlyBudgetStatusCopyWith<$Res>  {
  factory $MonthlyBudgetStatusCopyWith(MonthlyBudgetStatus value, $Res Function(MonthlyBudgetStatus) _then) = _$MonthlyBudgetStatusCopyWithImpl;
@useResult
$Res call({
 DateTime month, double totalPlanned, double totalSpent
});




}
/// @nodoc
class _$MonthlyBudgetStatusCopyWithImpl<$Res>
    implements $MonthlyBudgetStatusCopyWith<$Res> {
  _$MonthlyBudgetStatusCopyWithImpl(this._self, this._then);

  final MonthlyBudgetStatus _self;
  final $Res Function(MonthlyBudgetStatus) _then;

/// Create a copy of MonthlyBudgetStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? totalPlanned = null,Object? totalSpent = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalPlanned: null == totalPlanned ? _self.totalPlanned : totalPlanned // ignore: cast_nullable_to_non_nullable
as double,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyBudgetStatus].
extension MonthlyBudgetStatusPatterns on MonthlyBudgetStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyBudgetStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyBudgetStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyBudgetStatus value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyBudgetStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyBudgetStatus value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyBudgetStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  double totalPlanned,  double totalSpent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyBudgetStatus() when $default != null:
return $default(_that.month,_that.totalPlanned,_that.totalSpent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  double totalPlanned,  double totalSpent)  $default,) {final _that = this;
switch (_that) {
case _MonthlyBudgetStatus():
return $default(_that.month,_that.totalPlanned,_that.totalSpent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  double totalPlanned,  double totalSpent)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyBudgetStatus() when $default != null:
return $default(_that.month,_that.totalPlanned,_that.totalSpent);case _:
  return null;

}
}

}

/// @nodoc


class _MonthlyBudgetStatus extends MonthlyBudgetStatus {
  const _MonthlyBudgetStatus({required this.month, required this.totalPlanned, required this.totalSpent}): super._();
  

@override final  DateTime month;
@override final  double totalPlanned;
@override final  double totalSpent;

/// Create a copy of MonthlyBudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyBudgetStatusCopyWith<_MonthlyBudgetStatus> get copyWith => __$MonthlyBudgetStatusCopyWithImpl<_MonthlyBudgetStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyBudgetStatus&&(identical(other.month, month) || other.month == month)&&(identical(other.totalPlanned, totalPlanned) || other.totalPlanned == totalPlanned)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent));
}


@override
int get hashCode => Object.hash(runtimeType,month,totalPlanned,totalSpent);

@override
String toString() {
  return 'MonthlyBudgetStatus(month: $month, totalPlanned: $totalPlanned, totalSpent: $totalSpent)';
}


}

/// @nodoc
abstract mixin class _$MonthlyBudgetStatusCopyWith<$Res> implements $MonthlyBudgetStatusCopyWith<$Res> {
  factory _$MonthlyBudgetStatusCopyWith(_MonthlyBudgetStatus value, $Res Function(_MonthlyBudgetStatus) _then) = __$MonthlyBudgetStatusCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, double totalPlanned, double totalSpent
});




}
/// @nodoc
class __$MonthlyBudgetStatusCopyWithImpl<$Res>
    implements _$MonthlyBudgetStatusCopyWith<$Res> {
  __$MonthlyBudgetStatusCopyWithImpl(this._self, this._then);

  final _MonthlyBudgetStatus _self;
  final $Res Function(_MonthlyBudgetStatus) _then;

/// Create a copy of MonthlyBudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? totalPlanned = null,Object? totalSpent = null,}) {
  return _then(_MonthlyBudgetStatus(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalPlanned: null == totalPlanned ? _self.totalPlanned : totalPlanned // ignore: cast_nullable_to_non_nullable
as double,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
