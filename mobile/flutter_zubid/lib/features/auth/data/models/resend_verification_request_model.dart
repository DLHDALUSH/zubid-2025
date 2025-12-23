import 'package:json_annotation/json_annotation.dart';

part 'resend_verification_request_model.g.dart';

@JsonSerializable()
class ResendVerificationRequestModel {
  final String email;

  const ResendVerificationRequestModel({
    required this.email,
  });

  factory ResendVerificationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResendVerificationRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResendVerificationRequestModelToJson(this);

  @override
  String toString() {
    return 'ResendVerificationRequestModel(email: $email)';
  }
}
