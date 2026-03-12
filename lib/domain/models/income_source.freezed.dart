// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IncomeSource {

 String get id; String get name; double get amount; PaymentInterval get interval; IncomeGroup get group;
/// Create a copy of IncomeSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomeSourceCopyWith<IncomeSource> get copyWith => _$IncomeSourceCopyWithImpl<IncomeSource>(this as IncomeSource, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomeSource&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.group, group) || other.group == group));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,amount,interval,group);

@override
String toString() {
  return 'IncomeSource(id: $id, name: $name, amount: $amount, interval: $interval, group: $group)';
}


}

/// @nodoc
abstract mixin class $IncomeSourceCopyWith<$Res>  {
  factory $IncomeSourceCopyWith(IncomeSource value, $Res Function(IncomeSource) _then) = _$IncomeSourceCopyWithImpl;
@useResult
$Res call({
 String id, String name, double amount, PaymentInterval interval, IncomeGroup group
});




}
/// @nodoc
class _$IncomeSourceCopyWithImpl<$Res>
    implements $IncomeSourceCopyWith<$Res> {
  _$IncomeSourceCopyWithImpl(this._self, this._then);

  final IncomeSource _self;
  final $Res Function(IncomeSource) _then;

/// Create a copy of IncomeSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? interval = null,Object? group = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as PaymentInterval,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as IncomeGroup,
  ));
}

}


/// Adds pattern-matching-related methods to [IncomeSource].
extension IncomeSourcePatterns on IncomeSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IncomeSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IncomeSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IncomeSource value)  $default,){
final _that = this;
switch (_that) {
case _IncomeSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IncomeSource value)?  $default,){
final _that = this;
switch (_that) {
case _IncomeSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double amount,  PaymentInterval interval,  IncomeGroup group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IncomeSource() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.interval,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double amount,  PaymentInterval interval,  IncomeGroup group)  $default,) {final _that = this;
switch (_that) {
case _IncomeSource():
return $default(_that.id,_that.name,_that.amount,_that.interval,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double amount,  PaymentInterval interval,  IncomeGroup group)?  $default,) {final _that = this;
switch (_that) {
case _IncomeSource() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.interval,_that.group);case _:
  return null;

}
}

}

/// @nodoc


class _IncomeSource implements IncomeSource {
  const _IncomeSource({required this.id, required this.name, required this.amount, this.interval = PaymentInterval.monthly, this.group = IncomeGroup.main});
  

@override final  String id;
@override final  String name;
@override final  double amount;
@override@JsonKey() final  PaymentInterval interval;
@override@JsonKey() final  IncomeGroup group;

/// Create a copy of IncomeSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncomeSourceCopyWith<_IncomeSource> get copyWith => __$IncomeSourceCopyWithImpl<_IncomeSource>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncomeSource&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.group, group) || other.group == group));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,amount,interval,group);

@override
String toString() {
  return 'IncomeSource(id: $id, name: $name, amount: $amount, interval: $interval, group: $group)';
}


}

/// @nodoc
abstract mixin class _$IncomeSourceCopyWith<$Res> implements $IncomeSourceCopyWith<$Res> {
  factory _$IncomeSourceCopyWith(_IncomeSource value, $Res Function(_IncomeSource) _then) = __$IncomeSourceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double amount, PaymentInterval interval, IncomeGroup group
});




}
/// @nodoc
class __$IncomeSourceCopyWithImpl<$Res>
    implements _$IncomeSourceCopyWith<$Res> {
  __$IncomeSourceCopyWithImpl(this._self, this._then);

  final _IncomeSource _self;
  final $Res Function(_IncomeSource) _then;

/// Create a copy of IncomeSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? interval = null,Object? group = null,}) {
  return _then(_IncomeSource(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as PaymentInterval,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as IncomeGroup,
  ));
}


}

// dart format on
