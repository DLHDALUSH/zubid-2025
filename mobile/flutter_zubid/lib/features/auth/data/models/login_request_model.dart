import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  final String username;
  final String password;
  @JsonKey(name: 'remember_me')
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


