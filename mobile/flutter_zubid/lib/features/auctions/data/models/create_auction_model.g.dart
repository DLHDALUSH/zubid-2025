// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_auction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAuctionRequest _$CreateAuctionRequestFromJson(
        Map<String, dynamic> json) =>
    CreateAuctionRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: (json['categoryId'] as num).toInt(),
      startingBid: (json['startingBid'] as num).toDouble(),
      buyNowPrice: (json['buyNowPrice'] as num?)?.toDouble(),
      endTime: DateTime.parse(json['endTime'] as String),
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      condition: json['condition'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      shippingInfo:
          ShippingInfo.fromJson(json['shippingInfo'] as Map<String, dynamic>),
      allowInternationalShipping:
          json['allowInternationalShipping'] as bool? ?? false,
      returnPolicy: json['returnPolicy'] as String?,
      handlingTime: (json['handlingTime'] as num?)?.toInt() ?? 1,
      autoRelist: json['autoRelist'] as bool? ?? false,
      relistCount: (json['relistCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateAuctionRequestToJson(
        CreateAuctionRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'startingBid': instance.startingBid,
      'buyNowPrice': instance.buyNowPrice,
      'endTime': instance.endTime.toIso8601String(),
      'imageUrls': instance.imageUrls,
      'condition': instance.condition,
      'brand': instance.brand,
      'model': instance.model,
      'specifications': instance.specifications,
      'shippingInfo': instance.shippingInfo,
      'allowInternationalShipping': instance.allowInternationalShipping,
      'returnPolicy': instance.returnPolicy,
      'handlingTime': instance.handlingTime,
      'autoRelist': instance.autoRelist,
      'relistCount': instance.relistCount,
    };

ShippingInfo _$ShippingInfoFromJson(Map<String, dynamic> json) => ShippingInfo(
      domesticShippingCost: (json['domesticShippingCost'] as num).toDouble(),
      internationalShippingCost:
          (json['internationalShippingCost'] as num?)?.toDouble(),
      shippingMethod: json['shippingMethod'] as String,
      shipsTo:
          (json['shipsTo'] as List<dynamic>).map((e) => e as String).toList(),
      shippingNotes: json['shippingNotes'] as String?,
      freeShipping: json['freeShipping'] as bool? ?? false,
      freeShippingThreshold:
          (json['freeShippingThreshold'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ShippingInfoToJson(ShippingInfo instance) =>
    <String, dynamic>{
      'domesticShippingCost': instance.domesticShippingCost,
      'internationalShippingCost': instance.internationalShippingCost,
      'shippingMethod': instance.shippingMethod,
      'shipsTo': instance.shipsTo,
      'shippingNotes': instance.shippingNotes,
      'freeShipping': instance.freeShipping,
      'freeShippingThreshold': instance.freeShippingThreshold,
    };

CreateAuctionResponse _$CreateAuctionResponseFromJson(
        Map<String, dynamic> json) =>
    CreateAuctionResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      auctionId: (json['auctionId'] as num?)?.toInt(),
      auctionUrl: json['auctionUrl'] as String?,
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreateAuctionResponseToJson(
        CreateAuctionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'auctionId': instance.auctionId,
      'auctionUrl': instance.auctionUrl,
      'errors': instance.errors,
    };
