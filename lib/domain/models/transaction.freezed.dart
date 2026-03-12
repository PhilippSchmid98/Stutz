// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppTransaction {

 String get id; String get expenseNodeId; double get amount; DateTime get dateTime; String? get note;
/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTransactionCopyWith<AppTransaction> get copyWith => _$AppTransactionCopyWithImpl<AppTransaction>(this as AppTransaction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.expenseNodeId, expenseNodeId) || other.expenseNodeId == expenseNodeId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,expenseNodeId,amount,dateTime,note);

@override
String toString() {
  return 'AppTransaction(id: $id, expenseNodeId: $expenseNodeId, amount: $amount, dateTime: $dateTime, note: $note)';
}


}

/// @nodoc
abstract mixin class $AppTransactionCopyWith<$Res>  {
  factory $AppTransactionCopyWith(AppTransaction value, $Res Function(AppTransaction) _then) = _$AppTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String expenseNodeId, double amount, DateTime dateTime, String? note
});




}
/// @nodoc
class _$AppTransactionCopyWithImpl<$Res>
    implements $AppTransactionCopyWith<$Res> {
  _$AppTransactionCopyWithImpl(this._self, this._then);

  final AppTransaction _self;
  final $Res Function(AppTransaction) _then;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? expenseNodeId = null,Object? amount = null,Object? dateTime = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expenseNodeId: null == expenseNodeId ? _self.expenseNodeId : expenseNodeId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppTransaction].
extension AppTransactionPatterns on AppTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppTransaction value)  $default,){
final _that = this;
switch (_that) {
case _AppTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String expenseNodeId,  double amount,  DateTime dateTime,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
return $default(_that.id,_that.expenseNodeId,_that.amount,_that.dateTime,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String expenseNodeId,  double amount,  DateTime dateTime,  String? note)  $default,) {final _that = this;
switch (_that) {
case _AppTransaction():
return $default(_that.id,_that.expenseNodeId,_that.amount,_that.dateTime,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String expenseNodeId,  double amount,  DateTime dateTime,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
return $default(_that.id,_that.expenseNodeId,_that.amount,_that.dateTime,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _AppTransaction implements AppTransaction {
  const _AppTransaction({required this.id, required this.expenseNodeId, required this.amount, required this.dateTime, this.note});
  

@override final  String id;
@override final  String expenseNodeId;
@override final  double amount;
@override final  DateTime dateTime;
@override final  String? note;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTransactionCopyWith<_AppTransaction> get copyWith => __$AppTransactionCopyWithImpl<_AppTransaction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.expenseNodeId, expenseNodeId) || other.expenseNodeId == expenseNodeId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,expenseNodeId,amount,dateTime,note);

@override
String toString() {
  return 'AppTransaction(id: $id, expenseNodeId: $expenseNodeId, amount: $amount, dateTime: $dateTime, note: $note)';
}


}

/// @nodoc
abstract mixin class _$AppTransactionCopyWith<$Res> implements $AppTransactionCopyWith<$Res> {
  factory _$AppTransactionCopyWith(_AppTransaction value, $Res Function(_AppTransaction) _then) = __$AppTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String expenseNodeId, double amount, DateTime dateTime, String? note
});




}
/// @nodoc
class __$AppTransactionCopyWithImpl<$Res>
    implements _$AppTransactionCopyWith<$Res> {
  __$AppTransactionCopyWithImpl(this._self, this._then);

  final _AppTransaction _self;
  final $Res Function(_AppTransaction) _then;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? expenseNodeId = null,Object? amount = null,Object? dateTime = null,Object? note = freezed,}) {
  return _then(_AppTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expenseNodeId: null == expenseNodeId ? _self.expenseNodeId : expenseNodeId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
