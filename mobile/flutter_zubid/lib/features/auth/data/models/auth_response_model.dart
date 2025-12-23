import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;
  final UserModel? user;
  final Map<String, dynamic>? errors;

  const AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.user,
    this.errors,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  @override
  String toString() {
    return 'AuthResponseModel(success: $success, message: $message, hasToken: ${token != null}, hasUser: ${user != null})';
  }
}

@JsonSerializable()
class LoginRequestModel {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginRequestModel({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}

@JsonSerializable()
class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? idNumber;
  final bool acceptTerms;

  const RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.idNumber,
    this.acceptTerms = false,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequestModel {
  final String email;

  const ForgotPasswordRequestModel({
    required this.email,
  });

  factory ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestModelToJson(this);
}

@JsonSerializable()
class ResetPasswordRequestModel {
  final String token;
  final String password;
  final String confirmPassword;

  const ResetPasswordRequestModel({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestModelToJson(this);
}

@JsonSerializable()
class ChangePasswordRequestModel {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestModelToJson(this);
}

@JsonSerializable()
class RefreshTokenRequestModel {
  final String refreshToken;

  const RefreshTokenRequestModel({
    required this.refreshToken,
  });

  factory RefreshTokenRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestModelToJson(this);
}

@JsonSerializable()
class VerifyEmailRequestModel {
  final String token;

  const VerifyEmailRequestModel({
    required this.token,
  });

  factory VerifyEmailRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestModelToJson(this);
}

@JsonSerializable()
class ResendVerificationRequestModel {
  final String email;

  const ResendVerificationRequestModel({
    required this.email,
  });

  factory ResendVerificationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResendVerificationRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResendVerificationRequestModelToJson(this);
}
