// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_transactions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyTransactions {

 DateTime get date; double get totalAmount; List<TransactionWithCategory> get transactions;
/// Create a copy of DailyTransactions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyTransactionsCopyWith<DailyTransactions> get copyWith => _$DailyTransactionsCopyWithImpl<DailyTransactions>(this as DailyTransactions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyTransactions&&(identical(other.date, date) || other.date == date)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&const DeepCollectionEquality().equals(other.transactions, transactions));
}


@override
int get hashCode => Object.hash(runtimeType,date,totalAmount,const DeepCollectionEquality().hash(transactions));

@override
String toString() {
  return 'DailyTransactions(date: $date, totalAmount: $totalAmount, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class $DailyTransactionsCopyWith<$Res>  {
  factory $DailyTransactionsCopyWith(DailyTransactions value, $Res Function(DailyTransactions) _then) = _$DailyTransactionsCopyWithImpl;
@useResult
$Res call({
 DateTime date, double totalAmount, List<TransactionWithCategory> transactions
});




}
/// @nodoc
class _$DailyTransactionsCopyWithImpl<$Res>
    implements $DailyTransactionsCopyWith<$Res> {
  _$DailyTransactionsCopyWithImpl(this._self, this._then);

  final DailyTransactions _self;
  final $Res Function(DailyTransactions) _then;

/// Create a copy of DailyTransactions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? totalAmount = null,Object? transactions = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionWithCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyTransactions].
extension DailyTransactionsPatterns on DailyTransactions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyTransactions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyTransactions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyTransactions value)  $default,){
final _that = this;
switch (_that) {
case _DailyTransactions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyTransactions value)?  $default,){
final _that = this;
switch (_that) {
case _DailyTransactions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double totalAmount,  List<TransactionWithCategory> transactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyTransactions() when $default != null:
return $default(_that.date,_that.totalAmount,_that.transactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double totalAmount,  List<TransactionWithCategory> transactions)  $default,) {final _that = this;
switch (_that) {
case _DailyTransactions():
return $default(_that.date,_that.totalAmount,_that.transactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double totalAmount,  List<TransactionWithCategory> transactions)?  $default,) {final _that = this;
switch (_that) {
case _DailyTransactions() when $default != null:
return $default(_that.date,_that.totalAmount,_that.transactions);case _:
  return null;

}
}

}

/// @nodoc


class _DailyTransactions implements DailyTransactions {
  const _DailyTransactions({required this.date, required this.totalAmount, required final  List<TransactionWithCategory> transactions}): _transactions = transactions;
  

@override final  DateTime date;
@override final  double totalAmount;
 final  List<TransactionWithCategory> _transactions;
@override List<TransactionWithCategory> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}


/// Create a copy of DailyTransactions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyTransactionsCopyWith<_DailyTransactions> get copyWith => __$DailyTransactionsCopyWithImpl<_DailyTransactions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyTransactions&&(identical(other.date, date) || other.date == date)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&const DeepCollectionEquality().equals(other._transactions, _transactions));
}


@override
int get hashCode => Object.hash(runtimeType,date,totalAmount,const DeepCollectionEquality().hash(_transactions));

@override
String toString() {
  return 'DailyTransactions(date: $date, totalAmount: $totalAmount, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class _$DailyTransactionsCopyWith<$Res> implements $DailyTransactionsCopyWith<$Res> {
  factory _$DailyTransactionsCopyWith(_DailyTransactions value, $Res Function(_DailyTransactions) _then) = __$DailyTransactionsCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double totalAmount, List<TransactionWithCategory> transactions
});




}
/// @nodoc
class __$DailyTransactionsCopyWithImpl<$Res>
    implements _$DailyTransactionsCopyWith<$Res> {
  __$DailyTransactionsCopyWithImpl(this._self, this._then);

  final _DailyTransactions _self;
  final $Res Function(_DailyTransactions) _then;

/// Create a copy of DailyTransactions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? totalAmount = null,Object? transactions = null,}) {
  return _then(_DailyTransactions(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionWithCategory>,
  ));
}


}

// dart format on
