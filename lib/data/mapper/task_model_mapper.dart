import '../../domain/model/repeat_type.dart';
import '../../domain/model/task_model.dart';
import '../dto/task_model_dto.dart';

/// String -> RepeatType 변환 (기본값: weekly)
RepeatType _parseRepeatType(String? value) {
  switch (value) {
    case 'once':
      return RepeatType.once;
    case 'monthly':
      return RepeatType.monthly;
    case 'daily':
    case 'weekly':
    default:
      return RepeatType.weekly;
  }
}

/// RepeatType -> String 변환
String _repeatTypeToString(RepeatType type) {
  return type.name;
}

/// TaskModelDto -> TaskModel 변환
extension TaskModelDtoMapper on TaskModelDto? {
  TaskModel? toModel() {
    final dto = this;
    if (dto == null) return null;

    return TaskModel(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      name: dto.name ?? '',
      category: dto.category ?? '',
      repeatDays: dto.repeatDays ?? [1, 2, 3, 4, 5, 6, 7],
      reminderHour: dto.reminderHour ?? 9,
      reminderMinute: dto.reminderMinute ?? 0,
      isActive: dto.isActive ?? true,
      sortOrder: dto.sortOrder ?? 0,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
      repeatType: _parseRepeatType(dto.repeatType),
      specificDates: dto.specificDates ?? [],
      repeatMonthDays: dto.repeatMonthDays ?? [],
    );
  }
}

/// TaskModel -> TaskModelDto 변환
extension TaskModelMapper on TaskModel {
  TaskModelDto toDto() {
    return TaskModelDto(
      id: id,
      userId: userId,
      name: name,
      category: category,
      repeatDays: repeatDays,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      isActive: isActive,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      repeatType: _repeatTypeToString(repeatType),
      specificDates: specificDates,
      repeatMonthDays: repeatMonthDays,
    );
  }
}

/// TaskModelDto 리스트를 TaskModel 리스트로 변환
extension TaskModelDtoListMapper on List<TaskModelDto>? {
  List<TaskModel> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<TaskModel>().toList();
  }
}

/// TaskModel 리스트를 TaskModelDto 리스트로 변환
extension TaskModelListMapper on List<TaskModel>? {
  List<TaskModelDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}
