import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../presentation/widgets/seller_info_card.dart';

part 'auction_model.g.dart';

// ============================================================================
// Enums
// ============================================================================

/// Represents the possible states of an auction.
enum AuctionStatus {
  /// Auction is currently accepting bids.
  active,

  /// Auction has ended (time expired or sold).
  ended,

  /// Auction is pending approval or scheduled to start.
  pending,

  /// Auction was cancelled by the seller or admin.
  cancelled;

  /// Creates an [AuctionStatus] from a string value.
  ///
  /// Returns [AuctionStatus.active] if the value is unrecognized.
  factory AuctionStatus.fromString(String? value) {
    if (value == null) return AuctionStatus.active;
    return AuctionStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => AuctionStatus.active,
    );
  }

  /// Returns the display name for this status.
  String get displayName => switch (this) {
        AuctionStatus.active => 'Active',
        AuctionStatus.ended => 'Ended',
        AuctionStatus.pending => 'Pending',
        AuctionStatus.cancelled => 'Cancelled',
      };
}

// ============================================================================
// Type Definitions
// ============================================================================

/// Type alias for JSON map structure.
typedef JsonMap = Map<String, dynamic>;

// ============================================================================
// Main Model
// ============================================================================

/// Represents an auction listing in the Zubid marketplace.
///
/// This model handles both local persistence via Hive and JSON serialization
/// for API communication. It supports multiple JSON field naming conventions
/// (snake_case and camelCase) for API compatibility.
///
/// ## Example
/// ```dart
/// final auction = AuctionModel.fromJson(jsonData);
/// print(auction.formattedCurrentPrice); // $150.00
/// print(auction.timeRemainingText); // 2d 5h
/// ```
@HiveType(typeId: 2)
@JsonSerializable()
class AuctionModel extends HiveObject {
  // ==========================================================================
  // Core Fields
  // ==========================================================================

  /// Unique identifier for the auction.
  @HiveField(0)
  final int id;

  /// Title/name of the auction item.
  @HiveField(1)
  final String title;

  /// Detailed description of the auction item.
  @HiveField(2)
  final String description;

  // ==========================================================================
  // Pricing Fields
  // ==========================================================================

  /// Initial starting price for bidding.
  @HiveField(3)
  @JsonKey(name: 'starting_price')
  final double startingPrice;

  /// Current highest bid price.
  @HiveField(4)
  @JsonKey(name: 'current_price')
  final double currentPrice;

  /// Optional buy-it-now price to purchase immediately.
  @HiveField(5)
  @JsonKey(name: 'buy_now_price')
  final double? buyNowPrice;

  /// Optional minimum price that must be met for sale.
  @HiveField(6)
  @JsonKey(name: 'reserve_price')
  final double? reservePrice;

  /// Minimum bid amount (if different from starting price).
  @HiveField(38)
  @JsonKey(name: 'minimum_bid')
  final double? minimumBid;

  /// Current bid amount (alternative field name).
  @HiveField(39)
  @JsonKey(name: 'current_bid')
  final double? currentBid;

  // ==========================================================================
  // Time Fields
  // ==========================================================================

  /// When the auction starts accepting bids.
  @HiveField(7)
  @JsonKey(name: 'start_time')
  final DateTime startTime;

  /// When the auction ends.
  @HiveField(8)
  @JsonKey(name: 'end_time')
  final DateTime endTime;

  /// When the auction record was created.
  @HiveField(26)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// When the auction record was last updated.
  @HiveField(27)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // ==========================================================================
  // Status & Category
  // ==========================================================================

  /// Current status of the auction (active, ended, pending, cancelled).
  @HiveField(9)
  final String status;

  /// Category identifier for the auction item.
  @HiveField(10)
  @JsonKey(name: 'category_id')
  final int categoryId;

  /// Display name of the category.
  @HiveField(11)
  @JsonKey(name: 'category_name')
  final String categoryName;

  /// Whether the item has been sold.
  @HiveField(40)
  @JsonKey(name: 'has_sold')
  final bool? hasSold;

  // ==========================================================================
  // Seller Information
  // ==========================================================================

  /// Unique identifier of the seller.
  @HiveField(12)
  @JsonKey(name: 'seller_id')
  final int sellerId;

  /// Display username of the seller.
  @HiveField(13)
  @JsonKey(name: 'seller_username')
  final String sellerUsername;

  /// Seller's average rating (0.0 - 5.0).
  @HiveField(14)
  @JsonKey(name: 'seller_rating')
  final double? sellerRating;

