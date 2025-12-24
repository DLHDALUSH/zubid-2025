import 'package:hive/hive.dart';
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
  });

  factory CreateAuctionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAuctionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAuctionRequestToJson(this);

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
  
  String get formattedInternationalShipping => 
      internationalShippingCost != null 
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

  factory CreateAuctionResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateAuctionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAuctionResponseToJson(this);
}
