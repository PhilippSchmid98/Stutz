// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_with_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionWithCategory {

 AppTransaction get transaction; String get categoryName;/// The parent node's ID, used for grouping by category.
 String? get parentId;
/// Create a copy of TransactionWithCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionWithCategoryCopyWith<TransactionWithCategory> get copyWith => _$TransactionWithCategoryCopyWithImpl<TransactionWithCategory>(this as TransactionWithCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionWithCategory&&(identical(other.transaction, transaction) || other.transaction == transaction)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode => Object.hash(runtimeType,transaction,categoryName,parentId);

@override
String toString() {
  return 'TransactionWithCategory(transaction: $transaction, categoryName: $categoryName, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $TransactionWithCategoryCopyWith<$Res>  {
  factory $TransactionWithCategoryCopyWith(TransactionWithCategory value, $Res Function(TransactionWithCategory) _then) = _$TransactionWithCategoryCopyWithImpl;
@useResult
$Res call({
 AppTransaction transaction, String categoryName, String? parentId
});


$AppTransactionCopyWith<$Res> get transaction;

}
/// @nodoc
class _$TransactionWithCategoryCopyWithImpl<$Res>
    implements $TransactionWithCategoryCopyWith<$Res> {
  _$TransactionWithCategoryCopyWithImpl(this._self, this._then);

  final TransactionWithCategory _self;
  final $Res Function(TransactionWithCategory) _then;

/// Create a copy of TransactionWithCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transaction = null,Object? categoryName = null,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
transaction: null == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as AppTransaction,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TransactionWithCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppTransactionCopyWith<$Res> get transaction {
  
  return $AppTransactionCopyWith<$Res>(_self.transaction, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransactionWithCategory].
extension TransactionWithCategoryPatterns on TransactionWithCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionWithCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionWithCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionWithCategory value)  $default,){
final _that = this;
switch (_that) {
case _TransactionWithCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionWithCategory value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionWithCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppTransaction transaction,  String categoryName,  String? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionWithCategory() when $default != null:
return $default(_that.transaction,_that.categoryName,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppTransaction transaction,  String categoryName,  String? parentId)  $default,) {final _that = this;
switch (_that) {
case _TransactionWithCategory():
return $default(_that.transaction,_that.categoryName,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppTransaction transaction,  String categoryName,  String? parentId)?  $default,) {final _that = this;
switch (_that) {
case _TransactionWithCategory() when $default != null:
return $default(_that.transaction,_that.categoryName,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionWithCategory implements TransactionWithCategory {
  const _TransactionWithCategory({required this.transaction, required this.categoryName, this.parentId});
  

@override final  AppTransaction transaction;
@override final  String categoryName;
/// The parent node's ID, used for grouping by category.
@override final  String? parentId;

/// Create a copy of TransactionWithCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionWithCategoryCopyWith<_TransactionWithCategory> get copyWith => __$TransactionWithCategoryCopyWithImpl<_TransactionWithCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionWithCategory&&(identical(other.transaction, transaction) || other.transaction == transaction)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode => Object.hash(runtimeType,transaction,categoryName,parentId);

@override
String toString() {
  return 'TransactionWithCategory(transaction: $transaction, categoryName: $categoryName, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$TransactionWithCategoryCopyWith<$Res> implements $TransactionWithCategoryCopyWith<$Res> {
  factory _$TransactionWithCategoryCopyWith(_TransactionWithCategory value, $Res Function(_TransactionWithCategory) _then) = __$TransactionWithCategoryCopyWithImpl;
@override @useResult
$Res call({
 AppTransaction transaction, String categoryName, String? parentId
});


@override $AppTransactionCopyWith<$Res> get transaction;

}
/// @nodoc
class __$TransactionWithCategoryCopyWithImpl<$Res>
    implements _$TransactionWithCategoryCopyWith<$Res> {
  __$TransactionWithCategoryCopyWithImpl(this._self, this._then);

  final _TransactionWithCategory _self;
  final $Res Function(_TransactionWithCategory) _then;

/// Create a copy of TransactionWithCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transaction = null,Object? categoryName = null,Object? parentId = freezed,}) {
  return _then(_TransactionWithCategory(
transaction: null == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as AppTransaction,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TransactionWithCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppTransactionCopyWith<$Res> get transaction {
  
  return $AppTransactionCopyWith<$Res>(_self.transaction, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}
}

// dart format on
