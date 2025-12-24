// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyEmailRequestModel _$VerifyEmailRequestModelFromJson(
        Map<String, dynamic> json) =>
    VerifyEmailRequestModel(
      token: json['token'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$VerifyEmailRequestModelToJson(
        VerifyEmailRequestModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'email': instance.email,
    };
