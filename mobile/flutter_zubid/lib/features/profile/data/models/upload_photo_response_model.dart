import 'package:json_annotation/json_annotation.dart';

part 'upload_photo_response_model.g.dart';

@JsonSerializable()
class UploadPhotoResponseModel {
  final bool success;
  final String message;
  final String? photoUrl;

  const UploadPhotoResponseModel({
    required this.success,
    required this.message,
    this.photoUrl,
  });

  factory UploadPhotoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UploadPhotoResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UploadPhotoResponseModelToJson(this);
}
