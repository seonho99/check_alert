// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskListState {

 List<TaskModel> get tasks; List<TaskModel> get filteredTasks; bool get isLoading; String get selectedCategory; String? get errorMessage; DateTime get focusedDay; DateTime? get selectedDay;
/// Create a copy of TaskListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskListStateCopyWith<TaskListState> get copyWith => _$TaskListStateCopyWithImpl<TaskListState>(this as TaskListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskListState&&const DeepCollectionEquality().equals(other.tasks, tasks)&&const DeepCollectionEquality().equals(other.filteredTasks, filteredTasks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.focusedDay, focusedDay) || other.focusedDay == focusedDay)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tasks),const DeepCollectionEquality().hash(filteredTasks),isLoading,selectedCategory,errorMessage,focusedDay,selectedDay);

@override
String toString() {
  return 'TaskListState(tasks: $tasks, filteredTasks: $filteredTasks, isLoading: $isLoading, selectedCategory: $selectedCategory, errorMessage: $errorMessage, focusedDay: $focusedDay, selectedDay: $selectedDay)';
}


}

/// @nodoc
abstract mixin class $TaskListStateCopyWith<$Res>  {
  factory $TaskListStateCopyWith(TaskListState value, $Res Function(TaskListState) _then) = _$TaskListStateCopyWithImpl;
@useResult
$Res call({
@override List<TaskModel> tasks,@override List<TaskModel> filteredTasks,@override bool isLoading,@override String selectedCategory,@override String? errorMessage,@override DateTime focusedDay,@override DateTime? selectedDay
});




}
/// @nodoc
class _$TaskListStateCopyWithImpl<$Res>
    implements $TaskListStateCopyWith<$Res> {
  _$TaskListStateCopyWithImpl(this._self, this._then);

  final TaskListState _self;
  final $Res Function(TaskListState) _then;

/// Create a copy of TaskListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,Object? filteredTasks = null,Object? isLoading = null,Object? selectedCategory = null,Object? errorMessage = freezed,Object? focusedDay = null,Object? selectedDay = freezed,}) {
  return _then(TaskListState(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskModel>,filteredTasks: null == filteredTasks ? _self.filteredTasks : filteredTasks // ignore: cast_nullable_to_non_nullable
as List<TaskModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,focusedDay: null == focusedDay ? _self.focusedDay : focusedDay // ignore: cast_nullable_to_non_nullable
as DateTime,selectedDay: freezed == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskListState].
extension TaskListStatePatterns on TaskListState {
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
