// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileRequestModel _$UpdateProfileRequestModelFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileRequestModel(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      idNumber: json['id_number'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      bio: json['bio'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$UpdateProfileRequestModelToJson(
        UpdateProfileRequestModel instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'id_number': instance.idNumber,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'postal_code': instance.postalCode,
      'date_of_birth': instance.dateOfBirth,
      'bio': instance.bio,
      'preferred_language': instance.preferredLanguage,
      'timezone': instance.timezone,
    };

UpdateProfileResponseModel _$UpdateProfileResponseModelFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      profile: json['profile'] == null
          ? null
          : ProfileData.fromJson(json['profile'] as Map<String, dynamic>),
      errors: json['errors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateProfileResponseModelToJson(
        UpdateProfileResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'profile': instance.profile,
      'errors': instance.errors,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      idNumber: json['id_number'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      bio: json['bio'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      timezone: json['timezone'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      profileCompleted: json['profile_completed'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalBids: json['total_bids'] as int? ?? 0,
      totalWins: json['total_wins'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      memberSince: json['member_since'] as String,
      lastActive: json['last_active'] as String?,
    );

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'profile_photo_url': instance.profilePhotoUrl,
      'id_number': instance.idNumber,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'postal_code': instance.postalCode,
      'date_of_birth': instance.dateOfBirth,
      'bio': instance.bio,
      'preferred_language': instance.preferredLanguage,
      'timezone': instance.timezone,
      'email_verified': instance.emailVerified,
      'phone_verified': instance.phoneVerified,
      'profile_completed': instance.profileCompleted,
      'rating': instance.rating,
      'total_bids': instance.totalBids,
      'total_wins': instance.totalWins,
      'total_spent': instance.totalSpent,
      'member_since': instance.memberSince,
      'last_active': instance.lastActive,
    };

UploadPhotoRequestModel _$UploadPhotoRequestModelFromJson(
        Map<String, dynamic> json) =>
    UploadPhotoRequestModel(
      photoFile: json['photo_file'] as String,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String,
    );

Map<String, dynamic> _$UploadPhotoRequestModelToJson(
        UploadPhotoRequestModel instance) =>
    <String, dynamic>{
      'photo_file': instance.photoFile,
      'file_name': instance.fileName,
      'file_type': instance.fileType,
    };

UploadPhotoResponseModel _$UploadPhotoResponseModelFromJson(
        Map<String, dynamic> json) =>
    UploadPhotoResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      photoUrl: json['photo_url'] as String?,
      errors: json['errors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UploadPhotoResponseModelToJson(
        UploadPhotoResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'photo_url': instance.photoUrl,
      'errors': instance.errors,
    };
