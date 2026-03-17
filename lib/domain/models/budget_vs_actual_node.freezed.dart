// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_vs_actual_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetVsActualNode {

 ExpenseNode get node;/// Total planned budget (own + all children).
 double get planned;/// Total actual spending (own + all children).
 double get actual; List<BudgetVsActualNode> get children;
/// Create a copy of BudgetVsActualNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetVsActualNodeCopyWith<BudgetVsActualNode> get copyWith => _$BudgetVsActualNodeCopyWithImpl<BudgetVsActualNode>(this as BudgetVsActualNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetVsActualNode&&(identical(other.node, node) || other.node == node)&&(identical(other.planned, planned) || other.planned == planned)&&(identical(other.actual, actual) || other.actual == actual)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,node,planned,actual,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'BudgetVsActualNode(node: $node, planned: $planned, actual: $actual, children: $children)';
}


}

/// @nodoc
abstract mixin class $BudgetVsActualNodeCopyWith<$Res>  {
  factory $BudgetVsActualNodeCopyWith(BudgetVsActualNode value, $Res Function(BudgetVsActualNode) _then) = _$BudgetVsActualNodeCopyWithImpl;
@useResult
$Res call({
 ExpenseNode node, double planned, double actual, List<BudgetVsActualNode> children
});


$ExpenseNodeCopyWith<$Res> get node;

}
/// @nodoc
class _$BudgetVsActualNodeCopyWithImpl<$Res>
    implements $BudgetVsActualNodeCopyWith<$Res> {
  _$BudgetVsActualNodeCopyWithImpl(this._self, this._then);

  final BudgetVsActualNode _self;
  final $Res Function(BudgetVsActualNode) _then;

/// Create a copy of BudgetVsActualNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? node = null,Object? planned = null,Object? actual = null,Object? children = null,}) {
  return _then(_self.copyWith(
node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as ExpenseNode,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as double,actual: null == actual ? _self.actual : actual // ignore: cast_nullable_to_non_nullable
as double,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<BudgetVsActualNode>,
  ));
}
/// Create a copy of BudgetVsActualNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpenseNodeCopyWith<$Res> get node {
  
  return $ExpenseNodeCopyWith<$Res>(_self.node, (value) {
    return _then(_self.copyWith(node: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetVsActualNode].
extension BudgetVsActualNodePatterns on BudgetVsActualNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetVsActualNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetVsActualNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetVsActualNode value)  $default,){
final _that = this;
switch (_that) {
case _BudgetVsActualNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetVsActualNode value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetVsActualNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExpenseNode node,  double planned,  double actual,  List<BudgetVsActualNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetVsActualNode() when $default != null:
return $default(_that.node,_that.planned,_that.actual,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExpenseNode node,  double planned,  double actual,  List<BudgetVsActualNode> children)  $default,) {final _that = this;
switch (_that) {
case _BudgetVsActualNode():
return $default(_that.node,_that.planned,_that.actual,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExpenseNode node,  double planned,  double actual,  List<BudgetVsActualNode> children)?  $default,) {final _that = this;
switch (_that) {
case _BudgetVsActualNode() when $default != null:
return $default(_that.node,_that.planned,_that.actual,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetVsActualNode extends BudgetVsActualNode {
  const _BudgetVsActualNode({required this.node, required this.planned, required this.actual, required final  List<BudgetVsActualNode> children}): _children = children,super._();
  

@override final  ExpenseNode node;
/// Total planned budget (own + all children).
@override final  double planned;
/// Total actual spending (own + all children).
@override final  double actual;
 final  List<BudgetVsActualNode> _children;
@override List<BudgetVsActualNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of BudgetVsActualNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetVsActualNodeCopyWith<_BudgetVsActualNode> get copyWith => __$BudgetVsActualNodeCopyWithImpl<_BudgetVsActualNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetVsActualNode&&(identical(other.node, node) || other.node == node)&&(identical(other.planned, planned) || other.planned == planned)&&(identical(other.actual, actual) || other.actual == actual)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,node,planned,actual,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'BudgetVsActualNode(node: $node, planned: $planned, actual: $actual, children: $children)';
}


}

/// @nodoc
abstract mixin class _$BudgetVsActualNodeCopyWith<$Res> implements $BudgetVsActualNodeCopyWith<$Res> {
  factory _$BudgetVsActualNodeCopyWith(_BudgetVsActualNode value, $Res Function(_BudgetVsActualNode) _then) = __$BudgetVsActualNodeCopyWithImpl;
@override @useResult
$Res call({
 ExpenseNode node, double planned, double actual, List<BudgetVsActualNode> children
});


@override $ExpenseNodeCopyWith<$Res> get node;

}
/// @nodoc
class __$BudgetVsActualNodeCopyWithImpl<$Res>
    implements _$BudgetVsActualNodeCopyWith<$Res> {
  __$BudgetVsActualNodeCopyWithImpl(this._self, this._then);

  final _BudgetVsActualNode _self;
  final $Res Function(_BudgetVsActualNode) _then;

/// Create a copy of BudgetVsActualNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? node = null,Object? planned = null,Object? actual = null,Object? children = null,}) {
  return _then(_BudgetVsActualNode(
node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as ExpenseNode,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as double,actual: null == actual ? _self.actual : actual // ignore: cast_nullable_to_non_nullable
as double,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<BudgetVsActualNode>,
  ));
}

/// Create a copy of BudgetVsActualNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpenseNodeCopyWith<$Res> get node {
  
  return $ExpenseNodeCopyWith<$Res>(_self.node, (value) {
    return _then(_self.copyWith(node: value));
  });
}
}

// dart format on