  /// URL to seller's avatar image.
  @HiveField(28)
  @JsonKey(name: 'seller_avatar')
  final String? sellerAvatar;

  /// Whether the seller is verified.
  @HiveField(29)
  @JsonKey(name: 'seller_verified')
  final bool? sellerVerified;

  /// Number of reviews the seller has received.
  @HiveField(41)
  @JsonKey(name: 'seller_review_count')
  final int? sellerReviewCount;

  /// When the seller joined the platform.
  @HiveField(42)
  @JsonKey(name: 'seller_member_since')
  final DateTime? sellerMemberSince;

  /// Number of currently active auctions by this seller.
  @HiveField(43)
  @JsonKey(name: 'seller_active_auctions')
  final int? sellerActiveAuctions;

  /// Total number of completed sales by this seller.
  @HiveField(44)
  @JsonKey(name: 'seller_total_sales')
  final int? sellerTotalSales;

  /// Seller's transaction success rate (0.0 - 100.0).
  @HiveField(45)
  @JsonKey(name: 'seller_success_rate')
  final double? sellerSuccessRate;

  // ==========================================================================
  // Images
  // ==========================================================================

  /// List of image URLs for the auction item.
  @HiveField(15)
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;

  /// URL of the thumbnail image.
  @HiveField(16)
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  /// Alternative images list field.
  @HiveField(37)
  @JsonKey(name: 'images')
  final List<String>? images;

  // ==========================================================================
  // Statistics
  // ==========================================================================

  /// Number of bids placed on this auction.
  @HiveField(17)
  @JsonKey(name: 'bid_count')
  final int bidCount;

  /// Number of times the auction has been viewed.
  @HiveField(18)
  @JsonKey(name: 'view_count')
  final int viewCount;

  /// Number of users watching this auction.
  @HiveField(19)
  @JsonKey(name: 'watch_count')
  final int watchCount;

  /// Whether this auction is featured/promoted.
  @HiveField(20)
  @JsonKey(name: 'is_featured')
  final bool isFeatured;

  /// Whether the current user is watching this auction.
  @HiveField(21)
  @JsonKey(name: 'is_watched')
  final bool isWatched;

  // ==========================================================================
  // Item Details
  // ==========================================================================

  /// Condition of the item (new, used, refurbished, etc.).
  @HiveField(24)
  @JsonKey(name: 'condition')
  final String? condition;

  /// Location where the item is located.
  @HiveField(25)
  @JsonKey(name: 'location')
  final String? location;

  // ==========================================================================
  // Shipping Information
  // ==========================================================================

  /// Cost of shipping.
  @HiveField(22)
  @JsonKey(name: 'shipping_cost')
  final double? shippingCost;

  /// General shipping information text.
  @HiveField(23)
  @JsonKey(name: 'shipping_info')
  final String? shippingInfo;

  /// Shipping method (standard, express, overnight, etc.).
  @HiveField(30)
  @JsonKey(name: 'shipping_method')
  final String? shippingMethod;

  /// Estimated delivery timeframe.
  @HiveField(31)
  @JsonKey(name: 'estimated_delivery')
  final String? estimatedDelivery;

  /// Origin location for shipping.
  @HiveField(32)
  @JsonKey(name: 'ships_from')
  final String? shipsFrom;

  /// Destinations the item can ship to.
  @HiveField(33)
  @JsonKey(name: 'ships_to')
  final String? shipsTo;

  /// Time required to prepare the item for shipping.
  @HiveField(34)
  @JsonKey(name: 'handling_time')
  final String? handlingTime;

  /// Return policy details.
  @HiveField(35)
  @JsonKey(name: 'return_policy')
  final String? returnPolicy;

  /// Additional shipping notes or instructions.
  @HiveField(36)
  @JsonKey(name: 'shipping_notes')
  final String? shippingNotes;

  // ==========================================================================
  // Constructor
  // ==========================================================================

