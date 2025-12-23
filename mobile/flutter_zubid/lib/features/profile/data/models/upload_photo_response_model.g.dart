// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_photo_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadPhotoResponseModel _$UploadPhotoResponseModelFromJson(
        Map<String, dynamic> json) =>
    UploadPhotoResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$UploadPhotoResponseModelToJson(
        UploadPhotoResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'photoUrl': instance.photoUrl,
    };
