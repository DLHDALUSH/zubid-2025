import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../presentation/widgets/seller_info_card.dart';

part 'auction_model.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class AuctionModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  @JsonKey(name: 'starting_price')
  final double startingPrice;

  @HiveField(4)
  @JsonKey(name: 'current_price')
  final double currentPrice;

  @HiveField(5)
  @JsonKey(name: 'buy_now_price')
  final double? buyNowPrice;

  @HiveField(6)
  @JsonKey(name: 'reserve_price')
  final double? reservePrice;

  @HiveField(7)
  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @HiveField(8)
  @JsonKey(name: 'end_time')
  final DateTime endTime;

  @HiveField(9)
  final String status;

  @HiveField(10)
  @JsonKey(name: 'category_id')
  final int categoryId;

  @HiveField(11)
  @JsonKey(name: 'category_name')
  final String categoryName;

  @HiveField(12)
  @JsonKey(name: 'seller_id')
  final int sellerId;

  @HiveField(13)
  @JsonKey(name: 'seller_username')
  final String sellerUsername;

  @HiveField(14)
  @JsonKey(name: 'seller_rating')
  final double? sellerRating;

  @HiveField(15)
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;

  @HiveField(16)
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @HiveField(17)
  @JsonKey(name: 'bid_count')
  final int bidCount;

  @HiveField(18)
  @JsonKey(name: 'view_count')
  final int viewCount;

  @HiveField(19)
  @JsonKey(name: 'watch_count')
  final int watchCount;

  @HiveField(20)
  @JsonKey(name: 'is_featured')
  final bool isFeatured;

  @HiveField(21)
  @JsonKey(name: 'is_watched')
  final bool isWatched;

  @HiveField(22)
  @JsonKey(name: 'shipping_cost')
  final double? shippingCost;

  @HiveField(23)
  @JsonKey(name: 'shipping_info')
  final String? shippingInfo;

  @HiveField(24)
  @JsonKey(name: 'condition')
  final String? condition;

  @HiveField(25)
  @JsonKey(name: 'location')
  final String? location;

  @HiveField(26)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(27)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Additional seller fields
  @HiveField(28)
  @JsonKey(name: 'seller_avatar')
  final String? sellerAvatar;

  @HiveField(29)
  @JsonKey(name: 'seller_verified')
  final bool? sellerVerified;

  // Additional shipping fields
  @HiveField(30)
  @JsonKey(name: 'shipping_method')
  final String? shippingMethod;

  @HiveField(31)
  @JsonKey(name: 'estimated_delivery')
  final String? estimatedDelivery;

  @HiveField(32)
  @JsonKey(name: 'ships_from')
  final String? shipsFrom;

  @HiveField(33)
  @JsonKey(name: 'ships_to')
  final String? shipsTo;

  @HiveField(34)
  @JsonKey(name: 'handling_time')
  final String? handlingTime;

  @HiveField(35)
  @JsonKey(name: 'return_policy')
  final String? returnPolicy;

  @HiveField(36)
  @JsonKey(name: 'shipping_notes')
  final String? shippingNotes;

  // Additional computed properties
  @HiveField(37)
  @JsonKey(name: 'images')
  final List<String>? images;

  @HiveField(38)
  @JsonKey(name: 'minimum_bid')
  final double? minimumBid;

  @HiveField(39)
  @JsonKey(name: 'current_bid')
  final double? currentBid;

  @HiveField(40)
  @JsonKey(name: 'has_sold')
  final bool? hasSold;

  AuctionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.currentPrice,
    this.buyNowPrice,
    this.reservePrice,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.categoryId,
    required this.categoryName,
    required this.sellerId,
    required this.sellerUsername,
    this.sellerRating,
    required this.imageUrls,
    this.thumbnailUrl,
    required this.bidCount,
    required this.viewCount,
    required this.watchCount,
    required this.isFeatured,
    required this.isWatched,
    this.shippingCost,
    this.shippingInfo,
    this.condition,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.sellerAvatar,
    this.sellerVerified,
    this.shippingMethod,
    this.estimatedDelivery,
    this.shipsFrom,
    this.shipsTo,
    this.handlingTime,
    this.returnPolicy,
    this.shippingNotes,
    this.images,
    this.minimumBid,
    this.currentBid,
    this.hasSold,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) => _$AuctionModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuctionModelToJson(this);

  // Computed properties
  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  bool get hasEnded => DateTime.now().isAfter(endTime);
  bool get hasStarted => DateTime.now().isAfter(startTime);
  bool get isLive => hasStarted && !hasEnded && isActive;

  Duration get timeRemaining => hasEnded ? Duration.zero : endTime.difference(DateTime.now());
  Duration get timeSinceStart => hasStarted ? DateTime.now().difference(startTime) : Duration.zero;

  bool get hasBuyNow => buyNowPrice != null && buyNowPrice! > 0;
  bool get hasReserve => reservePrice != null && reservePrice! > 0;
  bool get reserveMet => hasReserve ? currentPrice >= reservePrice! : true;

  String get primaryImageUrl => thumbnailUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : '');
  bool get hasImages => imageUrls.isNotEmpty;

  String get timeRemainingText {
    if (hasEnded) return 'Ended';
    if (!hasStarted) return 'Not started';
    
    final duration = timeRemaining;
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'active':
        return isLive ? 'Live' : hasEnded ? 'Ended' : 'Scheduled';
      case 'ended':
        return 'Ended';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Seller information
  SellerInfo get seller => SellerInfo(
    id: sellerId,
    username: sellerUsername ?? 'Unknown',
    avatar: sellerAvatar,
    isVerified: sellerVerified ?? false,
    rating: sellerRating,
    reviewCount: 0, // TODO: Add review count field
    memberSince: createdAt, // TODO: Add proper member since date
    activeAuctions: 0, // TODO: Add active auctions count
    totalSales: 0, // TODO: Add total sales count
    successRate: 0.0, // TODO: Add success rate
  );

  // Shipping properties with defaults
  double get shippingCostValue => shippingCost ?? 0.0;
  String get shippingMethodValue => shippingMethod ?? '';
  String get estimatedDeliveryValue => estimatedDelivery ?? '';
  String get shipsFromValue => shipsFrom ?? '';
  String get shipsToValue => shipsTo ?? '';
  String get handlingTimeValue => handlingTime ?? '';
  String get returnPolicyValue => returnPolicy ?? '';
  String get shippingNotesValue => shippingNotes ?? '';

  // Formatted price getters
  String get formattedBuyNowPrice => buyNowPrice != null ? '\$${buyNowPrice!.toStringAsFixed(2)}' : 'N/A';
  String get formattedCurrentBid => currentBid != null ? '\$${currentBid!.toStringAsFixed(2)}' : 'N/A';
  String get formattedMinimumBid => minimumBid != null ? '\$${minimumBid!.toStringAsFixed(2)}' : 'N/A';

  // Shipping object for compatibility
  ShippingInfo get shipping => ShippingInfo(
    hasShippingCost: shippingCost != null && shippingCost! > 0,
    shippingCost: shippingCost ?? 0.0,
    hasReturnPolicy: returnPolicy != null && returnPolicy!.isNotEmpty,
    returnPolicy: returnPolicy ?? '',
  );

  AuctionModel copyWith({
    int? id,
    String? title,
    String? description,
    double? startingPrice,
    double? currentPrice,
    double? buyNowPrice,
    double? reservePrice,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    int? categoryId,
    String? categoryName,
    int? sellerId,
    String? sellerUsername,
    double? sellerRating,
    List<String>? imageUrls,
    String? thumbnailUrl,
    int? bidCount,
    int? viewCount,
    int? watchCount,
    bool? isFeatured,
    bool? isWatched,
    double? shippingCost,
    String? shippingInfo,
    String? condition,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuctionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startingPrice: startingPrice ?? this.startingPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      buyNowPrice: buyNowPrice ?? this.buyNowPrice,
      reservePrice: reservePrice ?? this.reservePrice,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      sellerId: sellerId ?? this.sellerId,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      sellerRating: sellerRating ?? this.sellerRating,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      bidCount: bidCount ?? this.bidCount,
      viewCount: viewCount ?? this.viewCount,
      watchCount: watchCount ?? this.watchCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isWatched: isWatched ?? this.isWatched,
      shippingCost: shippingCost ?? this.shippingCost,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Helper class for shipping information compatibility
class ShippingInfo {
  final bool hasShippingCost;
  final double shippingCost;
  final bool hasReturnPolicy;
  final String returnPolicy;

  const ShippingInfo({
    required this.hasShippingCost,
    required this.shippingCost,
    required this.hasReturnPolicy,
    required this.returnPolicy,
  });
}
