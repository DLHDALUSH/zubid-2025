// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileResponseModel _$UpdateProfileResponseModelFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      profile: json['profile'] == null
          ? null
          : ProfileData.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateProfileResponseModelToJson(
        UpdateProfileResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'profile': instance.profile,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      idNumber: json['idNumber'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      bio: json['bio'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      timezone: json['timezone'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalBids: (json['totalBids'] as num?)?.toInt() ?? 0,
      totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      memberSince: json['memberSince'] as String,
      lastActive: json['lastActive'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'idNumber': instance.idNumber,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'dateOfBirth': instance.dateOfBirth,
      'bio': instance.bio,
      'preferredLanguage': instance.preferredLanguage,
      'timezone': instance.timezone,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'profileCompleted': instance.profileCompleted,
      'rating': instance.rating,
      'totalBids': instance.totalBids,
      'totalWins': instance.totalWins,
      'totalSpent': instance.totalSpent,
      'memberSince': instance.memberSince,
      'lastActive': instance.lastActive,
      'preferences': instance.preferences,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
