// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestModel _$RegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    RegisterRequestModel(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phoneNumber: json['phone'] as String,
      idNumber: json['id_number'] as String,
      birthDate: json['birth_date'] as String,
      address: json['address'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      acceptTerms: json['acceptTerms'] as bool? ?? false,
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
        RegisterRequestModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'phone': instance.phoneNumber,
      'id_number': instance.idNumber,
      'birth_date': instance.birthDate,
      'address': instance.address,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'city': instance.city,
      'country': instance.country,
      'acceptTerms': instance.acceptTerms,
    };
