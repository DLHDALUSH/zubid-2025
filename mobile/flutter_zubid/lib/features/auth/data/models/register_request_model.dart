import 'package:json_annotation/json_annotation.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final String? idNumber;
  final String? address;
  final String? city;
  final String? country;
  final bool acceptTerms;

  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.idNumber,
    this.address,
    this.city,
    this.country,
    this.acceptTerms = false,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}