  /// Creates a new [AuctionModel] instance.
  AuctionModel({
    // Core
    required this.id,
    required this.title,
    required this.description,
    // Pricing
    required this.startingPrice,
    required this.currentPrice,
    this.buyNowPrice,
    this.reservePrice,
    this.minimumBid,
    this.currentBid,
    // Time
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
    // Status & Category
    required this.status,
    required this.categoryId,
    required this.categoryName,
    this.hasSold,
    // Seller
    required this.sellerId,
    required this.sellerUsername,
    this.sellerRating,
    this.sellerAvatar,
    this.sellerVerified,
    this.sellerReviewCount,
    this.sellerMemberSince,
    this.sellerActiveAuctions,
    this.sellerTotalSales,
    this.sellerSuccessRate,
    // Images
    required this.imageUrls,
    this.thumbnailUrl,
    this.images,
    // Statistics
    required this.bidCount,
    required this.viewCount,
    required this.watchCount,
    required this.isFeatured,
    required this.isWatched,
    // Item Details
    this.condition,
    this.location,
    // Shipping
    this.shippingCost,
    this.shippingInfo,
    this.shippingMethod,
    this.estimatedDelivery,
    this.shipsFrom,
    this.shipsTo,
    this.handlingTime,
    this.returnPolicy,
    this.shippingNotes,
  });

  // ==========================================================================
  // Factory Constructors
  // ==========================================================================

