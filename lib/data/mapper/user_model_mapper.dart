import '../../domain/model/user_model.dart';
import '../dto/user_model_dto.dart';

/// UserModelDto -> UserModel 변환
extension UserModelDtoMapper on UserModelDto? {
  UserModel? toModel() {
    final dto = this;
    if (dto == null) return null;

    return UserModel(
      uid: dto.uid ?? '',
      email: dto.email ?? '',
      displayName: dto.displayName,
      isEmailVerified: dto.isEmailVerified ?? false,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }
}

/// UserModel -> UserModelDto 변환
extension UserModelMapper on UserModel {
  UserModelDto toDto() {
    return UserModelDto(
      uid: uid,
      email: email,
      displayName: displayName,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// UID 문자열에서 UserModel 생성 (회원가입 시)
extension StringToUserModel on String {
  UserModel toUserModelWithUid({
    required String email,
    String? displayName,
    required bool isEmailVerified,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: this,
      email: email,
      displayName: displayName,
      isEmailVerified: isEmailVerified,
      createdAt: now,
      updatedAt: now,
    );
  }
}
