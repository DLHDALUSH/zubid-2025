import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bid_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class BidModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  @JsonKey(name: 'auction_id')
  final int auctionId;

  @HiveField(2)
  @JsonKey(name: 'user_id')
  final int userId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(5)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(6)
  @JsonKey(name: 'is_winning')
  final bool isWinning;

  @HiveField(7)
  @JsonKey(name: 'is_auto_bid')
  final bool isAutoBid;

  @HiveField(8)
  @JsonKey(name: 'max_bid_amount')
  final double? maxBidAmount;

  // User information
  @HiveField(9)
  @JsonKey(name: 'user_username')
  final String username;

  @HiveField(10)
  @JsonKey(name: 'user_avatar')
  final String? userAvatar;

  @HiveField(11)
  @JsonKey(name: 'user_rating')
  final double? userRating;

  const BidModel({
    required this.id,
    required this.auctionId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.isWinning = false,
    this.isAutoBid = false,
    this.maxBidAmount,
    required this.username,
    this.userAvatar,
    this.userRating,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) => _$BidModelFromJson(json);
  Map<String, dynamic> toJson() => _$BidModelToJson(this);

  // Computed properties
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get bidType => isAutoBid ? 'Auto Bid' : 'Manual Bid';
  
  bool get hasUserAvatar => userAvatar != null && userAvatar!.isNotEmpty;
  
  String get displayUsername {
    // Mask username for privacy (show first 2 and last 2 characters)
    if (username.length <= 4) {
      return username;
    }
    return '${username.substring(0, 2)}***${username.substring(username.length - 2)}';
  }

  BidModel copyWith({
    int? id,
    int? auctionId,
    int? userId,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isWinning,
    bool? isAutoBid,
    double? maxBidAmount,
    String? username,
    String? userAvatar,
    double? userRating,
  }) {
    return BidModel(
      id: id ?? this.id,
      auctionId: auctionId ?? this.auctionId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isWinning: isWinning ?? this.isWinning,
      isAutoBid: isAutoBid ?? this.isAutoBid,
      maxBidAmount: maxBidAmount ?? this.maxBidAmount,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      userRating: userRating ?? this.userRating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BidModel(id: $id, auctionId: $auctionId, amount: $amount, username: $username, isWinning: $isWinning)';
  }
}

// Bid Request Model for API calls
@JsonSerializable()
class PlaceBidRequest {
  @JsonKey(name: 'auction_id')
  final String auctionId;
  
  final double amount;
  
  @JsonKey(name: 'is_auto_bid')
  final bool isAutoBid;
  
  @JsonKey(name: 'max_bid_amount')
  final double? maxBidAmount;

  const PlaceBidRequest({
    required this.auctionId,
    required this.amount,
    this.isAutoBid = false,
    this.maxBidAmount,
  });

  factory PlaceBidRequest.fromJson(Map<String, dynamic> json) => _$PlaceBidRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceBidRequestToJson(this);
}

// Buy Now Request Model
@JsonSerializable()
class BuyNowRequest {
  @JsonKey(name: 'auction_id')
  final String auctionId;

  const BuyNowRequest({
    required this.auctionId,
  });

  factory BuyNowRequest.fromJson(Map<String, dynamic> json) => _$BuyNowRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BuyNowRequestToJson(this);
}
