import 'package:json_annotation/json_annotation.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  @JsonKey(name: 'phone')
  final String phoneNumber;
  @JsonKey(name: 'id_number')
  final String idNumber;
  @JsonKey(name: 'birth_date')
  final String birthDate;
  final String address;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? city;
  final String? country;
  @JsonKey(name: 'accept_terms')
  final bool acceptTerms;

  const RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.idNumber,
    required this.birthDate,
    required this.address,
    this.firstName,
    this.lastName,
    this.city,
    this.country,
    this.acceptTerms = false,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}
