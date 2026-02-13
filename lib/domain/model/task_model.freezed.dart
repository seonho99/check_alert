// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskModel {

 String get id; String get userId; String get name; String get category; List<int> get repeatDays; int get reminderHour; int get reminderMinute; bool get isActive; int get sortOrder; DateTime get createdAt; DateTime get updatedAt; RepeatType get repeatType; List<DateTime> get specificDates; List<int> get repeatMonthDays;
/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskModelCopyWith<TaskModel> get copyWith => _$TaskModelCopyWithImpl<TaskModel>(this as TaskModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.repeatDays, repeatDays)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&const DeepCollectionEquality().equals(other.specificDates, specificDates)&&const DeepCollectionEquality().equals(other.repeatMonthDays, repeatMonthDays));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,name,category,const DeepCollectionEquality().hash(repeatDays),reminderHour,reminderMinute,isActive,sortOrder,createdAt,updatedAt,repeatType,const DeepCollectionEquality().hash(specificDates),const DeepCollectionEquality().hash(repeatMonthDays));

@override
String toString() {
  return 'TaskModel(id: $id, userId: $userId, name: $name, category: $category, repeatDays: $repeatDays, reminderHour: $reminderHour, reminderMinute: $reminderMinute, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, repeatType: $repeatType, specificDates: $specificDates, repeatMonthDays: $repeatMonthDays)';
}


}

/// @nodoc
abstract mixin class $TaskModelCopyWith<$Res>  {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) _then) = _$TaskModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String category, List<int> repeatDays, int reminderHour, int reminderMinute, bool isActive, int sortOrder, DateTime createdAt, DateTime updatedAt, RepeatType repeatType, List<DateTime> specificDates, List<int> repeatMonthDays
});




}
/// @nodoc
class _$TaskModelCopyWithImpl<$Res>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._self, this._then);

  final TaskModel _self;
  final $Res Function(TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? category = null,Object? repeatDays = null,Object? reminderHour = null,Object? reminderMinute = null,Object? isActive = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? repeatType = null,Object? specificDates = null,Object? repeatMonthDays = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,repeatDays: null == repeatDays ? _self.repeatDays : repeatDays // ignore: cast_nullable_to_non_nullable
as List<int>,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,repeatType: null == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as RepeatType,specificDates: null == specificDates ? _self.specificDates : specificDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,repeatMonthDays: null == repeatMonthDays ? _self.repeatMonthDays : repeatMonthDays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskModel].
extension TaskModelPatterns on TaskModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String category,  List<int> repeatDays,  int reminderHour,  int reminderMinute,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  RepeatType repeatType,  List<DateTime> specificDates,  List<int> repeatMonthDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.category,_that.repeatDays,_that.reminderHour,_that.reminderMinute,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.repeatType,_that.specificDates,_that.repeatMonthDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String category,  List<int> repeatDays,  int reminderHour,  int reminderMinute,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  RepeatType repeatType,  List<DateTime> specificDates,  List<int> repeatMonthDays)  $default,) {final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that.id,_that.userId,_that.name,_that.category,_that.repeatDays,_that.reminderHour,_that.reminderMinute,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.repeatType,_that.specificDates,_that.repeatMonthDays);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String category,  List<int> repeatDays,  int reminderHour,  int reminderMinute,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  RepeatType repeatType,  List<DateTime> specificDates,  List<int> repeatMonthDays)?  $default,) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.category,_that.repeatDays,_that.reminderHour,_that.reminderMinute,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.repeatType,_that.specificDates,_that.repeatMonthDays);case _:
  return null;

}
}

}

/// @nodoc


class _TaskModel implements TaskModel {
  const _TaskModel({required this.id, required this.userId, required this.name, required this.category, required final  List<int> repeatDays, required this.reminderHour, required this.reminderMinute, required this.isActive, required this.sortOrder, required this.createdAt, required this.updatedAt, required this.repeatType, final  List<DateTime> specificDates = const [], final  List<int> repeatMonthDays = const []}): _repeatDays = repeatDays,_specificDates = specificDates,_repeatMonthDays = repeatMonthDays;
  

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String category;
 final  List<int> _repeatDays;
@override List<int> get repeatDays {
  if (_repeatDays is EqualUnmodifiableListView) return _repeatDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repeatDays);
}

@override final  int reminderHour;
@override final  int reminderMinute;
@override final  bool isActive;
@override final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  RepeatType repeatType;
 final  List<DateTime> _specificDates;
@override@JsonKey() List<DateTime> get specificDates {
  if (_specificDates is EqualUnmodifiableListView) return _specificDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specificDates);
}

 final  List<int> _repeatMonthDays;
@override@JsonKey() List<int> get repeatMonthDays {
  if (_repeatMonthDays is EqualUnmodifiableListView) return _repeatMonthDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repeatMonthDays);
}


/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskModelCopyWith<_TaskModel> get copyWith => __$TaskModelCopyWithImpl<_TaskModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._repeatDays, _repeatDays)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&const DeepCollectionEquality().equals(other._specificDates, _specificDates)&&const DeepCollectionEquality().equals(other._repeatMonthDays, _repeatMonthDays));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,name,category,const DeepCollectionEquality().hash(_repeatDays),reminderHour,reminderMinute,isActive,sortOrder,createdAt,updatedAt,repeatType,const DeepCollectionEquality().hash(_specificDates),const DeepCollectionEquality().hash(_repeatMonthDays));

@override
String toString() {
  return 'TaskModel(id: $id, userId: $userId, name: $name, category: $category, repeatDays: $repeatDays, reminderHour: $reminderHour, reminderMinute: $reminderMinute, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, repeatType: $repeatType, specificDates: $specificDates, repeatMonthDays: $repeatMonthDays)';
}


}

/// @nodoc
abstract mixin class _$TaskModelCopyWith<$Res> implements $TaskModelCopyWith<$Res> {
  factory _$TaskModelCopyWith(_TaskModel value, $Res Function(_TaskModel) _then) = __$TaskModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String category, List<int> repeatDays, int reminderHour, int reminderMinute, bool isActive, int sortOrder, DateTime createdAt, DateTime updatedAt, RepeatType repeatType, List<DateTime> specificDates, List<int> repeatMonthDays
});




}
/// @nodoc
class __$TaskModelCopyWithImpl<$Res>
    implements _$TaskModelCopyWith<$Res> {
  __$TaskModelCopyWithImpl(this._self, this._then);

  final _TaskModel _self;
  final $Res Function(_TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? category = null,Object? repeatDays = null,Object? reminderHour = null,Object? reminderMinute = null,Object? isActive = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? repeatType = null,Object? specificDates = null,Object? repeatMonthDays = null,}) {
  return _then(_TaskModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,repeatDays: null == repeatDays ? _self._repeatDays : repeatDays // ignore: cast_nullable_to_non_nullable
as List<int>,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,repeatType: null == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as RepeatType,specificDates: null == specificDates ? _self._specificDates : specificDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,repeatMonthDays: null == repeatMonthDays ? _self._repeatMonthDays : repeatMonthDays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
