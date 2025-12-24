import 'package:json_annotation/json_annotation.dart';

part 'update_profile_response_model.g.dart';

@JsonSerializable()
class UpdateProfileResponseModel {
  final bool success;
  final String message;
  final ProfileData? profile;

  const UpdateProfileResponseModel({
    required this.success,
    required this.message,
    this.profile,
  });

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileResponseModelToJson(this);
}

@JsonSerializable()
class ProfileData {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final String? idNumber;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? dateOfBirth;
  final String? bio;
  final String? preferredLanguage;
  final String? timezone;
  final bool emailVerified;
  final bool phoneVerified;
  final bool profileCompleted;
  final double? rating;
  final int totalBids;
  final int totalWins;
  final double totalSpent;
  final String memberSince;
  final String? lastActive;
  final Map<String, dynamic>? preferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileData({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePhotoUrl,
    this.idNumber,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.dateOfBirth,
    this.bio,
    this.preferredLanguage,
    this.timezone,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.profileCompleted = false,
    this.rating,
    this.totalBids = 0,
    this.totalWins = 0,
    this.totalSpent = 0.0,
    required this.memberSince,
    this.lastActive,
    this.preferences,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}
