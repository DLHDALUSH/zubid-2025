import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final int timestamp;
  final String type;
  @JsonKey(name: 'isRead')
  final bool isRead;
  @JsonKey(name: 'auctionId')
  final String? auctionId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = 'info',
    this.isRead = false,
    this.auctionId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(timestamp);

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    int? timestamp,
    String? type,
    bool? isRead,
    String? auctionId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      auctionId: auctionId ?? this.auctionId,
    );
  }

  // Get icon based on notification type
  String get iconName {
    switch (type) {
      case 'outbid':
        return 'trending_up';
      case 'won':
        return 'emoji_events';
      case 'ending':
        return 'timer';
      case 'payment':
        return 'payment';
      case 'shipping':
        return 'local_shipping';
      default:
        return 'notifications';
    }
  }
}

