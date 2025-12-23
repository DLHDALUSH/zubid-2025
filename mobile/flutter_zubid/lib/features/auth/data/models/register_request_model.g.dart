// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestModel _$RegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    RegisterRequestModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phoneNumber: json['phoneNumber'] as String,
      idNumber: json['idNumber'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      acceptTerms: json['acceptTerms'] as bool? ?? false,
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
        RegisterRequestModel instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'password': instance.password,
      'phoneNumber': instance.phoneNumber,
      'idNumber': instance.idNumber,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'acceptTerms': instance.acceptTerms,
    };
