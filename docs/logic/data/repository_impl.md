# 📚 Repository Implementation 패턴 가이드 (Auth 중심)

> **참조**: [Flutter Architecture Recommendations](https://docs.flutter.dev/app-architecture/recommendations)

## 개요

Repository Implementation은 **Clean Architecture의 Data Layer**에서 Domain Layer의 Repository 인터페이스를 구현하는 핵심 컴포넌트입니다.
외부 데이터소스(Firebase, API 등)와 도메인 비즈니스 로직 사이의 다리 역할을 하며,
**데이터 검증과 변환을 담당하는 핵심 계층**입니다.

> **Template Guide**: [Feature] 부분을 실제 기능명으로 변경하여 사용하세요.
> 예시: Auth, User, Product, Order 등

이 문서는: **Auth**(AuthRepository) 중심의 Repository Implementation 패턴
 
---

## 🧱 핵심 설계 원칙

- **Interface 구현**: Domain Repository 인터페이스를 완전 구현
- **DataSource 활용**: 외부 데이터소스를 DataSource를 통해 접근
- **Mapper 활용**: Extension Mapper로 DTO ↔ Entity 변환
- **Result<T> 패턴**: 모든 작업 결과를 Result<T> 패턴으로 반환
- **예외 처리**: try-catch로 예외를 Failure로 변환
- **입력 검증**: Repository 레벨에서 비즈니스 검증 수행

---

## 📁 파일 위치 및 네이밍 규칙

| 항목 | 규칙 |
|------|------|
| 파일 위치 | `lib/data/repository_impl/` |
| 파일명 | `{feature}_repository_impl.dart` (예: `auth_repository_impl.dart`) |
| 클래스명 | `{Feature}RepositoryImpl` (예: `AuthRepositoryImpl`) |
| 의존성 | DataSource, Mapper, FailureMapper |

---

## 🏗️ Repository Implementation 구조

### 1. 기본 Repository Implementation 템플릿

#### [Feature]RepositoryImpl (템플릿)

```dart
import '../../../core/result/result.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../core/errors/failure.dart';
import '../../domain/model/[feature]_model.dart';
import '../../domain/repository/[feature]_repository.dart';
import '../datasource/[feature]_datasource.dart';
import '../mapper/[feature]_mapper.dart';

class [Feature]RepositoryImpl implements [Feature]Repository {
  final [Feature]DataSource _dataSource;

  [Feature]RepositoryImpl({
    required [Feature]DataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<[Feature]Model>> get[Feature]() async {
    try {
      // 입력 검증 (필요시 수행)
      // if (condition) return Error(ValidationFailure('message'));

      // DataSource로 DTO 가져오기
      final dto = await _dataSource.get[Feature]();

      // Mapper로 DTO → Entity 변환
      final entity = dto.toModel();

      if (entity == null) {
        return Error(ServerFailure('[Feature] 데이터를 변환할 수 없습니다'));
      }

      return Success(entity);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> create[Feature]([Feature]Model [feature]) async {
    try {
      // Mapper로 Entity → DTO 변환
      final dto = [feature].toDto();

      // DataSource로 DTO 저장
      await _dataSource.create[Feature](dto);

      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }
}
```

### 2. 실제 예시: AuthRepositoryImpl (Auth 중심 구현)

```dart
import '../../../core/result/result.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../core/errors/failure.dart';
import '../../domain/model/user_model.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_datasource.dart';
import '../mapper/user_model_mapper.dart';

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
      // 비즈니스 입력 검증
      if (email.trim().isEmpty) {
        return Error(ValidationFailure('이메일은 필수입니다'));
      }
      if (password.trim().isEmpty) {
        return Error(ValidationFailure('비밀번호는 필수입니다'));
      }
      if (password.length < 6) {
        return Error(ValidationFailure('비밀번호는 6자 이상이어야 합니다'));
      }

      // Firebase Auth 회원가입 실행
      final uid = await _dataSource.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Extension Mapper로 UserModel 생성
      final user = uid.toUserModelWithUid(
        email: email.trim().toLowerCase(),
        displayName: displayName?.trim(),
        isEmailVerified: false,
      );

      // 사용자 Firestore에 추가 저장 (비동기처리)
      final userDto = user.toDto();
      _dataSource.saveUser(userDto).catchError((e) {
        print('사용자 Firestore 저장 실패(회원가입은 성공 완료): $e');
      });

      return Success(user);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final currentUserId = _dataSource.currentUserId;
      if (currentUserId == null) {
        return Error(UnauthorizedFailure('로그인이 필요합니다'));
      }

      // 사용자 Firestore에서 사용자 정보 조회
      final userDto = await _dataSource.getUser(currentUserId);

      // Extension Mapper로 DTO → Entity 변환
      final user = userDto.toModel();

      if (user == null) {
        return Error(ServerFailure('사용자 정보를 변환할 수 없습니다'));
      }

      return Success(user);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // 비즈니스 검증 로직
      if (currentPassword.trim().isEmpty) {
        return Error(ValidationFailure('현재 비밀번호는 필수입니다'));
      }
      if (newPassword.trim().isEmpty) {
        return Error(ValidationFailure('새 비밀번호는 필수입니다'));
      }
      if (newPassword.length < 6) {
        return Error(ValidationFailure('새 비밀번호는 6자 이상이어야 합니다'));
      }
      if (currentPassword == newPassword) {
        return Error(ValidationFailure('새 비밀번호는 현재 비밀번호와 달라야 합니다'));
      }

      await _dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  // 실시간 Stream 처리 패턴
  @override
  Stream<UserModel?> get authStateChanges {
    return _dataSource.authStateChanges.asyncMap((uid) async {
      if (uid == null) return null;

      try {
        final userDto = await _dataSource.getUser(uid);
        return userDto.toModel();
      } catch (e) {
        // 스트림 에러 발생시 null 반환
        return null;
      }
    });
  }

  // 간단한 Getter 패턴
  @override
  bool get isSignedIn => _dataSource.isSignedIn;

  @override
  String? get currentUserId => _dataSource.currentUserId;
}
```

---

## 🎯 핵심 Repository Implementation 패턴

### 1. **기본 패턴**
```dart
// 1. 입력 검증
if (condition) return Error(ValidationFailure('message'));

// 2. DataSource 호출
final result = await _dataSource.someMethod();

// 3. Mapper로 변환
final entity = result.toModel();

// 4. Success 반환
return Success(entity);
```

### 2. **Future 처리 패턴**
```dart
@override
Future<Result<List<[Feature]Model>>> getAll[Feature]s() async {
  try {
    final dtos = await _dataSource.getAll[Feature]s();
    final entities = dtos.toModelList();
    return Success(entities);
  } catch (e, stackTrace) {
    final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
    return Error(failure);
  }
}
```

## 📋 Repository Implementation 개발 가이드

### Auth 중심 핵심 원칙 (AuthRepositoryImpl 기준)
- **입력 검증**: Repository 레벨에서 비즈니스 검증 수행
- **예외 처리**: 모든 DataSource 호출을 try-catch로 감싸기
- **Mapper 활용**: Extension Mapper로 자연스러운 변환
- **Result<T> 패턴**: 모든 결과를 성공/실패로 구분
- **비즈니스 검증**: 복잡한 로직을 수행하지 말고 UseCase에 위임

### 구현 단계 가이드라인
1. **[Feature] 교체**: 실제 기능명으로 교체 (예: Auth, User, Product)
2. **DataSource 설정**: 해당 기능의 DataSource 의존성 주입
3. **Mapper 설정**: Extension Mapper로 DTO ↔ Entity 변환
4. **검증 로직**: 기본적인 입력 검증 수행
5. **예외 처리**: FailureMapper로 통합 에러 처리

### 구현 예시별 활용법
- **Auth Repository**: 로그인/회원가입 및 비밀번호 변경 등
- **CRUD Repository**: 기본적인 생성/조회/수정/삭제 작업

---

> 📎 관련 문서:
> - [DataSource 설계](datasource.md) - 외부 데이터 접근 계층
> - [Mapper 설계](mapper.md) - DTO ↔ Model 변환
> - [DTO 설계](dto.md) - 데이터 전송 객체
> - [Repository 인터페이스](../domain/repository.md) - Domain Layer 인터페이스

---

이 가이드는 **실제 구현된 AuthRepositoryImpl**을 중심으로 Auth 기능의 Repository Implementation 패턴을 설명하고 있습니다.