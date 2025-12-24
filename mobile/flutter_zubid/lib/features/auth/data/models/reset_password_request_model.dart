import 'package:json_annotation/json_annotation.dart';

part 'reset_password_request_model.g.dart';

@JsonSerializable()
class ResetPasswordRequestModel {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequestModel({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestModelToJson(this);

  @override
  String toString() {
    return 'ResetPasswordRequestModel(token: $token, newPassword: [HIDDEN], confirmPassword: [HIDDEN])';
  }
}
