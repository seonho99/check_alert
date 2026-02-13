import 'package:json_annotation/json_annotation.dart';

part 'task_model_dto.g.dart';

/// TaskModel DTO (JsonSerializable)
/// 모든 필드 nullable
@JsonSerializable()
class TaskModelDto {
  final String? id;
  final String? userId;
  final String? name;
  final String? category;
  final List<int>? repeatDays;
  final int? reminderHour;
  final int? reminderMinute;
  final bool? isActive;
  final int? sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? repeatType;
  final List<DateTime>? specificDates;
  final List<int>? repeatMonthDays;

  const TaskModelDto({
    this.id,
    this.userId,
    this.name,
    this.category,
    this.repeatDays,
    this.reminderHour,
    this.reminderMinute,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.repeatType,
    this.specificDates,
    this.repeatMonthDays,
  });

  factory TaskModelDto.fromJson(Map<String, dynamic> json) =>
      _$TaskModelDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelDtoToJson(this);

  TaskModelDto copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    List<int>? repeatDays,
    int? reminderHour,
    int? reminderMinute,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? repeatType,
    List<DateTime>? specificDates,
    List<int>? repeatMonthDays,
  }) {
    return TaskModelDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      repeatDays: repeatDays ?? this.repeatDays,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      repeatType: repeatType ?? this.repeatType,
      specificDates: specificDates ?? this.specificDates,
      repeatMonthDays: repeatMonthDays ?? this.repeatMonthDays,
    );
  }
}
