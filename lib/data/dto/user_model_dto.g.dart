// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModelDto _$UserModelDtoFromJson(Map<String, dynamic> json) => UserModelDto(
  uid: json['uid'] as String?,
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelDtoToJson(UserModelDto instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'isEmailVerified': instance.isEmailVerified,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
