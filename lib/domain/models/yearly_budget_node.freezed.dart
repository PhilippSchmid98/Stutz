// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'yearly_budget_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$YearlyBudgetNode {

 ExpenseNode get node;/// Total yearly planned budget (own + all children).
 double get planned;/// Total actual spending for the year (own + all children).
 double get actual;/// Virtual pre-app-usage offset (own + all children).
 double get offset; List<YearlyBudgetNode> get children;
/// Create a copy of YearlyBudgetNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$YearlyBudgetNodeCopyWith<YearlyBudgetNode> get copyWith => _$YearlyBudgetNodeCopyWithImpl<YearlyBudgetNode>(this as YearlyBudgetNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is YearlyBudgetNode&&(identical(other.node, node) || other.node == node)&&(identical(other.planned, planned) || other.planned == planned)&&(identical(other.actual, actual) || other.actual == actual)&&(identical(other.offset, offset) || other.offset == offset)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,node,planned,actual,offset,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'YearlyBudgetNode(node: $node, planned: $planned, actual: $actual, offset: $offset, children: $children)';
}


}

/// @nodoc
abstract mixin class $YearlyBudgetNodeCopyWith<$Res>  {
  factory $YearlyBudgetNodeCopyWith(YearlyBudgetNode value, $Res Function(YearlyBudgetNode) _then) = _$YearlyBudgetNodeCopyWithImpl;
@useResult
$Res call({
 ExpenseNode node, double planned, double actual, double offset, List<YearlyBudgetNode> children
});


$ExpenseNodeCopyWith<$Res> get node;

}
/// @nodoc
class _$YearlyBudgetNodeCopyWithImpl<$Res>
    implements $YearlyBudgetNodeCopyWith<$Res> {
  _$YearlyBudgetNodeCopyWithImpl(this._self, this._then);

  final YearlyBudgetNode _self;
  final $Res Function(YearlyBudgetNode) _then;

/// Create a copy of YearlyBudgetNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? node = null,Object? planned = null,Object? actual = null,Object? offset = null,Object? children = null,}) {
  return _then(_self.copyWith(
node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as ExpenseNode,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as double,actual: null == actual ? _self.actual : actual // ignore: cast_nullable_to_non_nullable
as double,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as double,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<YearlyBudgetNode>,
  ));
}
/// Create a copy of YearlyBudgetNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpenseNodeCopyWith<$Res> get node {
  
  return $ExpenseNodeCopyWith<$Res>(_self.node, (value) {
    return _then(_self.copyWith(node: value));
  });
}
}


/// Adds pattern-matching-related methods to [YearlyBudgetNode].
extension YearlyBudgetNodePatterns on YearlyBudgetNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _YearlyBudgetNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _YearlyBudgetNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _YearlyBudgetNode value)  $default,){
final _that = this;
switch (_that) {
case _YearlyBudgetNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _YearlyBudgetNode value)?  $default,){
final _that = this;
switch (_that) {
case _YearlyBudgetNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExpenseNode node,  double planned,  double actual,  double offset,  List<YearlyBudgetNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _YearlyBudgetNode() when $default != null:
return $default(_that.node,_that.planned,_that.actual,_that.offset,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExpenseNode node,  double planned,  double actual,  double offset,  List<YearlyBudgetNode> children)  $default,) {final _that = this;
switch (_that) {
case _YearlyBudgetNode():
return $default(_that.node,_that.planned,_that.actual,_that.offset,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExpenseNode node,  double planned,  double actual,  double offset,  List<YearlyBudgetNode> children)?  $default,) {final _that = this;
switch (_that) {
case _YearlyBudgetNode() when $default != null:
return $default(_that.node,_that.planned,_that.actual,_that.offset,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _YearlyBudgetNode extends YearlyBudgetNode {
  const _YearlyBudgetNode({required this.node, required this.planned, required this.actual, required this.offset, required final  List<YearlyBudgetNode> children}): _children = children,super._();
  

@override final  ExpenseNode node;
/// Total yearly planned budget (own + all children).
@override final  double planned;
/// Total actual spending for the year (own + all children).
@override final  double actual;
/// Virtual pre-app-usage offset (own + all children).
@override final  double offset;
 final  List<YearlyBudgetNode> _children;
@override List<YearlyBudgetNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of YearlyBudgetNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$YearlyBudgetNodeCopyWith<_YearlyBudgetNode> get copyWith => __$YearlyBudgetNodeCopyWithImpl<_YearlyBudgetNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _YearlyBudgetNode&&(identical(other.node, node) || other.node == node)&&(identical(other.planned, planned) || other.planned == planned)&&(identical(other.actual, actual) || other.actual == actual)&&(identical(other.offset, offset) || other.offset == offset)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,node,planned,actual,offset,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'YearlyBudgetNode(node: $node, planned: $planned, actual: $actual, offset: $offset, children: $children)';
}


}

/// @nodoc
abstract mixin class _$YearlyBudgetNodeCopyWith<$Res> implements $YearlyBudgetNodeCopyWith<$Res> {
  factory _$YearlyBudgetNodeCopyWith(_YearlyBudgetNode value, $Res Function(_YearlyBudgetNode) _then) = __$YearlyBudgetNodeCopyWithImpl;
@override @useResult
$Res call({
 ExpenseNode node, double planned, double actual, double offset, List<YearlyBudgetNode> children
});


@override $ExpenseNodeCopyWith<$Res> get node;

}
/// @nodoc
class __$YearlyBudgetNodeCopyWithImpl<$Res>
    implements _$YearlyBudgetNodeCopyWith<$Res> {
  __$YearlyBudgetNodeCopyWithImpl(this._self, this._then);

  final _YearlyBudgetNode _self;
  final $Res Function(_YearlyBudgetNode) _then;

/// Create a copy of YearlyBudgetNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? node = null,Object? planned = null,Object? actual = null,Object? offset = null,Object? children = null,}) {
  return _then(_YearlyBudgetNode(
node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as ExpenseNode,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as double,actual: null == actual ? _self.actual : actual // ignore: cast_nullable_to_non_nullable
as double,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as double,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<YearlyBudgetNode>,
  ));
}

/// Create a copy of YearlyBudgetNode
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
