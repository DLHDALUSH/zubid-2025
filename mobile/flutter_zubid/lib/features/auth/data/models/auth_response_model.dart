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


