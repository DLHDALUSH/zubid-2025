// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_photo_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadPhotoRequestModel _$UploadPhotoRequestModelFromJson(
        Map<String, dynamic> json) =>
    UploadPhotoRequestModel(
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
    );

Map<String, dynamic> _$UploadPhotoRequestModelToJson(
        UploadPhotoRequestModel instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
    };
