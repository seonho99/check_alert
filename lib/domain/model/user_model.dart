import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

/// 사용자 도메인 모델 (순수한 데이터 구조체)
///
/// Clean Architecture 원칙에 따라:
/// - 검증 로직 없음 (UseCase에서 처리)
/// - 비즈니스 로직 없음 (Domain Services에서 처리)
/// - 기술에 독립적인 순수 도메인 개념만 포함
@freezed
sealed class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    required bool isEmailVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;
}

/// UserModel 편의 확장 (단순한 getter만)
extension UserModelExtension on UserModel {
  /// 표시 이름이 있는지 확인
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// 표시할 이름 반환 (표시 이름이 없으면 이메일 사용)
  String get displayNameOrEmail => displayName ?? email;
}
