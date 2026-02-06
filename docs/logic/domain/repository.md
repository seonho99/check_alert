# 🧩 Repository 설계 가이드

> **참조**: [Flutter Architecture Recommendations](https://docs.flutter.dev/app-architecture/recommendations)

## ✅ 목적

Repository는 DataSource를 통해 외부 데이터를 가져오고,  
앱 내부에서 사용할 수 있도록 도메인 모델로 가공하는 **중간 추상화 계층**입니다.  
UseCase는 Repository를 통해 간접적으로 데이터를 접근하며,  
ViewModel은 UseCase를 통해 비즈니스 로직을 실행합니다.

---

## 🧱 설계 원칙

- 항상 `interface` + `impl` 구조로 분리합니다.
- 내부에서 DataSource를 호출하며, 외부 예외는 `Failure`로 변환합니다.
- 반환 타입은 `Result<T>`로 통일합니다.
- 외부로 노출되는 데이터는 DTO가 아닌 **Entity(Domain Model)** 을 기준으로 처리합니다.
- **Provider 패턴**으로 의존성 주입을 관리합니다.

---

## ✅ 파일 위치 및 네이밍

| 항목 | 규칙 |
|------|------|
| 파일 경로 (인터페이스) | `lib/domain/repository/` |
| 파일 경로 (구현체) | `lib/data/repository_impl/` |
| 파일명 (인터페이스) | `{entity_name}_repository.dart` (예: `auth_repository.dart`) |
| 파일명 (구현체) | `{entity_name}_repository_impl.dart` (예: `auth_repository_impl.dart`) |
| 클래스명 (인터페이스) | `{EntityName}Repository` (예: `AuthRepository`) |
| 클래스명 (구현체) | `{EntityName}RepositoryImpl` (예: `AuthRepositoryImpl`) |

---

## ✅ 기본 구조 예시

### Auth Repository 인터페이스 (실제 구현)

```dart
// domain/repository/auth_repository.dart
import '../../core/result/result.dart';
import '../model/user_model.dart';

/// Auth Repository 인터페이스
abstract class AuthRepository {
  // 인증 관련
  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail(String email);
}
```

### Auth Repository 구현체 (실제 구현)

```dart
// data/repository_impl/auth_repository_impl.dart
import '../../../core/result/result.dart';
import '../../core/errors/failure.dart';
import '../../domain/model/user_model.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_datasource.dart';

/// Auth Repository 구현체
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl({
    required AuthDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // 입력 값 검증
      if (email.trim().isEmpty) {
        return Error(ValidationFailure('이메일은 필수입니다'));
      }
      if (password.trim().isEmpty) {
        return Error(ValidationFailure('비밀번호는 필수입니다'));
      }

      // DataSource를 통한 회원가입
      final userDto = await _dataSource.signUp(email.trim(), password);

      // DTO → Model 변환
      final userModel = userDto.toModel();

      return Success(userModel);
    } catch (e) {
      // 예외를 Result<T> 패턴으로 변환
      return Error(ServerFailure('회원가입 실패: ${e.toString()}'));
    }
  }
}
```

## ✅ Feature 템플릿 (일반화)

```dart
/// [Feature] Repository 인터페이스
abstract class [Feature]Repository {
  Future<Result<List<[Feature]Model>>> get[Feature]s();
  Future<Result<[Feature]Model>> get[Feature]ById(String id);
  Future<Result<void>> add[Feature]([Feature]Model model);
  Future<Result<void>> update[Feature]([Feature]Model model);
  Future<Result<void>> delete[Feature](String id);
}

/// [Feature] Repository 구현체
class [Feature]RepositoryImpl implements [Feature]Repository {
  final [Feature]DataSource _dataSource;

  [Feature]RepositoryImpl({
    required [Feature]DataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<[Feature]Model>> add[Feature]([Feature]Model model) async {
    try {
      // 입력 검증
      // DataSource 호출
      // DTO → Model 변환
      // Success 반환
    } catch (e) {
      // Error 반환
    }
  }
}
```

---

## 🎯 핵심 패턴

### Repository의 책임
1. **입력 검증**: 비즈니스 규칙에 따른 유효성 검사
2. **DataSource 호출**: 실제 데이터 I/O 작업 위임
3. **예외 처리**: DataSource 예외를 Result<T> 패턴으로 변환
4. **데이터 변환**: DTO → Domain Model 변환

### Result<T> 패턴 활용
```dart
// 성공 시
return Success(userModel);

// 실패 시
return Error(ValidationFailure('입력값이 잘못되었습니다'));
return Error(ServerFailure('서버 오류가 발생했습니다'));
```

### 의존성 주입 (Provider)
```dart
Provider<AuthRepository>(
  create: (context) => AuthRepositoryImpl(
    dataSource: context.read<AuthDataSource>(),
  ),
),
```

---

> 📎 UseCase에서의 Repository 활용은 [usecase.md](usecase.md) 참조

---
