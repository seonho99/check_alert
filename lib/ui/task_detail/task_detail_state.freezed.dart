// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskDetailState {

 String get name; String get category; List<int> get repeatDays; int get reminderHour; int get reminderMinute; bool get isActive; bool get isLoading; bool get isSaveSuccess; bool get isEditMode; RepeatType get repeatType; String? get taskId; String? get errorMessage; List<DateTime> get specificDates; List<int> get repeatMonthDays;
/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDetailStateCopyWith<TaskDetailState> get copyWith => _$TaskDetailStateCopyWithImpl<TaskDetailState>(this as TaskDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDetailState&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.repeatDays, repeatDays)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaveSuccess, isSaveSuccess) || other.isSaveSuccess == isSaveSuccess)&&(identical(other.isEditMode, isEditMode) || other.isEditMode == isEditMode)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.specificDates, specificDates)&&const DeepCollectionEquality().equals(other.repeatMonthDays, repeatMonthDays));
}


@override
int get hashCode => Object.hash(runtimeType,name,category,const DeepCollectionEquality().hash(repeatDays),reminderHour,reminderMinute,isActive,isLoading,isSaveSuccess,isEditMode,repeatType,taskId,errorMessage,const DeepCollectionEquality().hash(specificDates),const DeepCollectionEquality().hash(repeatMonthDays));

@override
String toString() {
  return 'TaskDetailState(name: $name, category: $category, repeatDays: $repeatDays, reminderHour: $reminderHour, reminderMinute: $reminderMinute, isActive: $isActive, isLoading: $isLoading, isSaveSuccess: $isSaveSuccess, isEditMode: $isEditMode, repeatType: $repeatType, taskId: $taskId, errorMessage: $errorMessage, specificDates: $specificDates, repeatMonthDays: $repeatMonthDays)';
}


}

/// @nodoc
abstract mixin class $TaskDetailStateCopyWith<$Res>  {
  factory $TaskDetailStateCopyWith(TaskDetailState value, $Res Function(TaskDetailState) _then) = _$TaskDetailStateCopyWithImpl;
@useResult
$Res call({
@override String name,@override String category,@override List<int> repeatDays,@override int reminderHour,@override int reminderMinute,@override bool isActive,@override bool isLoading,@override bool isSaveSuccess,@override bool isEditMode,@override RepeatType repeatType,@override String? taskId,@override String? errorMessage,@override List<DateTime> specificDates,@override List<int> repeatMonthDays
});




}
/// @nodoc
class _$TaskDetailStateCopyWithImpl<$Res>
    implements $TaskDetailStateCopyWith<$Res> {
  _$TaskDetailStateCopyWithImpl(this._self, this._then);

  final TaskDetailState _self;
  final $Res Function(TaskDetailState) _then;

/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? category = null,Object? repeatDays = null,Object? reminderHour = null,Object? reminderMinute = null,Object? isActive = null,Object? isLoading = null,Object? isSaveSuccess = null,Object? isEditMode = null,Object? repeatType = null,Object? taskId = freezed,Object? errorMessage = freezed,Object? specificDates = null,Object? repeatMonthDays = null,}) {
  return _then(TaskDetailState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,repeatDays: null == repeatDays ? _self.repeatDays : repeatDays // ignore: cast_nullable_to_non_nullable
as List<int>,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaveSuccess: null == isSaveSuccess ? _self.isSaveSuccess : isSaveSuccess // ignore: cast_nullable_to_non_nullable
as bool,isEditMode: null == isEditMode ? _self.isEditMode : isEditMode // ignore: cast_nullable_to_non_nullable
as bool,repeatType: null == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as RepeatType,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,specificDates: null == specificDates ? _self.specificDates : specificDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,repeatMonthDays: null == repeatMonthDays ? _self.repeatMonthDays : repeatMonthDays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskDetailState].
extension TaskDetailStatePatterns on TaskDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
