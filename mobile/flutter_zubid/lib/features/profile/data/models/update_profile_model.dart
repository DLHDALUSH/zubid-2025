import 'package:json_annotation/json_annotation.dart';

part 'update_profile_model.g.dart';

@JsonSerializable()
class UpdateProfileRequestModel {
  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'id_number')
  final String? idNumber;

  final String? address;
  final String? city;
  final String? country;

  @JsonKey(name: 'postal_code')
  final String? postalCode;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth; // ISO string format

  final String? bio;

  @JsonKey(name: 'preferred_language')
  final String? preferredLanguage;

  final String? timezone;

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
    this.preferredLanguage,
    this.timezone,
  });

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestModelToJson(this);

  @override
  String toString() => 'UpdateProfileRequestModel(firstName: $firstName, lastName: $lastName)';
}

@JsonSerializable()
class UpdateProfileResponseModel {
  final bool success;
  final String message;
  final ProfileData? profile;
  final Map<String, dynamic>? errors;

  const UpdateProfileResponseModel({
    required this.success,
    required this.message,
    this.profile,
    this.errors,
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

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;

  @JsonKey(name: 'id_number')
  final String? idNumber;

  final String? address;
  final String? city;
  final String? country;

  @JsonKey(name: 'postal_code')
  final String? postalCode;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  final String? bio;

  @JsonKey(name: 'preferred_language')
  final String? preferredLanguage;

  final String? timezone;

  @JsonKey(name: 'email_verified')
  final bool emailVerified;

  @JsonKey(name: 'phone_verified')
  final bool phoneVerified;

  @JsonKey(name: 'profile_completed')
  final bool profileCompleted;

  final double? rating;

  @JsonKey(name: 'total_bids')
  final int totalBids;

  @JsonKey(name: 'total_wins')
  final int totalWins;

  @JsonKey(name: 'total_spent')
  final double totalSpent;

  @JsonKey(name: 'member_since')
  final String memberSince;

  @JsonKey(name: 'last_active')
  final String? lastActive;

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
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}

@JsonSerializable()
class UploadPhotoRequestModel {
  @JsonKey(name: 'photo_file')
  final String photoFile; // Base64 encoded image

  @JsonKey(name: 'file_name')
  final String fileName;

  @JsonKey(name: 'file_type')
  final String fileType;

  const UploadPhotoRequestModel({
    required this.photoFile,
    required this.fileName,
    required this.fileType,
  });

  factory UploadPhotoRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UploadPhotoRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UploadPhotoRequestModelToJson(this);
}

@JsonSerializable()
class UploadPhotoResponseModel {
  final bool success;
  final String message;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  final Map<String, dynamic>? errors;

  const UploadPhotoResponseModel({
    required this.success,
    required this.message,
    this.photoUrl,
    this.errors,
  });

  factory UploadPhotoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UploadPhotoResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UploadPhotoResponseModelToJson(this);
}
