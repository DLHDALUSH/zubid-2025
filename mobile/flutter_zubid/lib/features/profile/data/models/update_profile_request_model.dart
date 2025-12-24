import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request_model.g.dart';

@JsonSerializable()
class UpdateProfileRequestModel {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? idNumber;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? dateOfBirth;
  final String? bio;
  final String? profilePicture;

  const UpdateProfileRequestModel({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.idNumber,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.dateOfBirth,
    this.bio,
    this.profilePicture,
  });

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestModelToJson(this);
}
