// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileRequestModel _$UpdateProfileRequestModelFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileRequestModel(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      idNumber: json['idNumber'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$UpdateProfileRequestModelToJson(
        UpdateProfileRequestModel instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'idNumber': instance.idNumber,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'dateOfBirth': instance.dateOfBirth,
      'bio': instance.bio,
      'profilePicture': instance.profilePicture,
    };
