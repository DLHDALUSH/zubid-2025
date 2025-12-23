import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

part 'upload_photo_request_model.g.dart';

@JsonSerializable()
class UploadPhotoRequestModel {
  final String fileName;
  final String fileType;
  final int fileSize;

  const UploadPhotoRequestModel({
    required this.fileName,
    required this.fileType,
    required this.fileSize,
  });

  factory UploadPhotoRequestModel.fromFile(File file) {
    final fileName = file.path.split('/').last;
    final fileType = fileName.split('.').last.toLowerCase();
    final fileSize = file.lengthSync();

    return UploadPhotoRequestModel(
      fileName: fileName,
      fileType: fileType,
      fileSize: fileSize,
    );
  }

  factory UploadPhotoRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UploadPhotoRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UploadPhotoRequestModelToJson(this);
}
