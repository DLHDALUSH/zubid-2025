// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      type: json['type'] as String? ?? 'info',
      isRead: json['isRead'] as bool? ?? false,
      auctionId: json['auctionId'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'timestamp': instance.timestamp,
      'type': instance.type,
      'isRead': instance.isRead,
      'auctionId': instance.auctionId,
    };
