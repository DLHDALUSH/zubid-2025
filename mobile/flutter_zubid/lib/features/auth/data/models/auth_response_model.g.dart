// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      errors: json['errors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'token': instance.token,
      'refresh_token': instance.refreshToken,
      'user': instance.user,
      'errors': instance.errors,
    };

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      username: json['username'] as String,
      password: json['password'] as String,
      rememberMe: json['remember_me'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'remember_me': instance.rememberMe,
    };

RegisterRequestModel _$RegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    RegisterRequestModel(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirm_password'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      idNumber: json['id_number'] as String?,
      acceptTerms: json['accept_terms'] as bool? ?? false,
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
        RegisterRequestModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'confirm_password': instance.confirmPassword,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'id_number': instance.idNumber,
      'accept_terms': instance.acceptTerms,
    };

ForgotPasswordRequestModel _$ForgotPasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequestModel(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ForgotPasswordRequestModelToJson(
        ForgotPasswordRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

ResetPasswordRequestModel _$ResetPasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ResetPasswordRequestModel(
      token: json['token'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );

Map<String, dynamic> _$ResetPasswordRequestModelToJson(
        ResetPasswordRequestModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'password': instance.password,
      'confirm_password': instance.confirmPassword,
    };

ChangePasswordRequestModel _$ChangePasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordRequestModel(
      currentPassword: json['current_password'] as String,
      newPassword: json['new_password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );

Map<String, dynamic> _$ChangePasswordRequestModelToJson(
        ChangePasswordRequestModel instance) =>
    <String, dynamic>{
      'current_password': instance.currentPassword,
      'new_password': instance.newPassword,
      'confirm_password': instance.confirmPassword,
    };

RefreshTokenRequestModel _$RefreshTokenRequestModelFromJson(
        Map<String, dynamic> json) =>
    RefreshTokenRequestModel(
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestModelToJson(
        RefreshTokenRequestModel instance) =>
    <String, dynamic>{
      'refresh_token': instance.refreshToken,
    };

VerifyEmailRequestModel _$VerifyEmailRequestModelFromJson(
        Map<String, dynamic> json) =>
    VerifyEmailRequestModel(
      token: json['token'] as String,
    );

Map<String, dynamic> _$VerifyEmailRequestModelToJson(
        VerifyEmailRequestModel instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

ResendVerificationRequestModel _$ResendVerificationRequestModelFromJson(
        Map<String, dynamic> json) =>
    ResendVerificationRequestModel(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ResendVerificationRequestModelToJson(
        ResendVerificationRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
    };
