// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModelDto _$TaskModelDtoFromJson(Map<String, dynamic> json) => TaskModelDto(
  id: json['id'] as String?,
  userId: json['userId'] as String?,
  name: json['name'] as String?,
  category: json['category'] as String?,
  repeatDays:
      (json['repeatDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  reminderHour: (json['reminderHour'] as num?)?.toInt(),
  reminderMinute: (json['reminderMinute'] as num?)?.toInt(),
  isActive: json['isActive'] as bool?,
  sortOrder: (json['sortOrder'] as num?)?.toInt(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  repeatType: json['repeatType'] as String?,
  specificDates:
      (json['specificDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
  repeatMonthDays:
      (json['repeatMonthDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
);

Map<String, dynamic> _$TaskModelDtoToJson(TaskModelDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'category': instance.category,
      'repeatDays': instance.repeatDays,
      'reminderHour': instance.reminderHour,
      'reminderMinute': instance.reminderMinute,
      'isActive': instance.isActive,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'repeatType': instance.repeatType,
      'specificDates':
          instance.specificDates?.map((e) => e.toIso8601String()).toList(),
      'repeatMonthDays': instance.repeatMonthDays,
    };