  /// Creates an [AuctionModel] from a JSON map.
  ///
  /// Handles both snake_case and camelCase field names for API compatibility.
  /// Provides sensible defaults for missing required fields.
  factory AuctionModel.fromJson(JsonMap json) => AuctionModel(
        // Core
        id: _JsonParser.toInt(json['id']),
        title: json['title'] as String? ?? json['item_name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        // Pricing
        startingPrice: _JsonParser.toDouble(
          json['starting_price'] ??
              json['startingPrice'] ??
              json['starting_bid'],
        ),
        currentPrice: _JsonParser.toDouble(
          json['current_price'] ?? json['currentPrice'] ?? json['current_bid'],
        ),
        buyNowPrice: _JsonParser.toDoubleOrNull(
          json['buy_now_price'] ?? json['buyNowPrice'],
        ),
        reservePrice: _JsonParser.toDoubleOrNull(
          json['reserve_price'] ?? json['reservePrice'],
        ),
        minimumBid: _JsonParser.toDoubleOrNull(
          json['minimum_bid'] ?? json['minimumBid'],
        ),
        currentBid: _JsonParser.toDoubleOrNull(
          json['current_bid'] ?? json['currentBid'],
        ),
        // Time
        startTime: _JsonParser.toDateTime(
              json['start_time'] ?? json['startTime'],
            ) ??
            DateTime.now(),
        endTime: _JsonParser.toDateTime(
              json['end_time'] ?? json['endTime'],
            ) ??
            DateTime.now().add(const Duration(days: 7)),
        createdAt: _JsonParser.toDateTime(
              json['created_at'] ?? json['createdAt'],
            ) ??
            DateTime.now(),
        updatedAt: _JsonParser.toDateTime(
              json['updated_at'] ?? json['updatedAt'],
            ) ??
            DateTime.now(),
        // Status & Category
        status: json['status'] as String? ?? 'active',
        categoryId: _JsonParser.toInt(
          json['category_id'] ?? json['categoryId'],
        ),
        categoryName: json['category_name'] as String? ??
            json['categoryName'] as String? ??
            '',
        hasSold: _JsonParser.toBoolOrNull(json['has_sold'] ?? json['hasSold']),
        // Seller
        sellerId: _JsonParser.toInt(json['seller_id'] ?? json['sellerId']),
        sellerUsername: json['seller_username'] as String? ??
            json['sellerUsername'] as String? ??
            json['seller_name'] as String? ??
            '',
        sellerRating: _JsonParser.toDoubleOrNull(
          json['seller_rating'] ?? json['sellerRating'],
        ),
        sellerAvatar:
            json['seller_avatar'] as String? ?? json['sellerAvatar'] as String?,
        sellerVerified: _JsonParser.toBoolOrNull(
          json['seller_verified'] ?? json['sellerVerified'],
        ),
        sellerReviewCount: _JsonParser.toIntOrNull(
          json['seller_review_count'] ?? json['sellerReviewCount'],
        ),
        sellerMemberSince: _JsonParser.toDateTime(
          json['seller_member_since'] ?? json['sellerMemberSince'],
        ),
        sellerActiveAuctions: _JsonParser.toIntOrNull(
          json['seller_active_auctions'] ?? json['sellerActiveAuctions'],
        ),
        sellerTotalSales: _JsonParser.toIntOrNull(
          json['seller_total_sales'] ?? json['sellerTotalSales'],
        ),
        sellerSuccessRate: _JsonParser.toDoubleOrNull(
          json['seller_success_rate'] ?? json['sellerSuccessRate'],
        ),
        // Images
        imageUrls: _parseImageUrls(json),
        thumbnailUrl: json['thumbnail_url'] as String? ??
            json['thumbnailUrl'] as String? ??
            json['imageUrl'] as String? ??
            json['image_url'] as String? ??
            json['featured_image_url'] as String?,
        images: _parseImageUrlsNullable(json),
        // Statistics
        bidCount: _JsonParser.toInt(json['bid_count'] ?? json['bidCount']),
        viewCount: _JsonParser.toInt(json['view_count'] ?? json['viewCount']),
        watchCount:
            _JsonParser.toInt(json['watch_count'] ?? json['watchCount']),
        isFeatured: _JsonParser.toBool(
          json['is_featured'] ?? json['isFeatured'] ?? json['featured'],
        ),
        // cSpell:ignore isWishlisted
        isWatched: _JsonParser.toBool(
          json['is_watched'] ?? json['isWatched'] ?? json['isWishlisted'],
        ),
        // Item Details
        condition:
            json['condition'] as String? ?? json['item_condition'] as String?,
        location: json['location'] as String?,
        // Shipping
        shippingCost: _JsonParser.toDoubleOrNull(
          json['shipping_cost'] ?? json['shippingCost'],
        ),
        shippingInfo:
            json['shipping_info'] as String? ?? json['shippingInfo'] as String?,
        shippingMethod: json['shipping_method'] as String? ??
            json['shippingMethod'] as String?,
        estimatedDelivery: json['estimated_delivery'] as String? ??
            json['estimatedDelivery'] as String?,
        shipsFrom:
            json['ships_from'] as String? ?? json['shipsFrom'] as String?,
        shipsTo: json['ships_to'] as String? ?? json['shipsTo'] as String?,
        handlingTime:
            json['handling_time'] as String? ?? json['handlingTime'] as String?,
        returnPolicy:
            json['return_policy'] as String? ?? json['returnPolicy'] as String?,
        shippingNotes: json['shipping_notes'] as String? ??
            json['shippingNotes'] as String?,
      );

  /// Converts this model to a JSON map.
  JsonMap toJson() => _$AuctionModelToJson(this);

  // ==========================================================================
  // Image Parsing (Static)
  // ==========================================================================

  /// Parses image URLs from various JSON field formats.
  static List<String> _parseImageUrls(JsonMap json) {
    final imageUrls = <String>[];

    // Try array fields first
    final arrayField =
        json['image_urls'] ?? json['imageUrls'] ?? json['images'];
    if (arrayField is List) {
      for (final img in arrayField) {
        if (img is Map) {
          // Handle image object: {"id": 1, "url": "...", "is_primary": true}
          final url = img['url']?.toString();
          if (url != null && url.isNotEmpty) imageUrls.add(url);
        } else if (img is String && img.isNotEmpty) {
          imageUrls.add(img);
        }
      }
    }

    // Fallback to single image fields
    if (imageUrls.isEmpty) {
      final singleImage =
          (json['imageUrl'] ?? json['image_url'] ?? json['featured_image_url'])
              ?.toString();
      if (singleImage != null && singleImage.isNotEmpty) {
        imageUrls.add(singleImage);
      }
    }

    return imageUrls;
  }

  /// Parses image URLs, returning null if none found.
  static List<String>? _parseImageUrlsNullable(JsonMap json) {
    final urls = _parseImageUrls(json);
    return urls.isEmpty ? null : urls;
  }

  // ==========================================================================
  // Computed Properties - Status
  // ==========================================================================

  /// Returns the parsed auction status as an enum.
  AuctionStatus get auctionStatus => AuctionStatus.fromString(status);

  /// Whether the auction status is active.
  bool get isActive => status.toLowerCase() == 'active';

  /// Whether the auction status is ended.
  bool get isEnded => status.toLowerCase() == 'ended';

  /// Whether the auction status is pending.
  bool get isPending => status.toLowerCase() == 'pending';

  /// Whether the auction status is cancelled.
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Whether the auction end time has passed.
  bool get hasEnded => DateTime.now().isAfter(endTime);

  /// Whether the auction has started.
  bool get hasStarted => DateTime.now().isAfter(startTime);

  /// Whether the auction is currently live (started, not ended, and active).
  bool get isLive => hasStarted && !hasEnded && isActive;

  // ==========================================================================
  // Computed Properties - Time
  // ==========================================================================

  /// Time remaining until auction ends.
  Duration get timeRemaining =>
      hasEnded ? Duration.zero : endTime.difference(DateTime.now());

  /// Time since auction started.
  Duration get timeSinceStart =>
      hasStarted ? DateTime.now().difference(startTime) : Duration.zero;

  /// Human-readable time remaining text.
  String get timeRemainingText {
    if (hasEnded) return 'Ended';
    if (!hasStarted) return 'Not started';

    final duration = timeRemaining;
    return switch (duration) {
      Duration(inDays: > 0) => '${duration.inDays}d ${duration.inHours % 24}h',
      Duration(inHours: > 0) =>
        '${duration.inHours}h ${duration.inMinutes % 60}m',
      Duration(inMinutes: > 0) =>
        '${duration.inMinutes}m ${duration.inSeconds % 60}s',
      _ => '${duration.inSeconds}s',
    };
  }

  /// Human-readable status text.
  String get statusText => switch (status.toLowerCase()) {
        'active' => isLive
            ? 'Live'
            : hasEnded
                ? 'Ended'
                : 'Scheduled',
        'ended' => 'Ended',
        'pending' => 'Pending',
        'cancelled' => 'Cancelled',
        _ => status,
      };

  // ==========================================================================
  // Computed Properties - Pricing
  // ==========================================================================

  /// Whether buy-it-now is available.
  bool get hasBuyNow => buyNowPrice != null && buyNowPrice! > 0;

  /// Whether there's a reserve price.
  bool get hasReserve => reservePrice != null && reservePrice! > 0;

  /// Whether the reserve price has been met.
  bool get reserveMet => !hasReserve || currentPrice >= reservePrice!;

  // ==========================================================================
  // Computed Properties - Images
  // ==========================================================================

  /// Primary image URL with full path.
  String get primaryImageUrl => AppConfig.getFullImageUrl(
        thumbnailUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : ''),
      );

