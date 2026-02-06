# 🔄 Mapper 설계 가이드 (Extension 패턴)

## 🎯 목적

Mapper는 **데이터 구조 변환 계층**으로 외부 DTO를 내부 Entity로 변환하고,
반대로 Entity를 DTO로 변환합니다.
이 프로젝트는 **Extension 기반 Mapper 패턴**을 활용하여
자연스럽고 직관적인 변환을 수행합니다.

> **Template Guide**: [Feature] 부분을 실제 기능명으로 대체하여 사용하세요.

---

## 🧱 설계 원칙

- 모든 변환을 **Extension 메서드**로 정의
- 명확한 의미의 메서드명: `toModel()`, `toDto()`
- 리스트 변환을 위한 별도 Extension 메서드: `toModelList()`, `toDtoList()`
- **null 안전성** 보장 필수
- **Firestore 변환은 DataSource에서 처리**: Mapper는 DTO ↔ Model 변환만 담당
- Enum 변환을 위한 헬퍼 메서드 포함

---

## 📁 파일 위치 및 명명 규칙

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/data/mapper/` |
| 파일명 | `{entity_name}_mapper.dart` (예: `user_model_mapper.dart`) |
| Extension명 | `{EntityName}DtoMapper`, `{EntityName}Mapper` 등 |
| 메서드명 | `toModel()`, `toDto()`, `toFirestore()`, `toModelList()` 등 |

---

## ✅ Mapper 예시

### 1. 기본 Mapper 템플릿

```dart
import '../../domain/model/[feature].dart';
import '../dto/[feature]_dto.dart';

/// [Feature]Dto -> [Feature] 변환
extension [Feature]DtoMapper on [Feature]Dto? {
  [Feature]? toModel() {
    final dto = this;
    if (dto == null) return null;

    return [Feature](
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      [field1]: dto.[field1] ?? '',
      [field2]: _stringToEnum(dto.[field2]),  // Enum 변환
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }

  /// 문자열을 Enum으로 변환하는 내부 헬퍼 메서드
  [Feature]Type _stringToEnum(String? type) {
    switch (type?.toLowerCase()) {
      case 'value1':
        return [Feature]Type.value1;
      case 'value2':
        return [Feature]Type.value2;
      default:
        return [Feature]Type.value1; // 기본값
    }
  }
}

/// [Feature] -> [Feature]Dto 변환
extension [Feature]Mapper on [Feature] {
  [Feature]Dto toDto() {
    return [Feature]Dto(
      id: id,
      userId: userId,
      [field1]: [field1],
      [field2]: [field2].toStringValue(),  // Enum → String
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Enum을 문자열로 변환하는 extension
extension [Feature]TypeExtension on [Feature]Type {
  String toStringValue() {
    switch (this) {
      case [Feature]Type.value1:
        return 'value1';
      case [Feature]Type.value2:
        return 'value2';
    }
  }
}

/// List 변환 Extensions
extension [Feature]DtoListMapper on List<[Feature]Dto>? {
  List<[Feature]> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<[Feature]>().toList();
  }
}

extension [Feature]ListMapper on List<[Feature]>? {
  List<[Feature]Dto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}
```

> ⚠️ **Firestore 변환은 DataSource에서 처리**: `_documentToDto()`, `_dtoToFirestore()` 헬퍼 메서드 사용. 참고: [datasource.md](datasource.md)

### 2. 실제 구현: HistoryMapper (실제 프로젝트 예시)

```dart
import '../../domain/model/history.dart';
import '../dto/history_dto.dart';

/// HistoryDto -> History 변환
extension HistoryDtoMapper on HistoryDto? {
  History? toModel() {
    final dto = this;
    if (dto == null) return null;

    return History(
      id: dto.id ?? '',
      userId: dto.userId ?? '',  // 🔐 사용자 UID 매핑
      title: dto.title ?? '',
      amount: (dto.amount ?? 0.0).toDouble(),
      type: _stringToHistoryType(dto.type),
      categoryId: dto.categoryId ?? '',
      categoryName: dto.categoryName,  // ✨ denormalized
      categoryType: dto.categoryType,  // ✨ denormalized
      date: dto.date ?? DateTime.now(),
      description: dto.description,
      cardCompanyId: dto.cardCompanyId,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }

  /// 문자열을 HistoryType으로 변환하는 내부 헬퍼 메서드
  HistoryType _stringToHistoryType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return HistoryType.income;
      case 'expense':
        return HistoryType.expense;
      default:
        return HistoryType.expense; // 기본값
    }
  }
}

/// History -> HistoryDto 변환
extension HistoryMapper on History {
  HistoryDto toDto() {
    return HistoryDto(
      id: id,
      userId: userId,
      title: title,
      amount: amount,
      type: type.toStringValue(),
      categoryId: categoryId,
      categoryName: categoryName,
      categoryType: categoryType,
      date: date,
      description: description,
      cardCompanyId: cardCompanyId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// HistoryType을 문자열로 변환하는 extension
extension HistoryTypeExtension on HistoryType {
  String toStringValue() {
    switch (this) {
      case HistoryType.income:
        return 'income';
      case HistoryType.expense:
        return 'expense';
    }
  }
}

/// List<HistoryDto> -> List<History> 변환
extension HistoryDtoListMapper on List<HistoryDto>? {
  List<History> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<History>().toList();
  }
}

/// List<History> -> List<HistoryDto> 변환
extension HistoryListMapper on List<History>? {
  List<HistoryDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}
```

---

## 📌 Repository에서 Extension Mapper 활용

```dart
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;

  HistoryRepositoryImpl({
    required HistoryDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<History>>> getHistories(String userUid) async {
    try {
      // DataSource에서 DTO 리스트 가져오기
      final dtoList = await _dataSource.getHistories(userUid);

      // ✅ Extension을 통해 DTO 리스트 → Entity 리스트 변환
      final histories = dtoList.toModelList();

      return Result.success(histories);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addHistory(String userUid, History history) async {
    try {
      // ✅ Extension을 통해 Entity → DTO 변환
      final dto = history.toDto();

      // DataSource에 DTO 전달
      await _dataSource.addHistory(userUid, dto);

      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
```

---
## 🔄 주요 변환 패턴

### 기본 사용법
```dart
// DTO → Entity 변환
final history = historyDto.toModel();

// Entity → DTO 변환
final dto = history.toDto();

// 리스트 변환
final histories = historyDtos.toModelList();
final dtos = histories.toDtoList();

// Enum 변환
final typeString = historyType.toStringValue();  // 'income' or 'expense'

// Null 안전성
final history = nullableDto?.toModel(); // null이면 null 반환
```

### 템플릿 활용법
1. **[Feature] 대체**: 실제 기능명으로 대체 (예: History, Budget, Category)
2. **Extension 구현**: DtoMapper, ModelMapper 패턴 활용
3. **Enum 변환**: toStringValue(), _stringToEnum() 헬퍼 메서드
4. **List 지원**: toModelList(), toDtoList() 메서드 추가

---

## ✅ 핵심 요약

- **Extension 기반 변환**: `toModel()`, `toDto()` 메서드로 자연스러운 변환
- **Firestore 변환은 DataSource에서**: Mapper는 DTO ↔ Model 변환만 담당
- **Enum 변환 헬퍼**: `_stringToEnum()`, `toStringValue()` 메서드
- **List 변환**: `toModelList()`, `toDtoList()` Extension 메서드
- **Null 안전성**: nullable Extension으로 안전한 변환

---