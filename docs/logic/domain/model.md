# 🧬 Domain Model (Entity) 설계 가이드 - Freezed (Clean Architecture)

> **참조**: [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/guide) | [Freezed Package](https://pub.dev/packages/freezed)

## ✅ 목적

Domain Model(Entity)은 **Clean Architecture Domain Layer**의 핵심으로, 앱의 **핵심 비즈니스 로직을 담는 도메인 객체**입니다.  
**ViewModel** (ChangeNotifier), **UseCase**, **Repository**에서 공통으로 사용되며,  
외부 의존성이 없는 **순수한 도메인 중심 데이터 구조**로 설계합니다.

---

## 🧱 설계 원칙

- **Freezed** `@freezed` + `factory constructor` 패턴 사용
- **불변성(Immutable)** 보장으로 예측 가능한 상태 관리
- **타입 안전성**: 강타입과 null safety 활용
- **순수한 데이터 구조체**: 검증 로직 없음 (UseCase에서 처리)
- **단순한 Extension**: 편의 메서드만 포함
- **DTO와 완전 분리**: Mapper를 통한 변환으로 레이어 독립성 유지

---

## ✅ 파일 위치 및 네이밍

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/domain/model/` |
| 파일명 | `snake_case.dart` (예: `user_model.dart`) |
| 클래스명 | `PascalCase` (예: `UserModel`) |
| 생성 파일 | `{name}.freezed.dart` (자동 생성) |

---

## ✅ 실제 구현 예시 (Auth 도메인)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

/// 사용자 도메인 모델 (순수한 데이터 구조체)
///
/// Clean Architecture 원칙에 따라:
/// - 검증 로직 없음 (Use Cases에서 처리)
/// - 비즈니스 로직 없음 (Domain Services에서 처리)
/// - 기술에 독립적인 순수 도메인 개념만 포함
@freezed
sealed class UserModel with _$UserModel {
  /// 사용자 도메인 모델 생성자
  const factory UserModel({
    required String uid,        // 사용자 고유 ID
    required String email,      // 이메일 주소
    String? displayName,        // 표시 이름
    required bool isEmailVerified,  // 이메일 검증 상태
    required DateTime createdAt,    // 생성 일시
    required DateTime updatedAt,    // 수정 일시
  }) = _UserModel;

}
```

## ✅ Extension 예시 (단순한 편의 메서드만)

```dart
/// UserModel 편의 확장 (단순한 getter만)
extension UserModelExtension on UserModel {
  /// 표시 이름이 있는지 확인
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// 표시할 이름 반환 (표시 이름이 없으면 이메일 사용)
  String get displayNameOrEmail => displayName ?? email;
}
```

## ✅ Feature 템플릿 (일반화)

```dart
/// [Feature] 도메인 모델 (순수한 데이터 구조체)
@freezed
sealed class [Feature]Model with _$[Feature]Model {
  const factory [Feature]Model({
    required String id,
    required String name,
    // feature에 맞는 필드들...
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _[Feature]Model;
}

/// [Feature]Model 편의 확장 (단순한 편의 메서드만)
extension [Feature]ModelExtension on [Feature]Model {
  // feature에 맞는 단순한 getter들...
  bool get isValid => name.isNotEmpty;
  String get displayText => name;
}
```

---

## 🎯 핵심 패턴

### Freezed 3.0+ 장점
- **불변성**: 상태 변경이 예측 가능
- **타입 안전성**: 컴파일 타임 오류 방지
- **코드 생성**: copyWith, toString, equality 자동 생성
- **패턴 매칭**: when/map 메서드 활용 가능
- **sealed 클래스**: Freezed 3.0+에서 `sealed class` 키워드 필수 사용

### Clean Architecture 원칙
- **순수한 데이터 구조체**: 검증이나 복잡한 비즈니스 로직 없음
- **UseCase에서 검증**: 모든 검증과 비즈니스 로직은 UseCase에서 처리
- **Extension은 편의용**: 단순한 getter나 계산만 포함

```dart
// ❌ 잘못된 사용 - Domain Model에 검증 로직
class UserModel {
  bool isEmailValid() {
    // 이메일 검증 로직 - UseCase에서 해야 함
  }

  void validatePassword(String password) {
    // 패스워드 검증 - UseCase에서 해야 함
  }
}

// ✅ 올바른 사용 - 단순한 편의 메서드만
extension UserModelExtension on UserModel {
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;
  String get displayNameOrEmail => displayName ?? email;
}
```

### DTO와의 차이점
- **Domain Model**: 순수 도메인 개념만, photoURL 같은 기술적 필드 없음
- **DTO**: 외부 시스템 연동, photoURL 등 기술적 필드 포함
- **변환**: Mapper를 통해 계층 간 분리 유지

---

> 📎 Repository 및 UseCase에서의 활용은 [repository.md](repository.md) 참조

---