  /// Whether the auction has images.
  bool get hasImages => imageUrls.isNotEmpty;

  // ==========================================================================
  // Computed Properties - Seller
  // ==========================================================================

  /// Aggregated seller information object.
  SellerInfo get seller => SellerInfo(
        id: sellerId,
        username: sellerUsername,
        avatar: sellerAvatar,
        isVerified: sellerVerified ?? false,
        rating: sellerRating,
        reviewCount: sellerReviewCount ?? 0,
        memberSince: sellerMemberSince ?? createdAt,
        activeAuctions: sellerActiveAuctions ?? 0,
        totalSales: sellerTotalSales ?? 0,
        successRate: sellerSuccessRate ?? 0.0,
      );

  // ==========================================================================
  // Computed Properties - Shipping
  // ==========================================================================

  /// Shipping cost with default of 0.0.
  double get shippingCostValue => shippingCost ?? 0.0;

  /// Shipping method with empty default.
  String get shippingMethodValue => shippingMethod ?? '';

  /// Estimated delivery with empty default.
  String get estimatedDeliveryValue => estimatedDelivery ?? '';

  /// Origin location with empty default.
  String get shipsFromValue => shipsFrom ?? '';

  /// Destination locations with empty default.
  String get shipsToValue => shipsTo ?? '';

  /// Handling time with empty default.
  String get handlingTimeValue => handlingTime ?? '';

  /// Return policy with empty default.
  String get returnPolicyValue => returnPolicy ?? '';

  /// Shipping notes with empty default.
  String get shippingNotesValue => shippingNotes ?? '';

  /// Aggregated shipping information object.
  AuctionShippingDetails get shipping => AuctionShippingDetails(
        hasShippingCost: shippingCost != null && shippingCost! > 0,
        shippingCost: shippingCost ?? 0.0,
        hasReturnPolicy: returnPolicy != null && returnPolicy!.isNotEmpty,
        returnPolicy: returnPolicy ?? '',
      );

  // ==========================================================================
  // Computed Properties - Formatted Prices
  // ==========================================================================

  /// Formatted buy-now price string.
  String get formattedBuyNowPrice => _formatPrice(buyNowPrice);

  /// Formatted current bid string.
  String get formattedCurrentBid => _formatPrice(currentBid);

  /// Formatted minimum bid string.
  String get formattedMinimumBid => _formatPrice(minimumBid);

  /// Formatted starting price string.
  String get formattedStartingPrice => _formatPrice(startingPrice);

  /// Formatted current price string.
  String get formattedCurrentPrice => _formatPrice(currentPrice);

  /// Formats a price value to currency string.
  static String _formatPrice(double? price) =>
      price != null ? '\$${price.toStringAsFixed(2)}' : 'N/A';

