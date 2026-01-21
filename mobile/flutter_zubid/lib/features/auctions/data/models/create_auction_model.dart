import 'package:json_annotation/json_annotation.dart';

part 'create_auction_model.g.dart';

@JsonSerializable()
class CreateAuctionRequest {
  final String title;
  final String description;
  final int categoryId;
  final double startingBid;
  final double? buyNowPrice;
  final DateTime endTime;
  final List<String> imageUrls;
  final String condition;
  final String? brand;
  final String? model;
  final Map<String, dynamic>? specifications;
  final ShippingInfo shippingInfo;
  final bool allowInternationalShipping;
  final String? returnPolicy;
  final int handlingTime; // days
  final bool autoRelist;
  final int? relistCount;
  final double bidIncrement;

  const CreateAuctionRequest({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.startingBid,
    this.buyNowPrice,
    required this.endTime,
    required this.imageUrls,
    required this.condition,
    this.brand,
    this.model,
    this.specifications,
    required this.shippingInfo,
    this.allowInternationalShipping = false,
    this.returnPolicy,
    this.handlingTime = 1,
    this.autoRelist = false,
    this.relistCount,
    this.bidIncrement = 1.0,
  });

  factory CreateAuctionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAuctionRequestFromJson(json);

  /// Convert to JSON format expected by the backend API
  /// Backend expects: item_name, starting_bid, category_id, item_condition, real_price, bid_increment
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'item_name': title,
      'description': description,
      'category_id': categoryId,
      'starting_bid': startingBid,
      'bid_increment': bidIncrement,
      'end_time': endTime.toUtc().toIso8601String(),
      'item_condition': condition,
    };

    // Add optional fields only if they have values
    if (buyNowPrice != null && buyNowPrice! > 0) {
      json['real_price'] = buyNowPrice;
    }
    if (imageUrls.isNotEmpty) {
      json['featured_image_url'] = imageUrls.first;
      json['image_urls'] = imageUrls;
    }
    if (brand != null && brand!.isNotEmpty) {
      json['brand'] = brand;
    }
    if (model != null && model!.isNotEmpty) {
      json['model'] = model;
    }
    if (specifications != null) {
      json['specifications'] = specifications;
    }
    if (returnPolicy != null && returnPolicy!.isNotEmpty) {
      json['return_policy'] = returnPolicy;
    }
    // Add shipping info
    json['shipping_info'] = {
      'domestic_cost': shippingInfo.domesticShippingCost,
      'international_cost': shippingInfo.internationalShippingCost,
      'method': shippingInfo.shippingMethod,
      'free_shipping': shippingInfo.freeShipping,
    };
    json['allow_international_shipping'] = allowInternationalShipping;
    json['handling_time'] = handlingTime;

    return json;
  }

  // Validation methods
  bool get isValid {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        categoryId > 0 &&
        startingBid > 0 &&
        (buyNowPrice == null || buyNowPrice! > startingBid) &&
        endTime.isAfter(DateTime.now()) &&
        imageUrls.isNotEmpty &&
        condition.isNotEmpty &&
        handlingTime > 0;
  }

  List<String> get validationErrors {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Title is required');
    } else if (title.length < 10) {
      errors.add('Title must be at least 10 characters');
    } else if (title.length > 80) {
      errors.add('Title must be less than 80 characters');
    }

    if (description.trim().isEmpty) {
      errors.add('Description is required');
    } else if (description.length < 50) {
      errors.add('Description must be at least 50 characters');
    }

    if (categoryId <= 0) {
      errors.add('Category is required');
    }

    if (startingBid <= 0) {
      errors.add('Starting bid must be greater than 0');
    }

    if (buyNowPrice != null && buyNowPrice! <= startingBid) {
      errors.add('Buy Now price must be greater than starting bid');
    }

    if (endTime.isBefore(DateTime.now())) {
      errors.add('End time must be in the future');
    }

    if (imageUrls.isEmpty) {
      errors.add('At least one image is required');
    } else if (imageUrls.length > 12) {
      errors.add('Maximum 12 images allowed');
    }

    if (condition.isEmpty) {
      errors.add('Condition is required');
    }

    if (handlingTime <= 0) {
      errors.add('Handling time must be at least 1 day');
    }

    return errors;
  }

  // Computed properties
  Duration get auctionDuration => endTime.difference(DateTime.now());

  bool get hasBuyNow => buyNowPrice != null && buyNowPrice! > 0;

  String get formattedStartingBid => '\$${startingBid.toStringAsFixed(2)}';

  String get formattedBuyNowPrice =>
      hasBuyNow ? '\$${buyNowPrice!.toStringAsFixed(2)}' : 'Not set';

  String get formattedEndTime {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else {
      return '${difference.inMinutes} minutes';
    }
  }
}

@JsonSerializable()
class ShippingInfo {
  final double domesticShippingCost;
  final double? internationalShippingCost;
  final String shippingMethod;
  final List<String> shipsTo;
  final String? shippingNotes;
  final bool freeShipping;
  final double? freeShippingThreshold;

  const ShippingInfo({
    required this.domesticShippingCost,
    this.internationalShippingCost,
    required this.shippingMethod,
    required this.shipsTo,
    this.shippingNotes,
    this.freeShipping = false,
    this.freeShippingThreshold,
  });

  factory ShippingInfo.fromJson(Map<String, dynamic> json) =>
      _$ShippingInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingInfoToJson(this);

  String get formattedDomesticShipping =>
      freeShipping ? 'Free' : '\$${domesticShippingCost.toStringAsFixed(2)}';

  String get formattedInternationalShipping => internationalShippingCost != null
      ? '\$${internationalShippingCost!.toStringAsFixed(2)}'
      : 'Not available';
}

@JsonSerializable()
class CreateAuctionResponse {
  final bool success;
  final String message;
  final int? auctionId;
  final String? auctionUrl;
  final List<String>? errors;

  const CreateAuctionResponse({
    required this.success,
    required this.message,
    this.auctionId,
    this.auctionUrl,
    this.errors,
  });

  /// Parse response from backend API
  /// Backend returns: {'id': ..., 'message': ...} on success
  /// Or: {'error': '...'} on failure
  factory CreateAuctionResponse.fromJson(Map<String, dynamic> json) {
    // Check for error response format
    if (json.containsKey('error')) {
      return CreateAuctionResponse(
        success: false,
        message: json['error'] as String? ?? 'Unknown error',
        errors: [json['error'] as String? ?? 'Unknown error'],
      );
    }

    // Success response format from backend
    return CreateAuctionResponse(
      success: true,
      message: json['message'] as String? ?? 'Auction created successfully',
      auctionId: json['id'] as int?,
      auctionUrl: json['auction_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'auctionId': auctionId,
        'auctionUrl': auctionUrl,
        'errors': errors,
      };
}
