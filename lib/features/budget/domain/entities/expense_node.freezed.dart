// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpenseNode {

 String get id; String? get parentId; String get name; double? get plannedAmount;/// Calculated field — not persisted in DB.
 double? get actualAmount; ExpenseType? get type; PaymentInterval? get interval; List<ExpenseNode> get children;/// [sortOrder] 99999 is a lazy-migration sentinel for old documents without sorting.
 int get sortOrder;
/// Create a copy of ExpenseNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseNodeCopyWith<ExpenseNode> get copyWith => _$ExpenseNodeCopyWithImpl<ExpenseNode>(this as ExpenseNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseNode&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.plannedAmount, plannedAmount) || other.plannedAmount == plannedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.type, type) || other.type == type)&&(identical(other.interval, interval) || other.interval == interval)&&const DeepCollectionEquality().equals(other.children, children)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode => Object.hash(runtimeType,id,parentId,name,plannedAmount,actualAmount,type,interval,const DeepCollectionEquality().hash(children),sortOrder);

@override
String toString() {
  return 'ExpenseNode(id: $id, parentId: $parentId, name: $name, plannedAmount: $plannedAmount, actualAmount: $actualAmount, type: $type, interval: $interval, children: $children, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $ExpenseNodeCopyWith<$Res>  {
  factory $ExpenseNodeCopyWith(ExpenseNode value, $Res Function(ExpenseNode) _then) = _$ExpenseNodeCopyWithImpl;
@useResult
$Res call({
 String id, String? parentId, String name, double? plannedAmount, double? actualAmount, ExpenseType? type, PaymentInterval? interval, List<ExpenseNode> children, int sortOrder
});




}
/// @nodoc
class _$ExpenseNodeCopyWithImpl<$Res>
    implements $ExpenseNodeCopyWith<$Res> {
  _$ExpenseNodeCopyWithImpl(this._self, this._then);

  final ExpenseNode _self;
  final $Res Function(ExpenseNode) _then;

/// Create a copy of ExpenseNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentId = freezed,Object? name = null,Object? plannedAmount = freezed,Object? actualAmount = freezed,Object? type = freezed,Object? interval = freezed,Object? children = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,plannedAmount: freezed == plannedAmount ? _self.plannedAmount : plannedAmount // ignore: cast_nullable_to_non_nullable
as double?,actualAmount: freezed == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExpenseType?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as PaymentInterval?,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<ExpenseNode>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseNode].
extension ExpenseNodePatterns on ExpenseNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseNode value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseNode value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? parentId,  String name,  double? plannedAmount,  double? actualAmount,  ExpenseType? type,  PaymentInterval? interval,  List<ExpenseNode> children,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseNode() when $default != null:
return $default(_that.id,_that.parentId,_that.name,_that.plannedAmount,_that.actualAmount,_that.type,_that.interval,_that.children,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? parentId,  String name,  double? plannedAmount,  double? actualAmount,  ExpenseType? type,  PaymentInterval? interval,  List<ExpenseNode> children,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _ExpenseNode():
return $default(_that.id,_that.parentId,_that.name,_that.plannedAmount,_that.actualAmount,_that.type,_that.interval,_that.children,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? parentId,  String name,  double? plannedAmount,  double? actualAmount,  ExpenseType? type,  PaymentInterval? interval,  List<ExpenseNode> children,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseNode() when $default != null:
return $default(_that.id,_that.parentId,_that.name,_that.plannedAmount,_that.actualAmount,_that.type,_that.interval,_that.children,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc


class _ExpenseNode extends ExpenseNode {
  const _ExpenseNode({required this.id, this.parentId, required this.name, this.plannedAmount, this.actualAmount, this.type, this.interval, final  List<ExpenseNode> children = const [], this.sortOrder = 99999}): _children = children,super._();
  

@override final  String id;
@override final  String? parentId;
@override final  String name;
@override final  double? plannedAmount;
/// Calculated field — not persisted in DB.
@override final  double? actualAmount;
@override final  ExpenseType? type;
@override final  PaymentInterval? interval;
 final  List<ExpenseNode> _children;
@override@JsonKey() List<ExpenseNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

/// [sortOrder] 99999 is a lazy-migration sentinel for old documents without sorting.
@override@JsonKey() final  int sortOrder;

/// Create a copy of ExpenseNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseNodeCopyWith<_ExpenseNode> get copyWith => __$ExpenseNodeCopyWithImpl<_ExpenseNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseNode&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.plannedAmount, plannedAmount) || other.plannedAmount == plannedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.type, type) || other.type == type)&&(identical(other.interval, interval) || other.interval == interval)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode => Object.hash(runtimeType,id,parentId,name,plannedAmount,actualAmount,type,interval,const DeepCollectionEquality().hash(_children),sortOrder);

@override
String toString() {
  return 'ExpenseNode(id: $id, parentId: $parentId, name: $name, plannedAmount: $plannedAmount, actualAmount: $actualAmount, type: $type, interval: $interval, children: $children, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$ExpenseNodeCopyWith<$Res> implements $ExpenseNodeCopyWith<$Res> {
  factory _$ExpenseNodeCopyWith(_ExpenseNode value, $Res Function(_ExpenseNode) _then) = __$ExpenseNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String? parentId, String name, double? plannedAmount, double? actualAmount, ExpenseType? type, PaymentInterval? interval, List<ExpenseNode> children, int sortOrder
});




}
/// @nodoc
class __$ExpenseNodeCopyWithImpl<$Res>
    implements _$ExpenseNodeCopyWith<$Res> {
  __$ExpenseNodeCopyWithImpl(this._self, this._then);

  final _ExpenseNode _self;
  final $Res Function(_ExpenseNode) _then;

/// Create a copy of ExpenseNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentId = freezed,Object? name = null,Object? plannedAmount = freezed,Object? actualAmount = freezed,Object? type = freezed,Object? interval = freezed,Object? children = null,Object? sortOrder = null,}) {
  return _then(_ExpenseNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,plannedAmount: freezed == plannedAmount ? _self.plannedAmount : plannedAmount // ignore: cast_nullable_to_non_nullable
as double?,actualAmount: freezed == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExpenseType?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as PaymentInterval?,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<ExpenseNode>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