  // ==========================================================================
  // Object Methods
  // ==========================================================================

  @override
  String toString() => 'AuctionModel(id: $id, title: $title, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuctionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // ==========================================================================
  // Copy With
  // ==========================================================================

  /// Creates a copy of this [AuctionModel] with the given fields replaced.
  ///
  /// All fields are optional. If a field is not provided, the current value
  /// is retained.
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
    String? sellerAvatar,
    bool? sellerVerified,
    String? shippingMethod,
    String? estimatedDelivery,
    String? shipsFrom,
    String? shipsTo,
    String? handlingTime,
    String? returnPolicy,
    String? shippingNotes,
    List<String>? images,
    double? minimumBid,
    double? currentBid,
    bool? hasSold,
    int? sellerReviewCount,
    DateTime? sellerMemberSince,
    int? sellerActiveAuctions,
    int? sellerTotalSales,
    double? sellerSuccessRate,
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
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      sellerVerified: sellerVerified ?? this.sellerVerified,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      shipsFrom: shipsFrom ?? this.shipsFrom,
      shipsTo: shipsTo ?? this.shipsTo,
      handlingTime: handlingTime ?? this.handlingTime,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      shippingNotes: shippingNotes ?? this.shippingNotes,
      images: images ?? this.images,
      minimumBid: minimumBid ?? this.minimumBid,
      currentBid: currentBid ?? this.currentBid,
      hasSold: hasSold ?? this.hasSold,
      sellerReviewCount: sellerReviewCount ?? this.sellerReviewCount,
      sellerMemberSince: sellerMemberSince ?? this.sellerMemberSince,
      sellerActiveAuctions: sellerActiveAuctions ?? this.sellerActiveAuctions,
      sellerTotalSales: sellerTotalSales ?? this.sellerTotalSales,
      sellerSuccessRate: sellerSuccessRate ?? this.sellerSuccessRate,
    );
  }
}

// =============================================================================
// Helper Classes
// =============================================================================

/// Aggregated shipping details for an auction.
class AuctionShippingDetails {
  /// Whether shipping cost is specified.
  final bool hasShippingCost;

  /// The shipping cost amount.
  final double shippingCost;

  /// Whether a return policy is specified.
  final bool hasReturnPolicy;

  /// The return policy description.
  final String returnPolicy;

  /// Creates shipping details.
  const AuctionShippingDetails({
    required this.hasShippingCost,
    required this.shippingCost,
    required this.hasReturnPolicy,
    required this.returnPolicy,
  });
}

// =============================================================================
// JSON Parsing Utilities
// =============================================================================

/// Type-safe JSON parsing utilities.
///
/// Provides consistent parsing of dynamic JSON values to typed Dart values.
abstract final class _JsonParser {
  /// Parses value to non-null int, defaulting to 0.
  static int toInt(dynamic value) => switch (value) {
        int v => v,
        double v => v.toInt(),
        String v => int.tryParse(v) ?? 0,
        _ => 0,
      };

  /// Parses value to nullable int.
  static int? toIntOrNull(dynamic value) => switch (value) {
        null => null,
        int v => v,
        double v => v.toInt(),
        String v => int.tryParse(v),
        _ => null,
      };

  /// Parses value to non-null double, defaulting to 0.0.
  static double toDouble(dynamic value) => switch (value) {
        double v => v,
        int v => v.toDouble(),
        String v => double.tryParse(v) ?? 0.0,
        _ => 0.0,
      };

  /// Parses value to nullable double.
  static double? toDoubleOrNull(dynamic value) => switch (value) {
        null => null,
        double v => v,
        int v => v.toDouble(),
        String v => double.tryParse(v),
        _ => null,
      };

  /// Parses value to non-null bool, defaulting to false.
  static bool toBool(dynamic value) => switch (value) {
        bool v => v,
        int v => v == 1,
        String v => v.toLowerCase() == 'true' || v == '1',
        _ => false,
      };

  /// Parses value to nullable bool.
  static bool? toBoolOrNull(dynamic value) => switch (value) {
        null => null,
        bool v => v,
        int v => v == 1,
        String v => v.toLowerCase() == 'true' || v == '1',
        _ => null,
      };

  /// Parses value to nullable DateTime.
  static DateTime? toDateTime(dynamic value) => switch (value) {
        null => null,
        String v => DateTime.tryParse(v),
        int v => DateTime.fromMillisecondsSinceEpoch(v),
        _ => null,
      };
}
