# 📥 DTO (Data Transfer Object) 설계 가이드

## 🎯 목적

DTO는 **외부 시스템(Firebase, API 등)과의 통신**을 위한 **I/O 전용 데이터 구조**입니다.
앱 내부에서 직접 사용하는 **Domain Model(Entity)**과 분리되어야 하며,
**Extension 기반 Mapper**를 통해 변환됩니다.

> **Template Guide**: [Feature] 부분을 실제 기능명으로 대체하여 사용하세요.
> 예: User, Product, Order 등

---

## 🧱 설계 원칙

- **모든 필드 nullable**: 외부 응답은 항상 불완전할 수 있으므로 모든 필드를 nullable로 정의
- **JsonSerializable 사용**: `@JsonSerializable()` 어노테이션으로 JSON 직렬화/역직렬화 처리
- **JSON만 처리**: `fromJson`, `toJson` 메서드만 제공 (Firestore 변환은 DataSource에서 처리)
- **snake_case → camelCase 매핑**: `@JsonKey`로 필드명 변환 처리
- **Extension Mapper 연동**: Repository 구현체에서 Mapper를 통한 Entity 변환
- **copyWith 수동 구현**: 불변성 업데이트를 위한 copyWith 메서드 구현

---

## 📁 파일 위치 및 명명 규칙

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/data/dto/` |
| 파일명 | `{entity_name}_dto.dart` (예: `user_model_dto.dart`) |
| 클래스명 | PascalCase + `Dto` 접미사 (예: `UserModelDto`) |
| 코드 생성 파일 | `.g.dart` 자동 생성 (JsonSerializable) |

---

## ✅ DTO 예시

### 1. 기본 DTO 템플릿

#### [Feature]Dto (템플릿)

```dart
import 'package:json_annotation/json_annotation.dart';

part '[feature]_dto.g.dart';

/// [Feature] DTO (JsonSerializable)
@JsonSerializable()
class [Feature]Dto {
  final String? id;
  final String? userId;  // 🔐 사용자 UID (필수)
  final String? [field1];
  final String? [field2];
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const [Feature]Dto({
    this.id,
    this.userId,
    this.[field1],
    this.[field2],
    this.createdAt,
    this.updatedAt,
  });

  /// JSON serialization (auto-generated)
  factory [Feature]Dto.fromJson(Map<String, dynamic> json) =>
      _$[Feature]DtoFromJson(json);

  Map<String, dynamic> toJson() => _$[Feature]DtoToJson(this);

  /// copyWith 메서드 (수동 구현)
  [Feature]Dto copyWith({
    String? id,
    String? userId,
    String? [field1],
    String? [field2],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return [Feature]Dto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      [field1]: [field1] ?? this.[field1],
      [field2]: [field2] ?? this.[field2],
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

> ⚠️ **Firestore 변환은 DataSource에서 처리**: `fromFirestore`/`toFirestore`는 DTO가 아닌 DataSource 구현체에서 헬퍼 메서드로 구현합니다. 참고: [datasource.md](datasource.md)

### 2. 실제 구현: HistoryDto (실제 프로젝트 예시)

```dart
import 'package:json_annotation/json_annotation.dart';

part 'history_dto.g.dart';

/// History DTO (JsonSerializable)
@JsonSerializable()
class HistoryDto {
  final String? id;
  final String? userId;  // 🔐 사용자 UID (필수!)
  final String? title;
  final num? amount;
  final String? type;
  final String? categoryId;
  final String? categoryName;  // ✨ 카테고리 이름 (denormalized)
  final String? categoryType;  // ✨ 카테고리 타입 (denormalized)
  final DateTime? date;
  final String? description;
  final String? cardCompanyId;  // 🏦 카드사 ID
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HistoryDto({
    this.id,
    this.userId,
    this.title,
    this.amount,
    this.type,
    this.categoryId,
    this.categoryName,
    this.categoryType,
    this.date,
    this.description,
    this.cardCompanyId,
    this.createdAt,
    this.updatedAt,
  });

  factory HistoryDto.fromJson(Map<String, dynamic> json) => _$HistoryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryDtoToJson(this);

  // copyWith 메서드 수동 구현
  HistoryDto copyWith({
    String? id,
    String? userId,
    String? title,
    num? amount,
    String? type,
    String? categoryId,
    String? categoryName,
    String? categoryType,
    DateTime? date,
    String? description,
    String? cardCompanyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoryDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryType: categoryType ?? this.categoryType,
      date: date ?? this.date,
      description: description ?? this.description,
      cardCompanyId: cardCompanyId ?? this.cardCompanyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```


---

## 🔁 DTO ↔ Entity 변환

- DTO는 앱에서 직접 사용하지 않고 **Mapper**를 통해 Entity로 변환해야 합니다.
- DTO는 ViewModel이나 UI에서 직접 접근하지 않습니다.
- Repository는 DataSource에서 DTO를 받아 Mapper를 통해 Entity로 변환 후 반환합니다.

```dart
// ❌ 잘못된 사용 - ViewModel에서 DTO 직접 사용
class AuthViewModel extends ChangeNotifier {
  UserModelDto? user; // 잘못된 사용!
}

// ✅ 올바른 사용 - Repository에서 변환 후 Entity 사용
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Result<UserModel>> getCurrentUser() async {
    final dto = await _dataSource.getCurrentUser();
    final entity = dto.toModel(); // DTO → Entity 변환
    return Success(entity);
  }
}
```

> 참고: [mapper.md](mapper.md)

---

## ✅ 핵심 요약

- **JsonSerializable만 사용**: DTO는 JSON 직렬화/역직렬화만 담당
- **Firestore 변환은 DataSource에서**: `_documentToDto()`, `_dtoToFirestore()` 헬퍼 메서드 활용
- **모든 필드 nullable**: 외부 데이터의 불완전성 대응
- **copyWith 수동 구현**: 불변성 유지를 위한 업데이트 메서드

---