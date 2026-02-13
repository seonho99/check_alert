import 'package:json_annotation/json_annotation.dart';

part 'user_model_dto.g.dart';

/// UserModel DTO (JsonSerializable)
/// 모든 필드 nullable - 외부 데이터의 불완전성 대응
@JsonSerializable()
class UserModelDto {
  final String? uid;
  final String? email;
  final String? displayName;
  final bool? isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModelDto({
    this.uid,
    this.email,
    this.displayName,
    this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModelDto.fromJson(Map<String, dynamic> json) =>
      _$UserModelDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelDtoToJson(this);

  UserModelDto copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModelDto(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
