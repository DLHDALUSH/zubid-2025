import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/config/app_config.dart';
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

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    // Handle the API's mixed field naming and type inconsistencies
    return AuctionModel(
      id: _parseId(json['id']),
      title: json['title'] ?? json['item_name'] ?? '',
      description: json['description'] ?? '',
      startingPrice: _parseDouble(json['starting_price'] ??
          json['startingPrice'] ??
          json['starting_bid']),
      currentPrice: _parseDouble(
          json['current_price'] ?? json['currentPrice'] ?? json['current_bid']),
      buyNowPrice:
          _parseDoubleNullable(json['buy_now_price'] ?? json['buyNowPrice']),
      reservePrice:
          _parseDoubleNullable(json['reserve_price'] ?? json['reservePrice']),
      startTime: _parseDateTime(json['start_time'] ?? json['startTime']) ??
          DateTime.now(),
      endTime: _parseDateTime(json['end_time'] ?? json['endTime']) ??
          DateTime.now().add(const Duration(days: 7)),
      status: json['status'] ?? 'active',
      categoryId: _parseId(json['category_id'] ?? json['categoryId']),
      categoryName: json['category_name'] ?? json['categoryName'] ?? '',
      sellerId: _parseId(json['seller_id'] ?? json['sellerId']),
      sellerUsername: json['seller_username'] ??
          json['sellerUsername'] ??
          json['seller_name'] ??
          '',
      sellerRating:
          _parseDoubleNullable(json['seller_rating'] ?? json['sellerRating']),
      imageUrls: _parseImageUrls(json),
      thumbnailUrl: json['thumbnail_url'] ??
          json['thumbnailUrl'] ??
          json['imageUrl'] ??
          json['image_url'] ??
          json['featured_image_url'],
      bidCount: _parseInt(json['bid_count'] ?? json['bidCount'] ?? 0),
      viewCount: _parseInt(json['view_count'] ?? json['viewCount'] ?? 0),
      watchCount: _parseInt(json['watch_count'] ?? json['watchCount'] ?? 0),
      isFeatured: _parseBool(
          json['is_featured'] ?? json['isFeatured'] ?? json['featured']),
      isWatched: _parseBool(
          json['is_watched'] ?? json['isWatched'] ?? json['isWishlisted']),
      shippingCost:
          _parseDoubleNullable(json['shipping_cost'] ?? json['shippingCost']),
      shippingInfo: json['shipping_info'] ?? json['shippingInfo'],
      condition: json['condition'] ?? json['item_condition'],
      location: json['location'],
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']) ??
          DateTime.now(),
      sellerAvatar: json['seller_avatar'] ?? json['sellerAvatar'],
      sellerVerified:
          _parseBoolNullable(json['seller_verified'] ?? json['sellerVerified']),
      shippingMethod: json['shipping_method'] ?? json['shippingMethod'],
      estimatedDelivery:
          json['estimated_delivery'] ?? json['estimatedDelivery'],
      shipsFrom: json['ships_from'] ?? json['shipsFrom'],
      shipsTo: json['ships_to'] ?? json['shipsTo'],
      handlingTime: json['handling_time'] ?? json['handlingTime'],
      returnPolicy: json['return_policy'] ?? json['returnPolicy'],
      shippingNotes: json['shipping_notes'] ?? json['shippingNotes'],
      images: _parseImageUrlsNullable(json),
      minimumBid:
          _parseDoubleNullable(json['minimum_bid'] ?? json['minimumBid']),
      currentBid:
          _parseDoubleNullable(json['current_bid'] ?? json['currentBid']),
      hasSold: _parseBoolNullable(json['has_sold'] ?? json['hasSold']),
    );
  }

  Map<String, dynamic> toJson() => _$AuctionModelToJson(this);

  // Helper methods for parsing API response
  static int _parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is int) return value == 1;
    return false;
  }

  static bool? _parseBoolNullable(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is int) return value == 1;
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is int) {
      // Handle timestamp in milliseconds
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static List<String> _parseImageUrls(Map<String, dynamic> json) {
    // Try multiple possible field names for image URLs
    final imageUrls = <String>[];

    // Check for image_urls array (string array)
    if (json['image_urls'] is List) {
      imageUrls.addAll((json['image_urls'] as List).map((e) => e.toString()));
    } else if (json['imageUrls'] is List) {
      imageUrls.addAll((json['imageUrls'] as List).map((e) => e.toString()));
    } else if (json['images'] is List) {
      // Handle images as array of objects with 'url' field (backend format)
      // or as array of strings
      for (final img in json['images'] as List) {
        if (img is Map) {
          // Image object: {"id": 1, "url": "...", "is_primary": true}
          final url = img['url'];
          if (url != null && url.toString().isNotEmpty) {
            imageUrls.add(url.toString());
          }
        } else if (img is String && img.isNotEmpty) {
          // Direct string URL
          imageUrls.add(img);
        }
      }
    }

    // If no array found, check for single image fields
    if (imageUrls.isEmpty) {
      final singleImage =
          json['imageUrl'] ?? json['image_url'] ?? json['featured_image_url'];
      if (singleImage != null && singleImage.toString().isNotEmpty) {
        imageUrls.add(singleImage.toString());
      }
    }

    return imageUrls;
  }

  static List<String>? _parseImageUrlsNullable(Map<String, dynamic> json) {
    final urls = _parseImageUrls(json);
    return urls.isEmpty ? null : urls;
  }

  // Computed properties
  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  bool get hasEnded => DateTime.now().isAfter(endTime);
  bool get hasStarted => DateTime.now().isAfter(startTime);
  bool get isLive => hasStarted && !hasEnded && isActive;

  Duration get timeRemaining =>
      hasEnded ? Duration.zero : endTime.difference(DateTime.now());
  Duration get timeSinceStart =>
      hasStarted ? DateTime.now().difference(startTime) : Duration.zero;

  bool get hasBuyNow => buyNowPrice != null && buyNowPrice! > 0;
  bool get hasReserve => reservePrice != null && reservePrice! > 0;
  bool get reserveMet => hasReserve ? currentPrice >= reservePrice! : true;

  String get primaryImageUrl => AppConfig.getFullImageUrl(
      thumbnailUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : ''));
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
        return isLive
            ? 'Live'
            : hasEnded
                ? 'Ended'
                : 'Scheduled';
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
  String get formattedBuyNowPrice =>
      buyNowPrice != null ? '\$${buyNowPrice!.toStringAsFixed(2)}' : 'N/A';
  String get formattedCurrentBid =>
      currentBid != null ? '\$${currentBid!.toStringAsFixed(2)}' : 'N/A';
  String get formattedMinimumBid =>
      minimumBid != null ? '\$${minimumBid!.toStringAsFixed(2)}' : 'N/A';

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
