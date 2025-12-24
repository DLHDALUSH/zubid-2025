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

  /// Custom fromJson that handles backend's session-based response format
  /// Backend returns: { "message": "Login successful", "user": {...} }
  /// Or error: { "error": "Invalid credentials" }
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Check if this is a successful login (has 'user' and 'message', no 'error')
    final hasUser = json['user'] != null;
    final hasError = json['error'] != null;
    final message = json['message'] as String? ?? json['error'] as String? ?? '';

    // Determine success based on presence of user and absence of error
    final success = hasUser && !hasError;

    return AuthResponseModel(
      success: json['success'] as bool? ?? success,
      message: message,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String? ?? json['refresh_token'] as String?,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  @override
  String toString() {
    return 'AuthResponseModel(success: $success, message: $message, hasToken: ${token != null}, hasUser: ${user != null})';
  }
}


