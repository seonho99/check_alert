/// `Result<T>` 패턴 - 함수형 에러 처리
///
/// 모든 Repository/UseCase 반환 타입으로 사용
/// [Success]와 [Error]를 구분하여 안전한 에러 처리 제공
sealed class Result<T> {
  const Result();

  /// 성공/실패 분기 처리
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Error<T>(:final failure) => error(failure),
    };
  }

  /// 성공 여부 확인
  bool get isSuccess => this is Success<T>;

  /// 실패 여부 확인
  bool get isError => this is Error<T>;

  /// 성공 데이터 추출 (null 가능)
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Error<T>() => null,
  };

  /// 실패 정보 추출 (null 가능)
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(:final failure) => failure,
  };
}

/// 성공 결과
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';
}

/// 실패 결과
class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  String toString() => 'Error(failure: $failure)';
}

/// Failure 기본 클래스
abstract class Failure {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType(message: $message)';
}
