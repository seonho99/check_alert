# 🎯 Result 패턴 설계 가이드

---

## ✅ 목적

**Repository와 UseCase**에서 성공/실패를 타입 안전하게 처리하기 위해 Result 패턴을 사용합니다.

- Repository는 항상 `Result<T>` 반환
- UseCase는 Repository의 `Result<T>`를 그대로 전달
- ViewModel에서 Result 패턴 매칭으로 상태 업데이트
- 예외 대신 흐름 기반 에러 처리로 테스트성과 추적성 향상

---

## ✅ 설계 원칙

- Result는 `Success<T>`와 `Error(Failure)` 두 가지 형태의 sealed class
- DataSource는 Exception throw, Repository는 이를 catch하여 Result로 변환
- UseCase는 Repository의 `Result<T>`를 그대로 반환
- ViewModel은 패턴 매칭으로 Result 처리 후 State 업데이트
- FailureMapper로 일관된 예외 → Failure 변환

---

## ✅ 흐름 구조 요약

```text
DataSource      → throws Exception
Repository      → try-catch → FailureMapper → Result<T>
UseCase         → Result<T> 그대로 반환
ViewModel       → Result 패턴 매칭 → Freezed State 업데이트 → notifyListeners()
View            → Consumer → State 구독 → 상태별 UI 렌더링
```

---

## ✅ Result 클래스 정의

```dart
/// 성공/실패를 타입 안전하게 처리하는 Result 패턴
sealed class Result<T> {
  const Result();
}

/// 성공 결과
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// 실패 결과
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
```

---

## ✅ Result 패턴 매칭 활용

```dart
// ✅ when() 메서드 (권장)
result.when(
  success: (data) {
    // 성공 처리
  },
  error: (failure) {
    // 실패 처리
  },
);

// fold() - 다른 타입으로 변환
final message = result.fold(
  onSuccess: (data) => '성공: $data',
  onError: (failure) => '실패: ${failure.message}',
);
```

### Extension 메서드들

```dart
// 상태 확인
result.isSuccess;     // 성공 여부
result.isError;       // 실패 여부

// 데이터 접근
result.dataOrNull;    // 성공 시 데이터, 실패 시 null
result.failureOrNull; // 실패 시 Failure, 성공 시 null
result.dataOrThrow;   // 성공 시 데이터, 실패 시 Exception throw

// 데이터 변환
result.map((data) => transformData(data));       // 동기 변환
result.mapAsync((data) => asyncTransform(data)); // 비동기 변환

// 체이닝
result
  .onSuccess((data) => print('성공: $data'))
  .onError((failure) => print('실패: ${failure.message}'));
```

---

## ✅ Failure 클래스 정의

```dart
/// Failure 추상 클래스
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// 서버 에러
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// 검증 에러
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// 권한 에러
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

/// Firebase 에러
class FirebaseFailure extends Failure {
  const FirebaseFailure(super.message);
}

/// 알 수 없는 오류
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
```

---

## ✅ Exception 클래스 정의

```dart
/// DataSource에서 사용하는 예외들
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

/// 네트워크 예외
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// 서버 예외
class ServerException extends AppException {
  const ServerException(super.message);
}

/// 캐시 예외
class CacheException extends AppException {
  const CacheException(super.message);
}

/// 검증 예외
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// 권한 예외
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}
```

---

## ✅ FailureMapper 활용

```dart
/// Exception을 Failure로 변환하는 유틸리티
class FailureMapper {
  static Failure mapExceptionToFailure(Object error) {
    // 커스텀 예외 변환
    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is ServerException) return ServerFailure(error.message);
    if (error is CacheException) return CacheFailure(error.message);
    if (error is ValidationException) return ValidationFailure(error.message);
    if (error is UnauthorizedException) return UnauthorizedFailure(error.message);

    // 시스템 예외 변환
    if (error is SocketException) return NetworkFailure('네트워크 연결 오류');
    if (error is TimeoutException) return NetworkFailure('요청 시간 초과');
    if (error is FormatException) return ServerFailure('데이터 형식 오류');

    // 기타 예외
    return UnknownFailure('알 수 없는 오류: ${error.toString()}');
  }
}
```

---

## ✅ Repository에서 Result 사용

```dart
class [Feature]RepositoryImpl implements [Feature]Repository {
  final [Feature]DataSource _dataSource;

  @override
  Future<Result<[Model]>> get[Model]() async {
    try {
      final dto = await _dataSource.get[Model]();
      return Success(dto.toModel());
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> add[Model]([Model] model) async {
    try {
      await _dataSource.add[Model](model.toDto());
      return const Success(null);
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }
}
```

---

## ✅ UseCase에서 Result 처리

```dart
class [Action][Model]UseCase {
  final [Feature]Repository _repository;

  [Action][Model]UseCase({required [Feature]Repository repository})
      : _repository = repository;

  Future<Result<[ReturnType]>> call([Parameters]) async {
    return await _repository.[method]([parameters]);
  }
}
```

---

## ✅ ViewModel에서 Result 처리

```dart
class [Feature]ViewModel extends ChangeNotifier {
  final [Action][Model]UseCase _useCase;

  [Feature]State _state = [Feature]State.initial();
  [Feature]State get state => _state;

  void _updateState([Feature]State newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> [actionMethod]() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _useCase();

    result.when(
      success: (data) {
        _updateState(_state.copyWith(
          data: data,
          isLoading: false,
          errorMessage: null,
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return '인터넷 연결을 확인해주세요';
    } else if (failure is UnauthorizedFailure) {
      return '인증 오류가 발생했습니다';
    } else if (failure is FirebaseFailure) {
      return _translateFirebaseError(failure.message);
    } else {
      return '오류가 발생했습니다: ${failure.message}';
    }
  }
}
```

---

## ✅ View에서 State 처리

```dart
class [Feature]View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[Feature]')),
      body: Consumer<[Feature]ViewModel>(
        builder: (context, viewModel, child) {
          return switch (viewModel.state) {
            [Feature]State(isLoading: true) =>
              const Center(child: CircularProgressIndicator()),

            [Feature]State(errorMessage: final error?) =>
              Center(child: Text(error)),

            [Feature]State(data: final data, isLoading: false) =>
              data.isEmpty
                ? const Center(child: Text('데이터가 없습니다'))
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) =>
                      [Feature]Card(item: data[index]),
                  ),
          };
        },
      ),
    );
  }
}
```

---

## ✅ 흐름 요약

| 단계         | 처리 방식                          |
|------------|-----------------------------------|
| DataSource | Exception throw                   |
| Repository | try-catch → FailureMapper → `Result<T>` |
| UseCase    | `Result<T>` 그대로 반환           |
| ViewModel  | `result.when()` → State 업데이트 → notifyListeners() |
| View       | Consumer + switch expression → 상태별 UI 렌더링 |

---

## ✅ Result 패턴의 장점

1. **타입 안전성**: 컴파일 타임에 에러 처리 강제
2. **일관된 예외 처리**: Exception → Failure → 사용자 메시지
3. **테스트 가능성**: 예외 흐름을 쉽게 테스트 가능
4. **체이닝 지원**: `onSuccess()`, `onError()`로 유연한 처리
5. **변환 지원**: `map()`, `mapAsync()`로 데이터 변환

---