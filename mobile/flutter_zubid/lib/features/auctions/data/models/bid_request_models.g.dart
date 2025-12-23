// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceBidRequest _$PlaceBidRequestFromJson(Map<String, dynamic> json) =>
    PlaceBidRequest(
      auctionId: json['auction_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      isAutoBid: json['is_auto_bid'] as bool?,
      maxBidAmount: (json['max_bid_amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PlaceBidRequestToJson(PlaceBidRequest instance) =>
    <String, dynamic>{
      'auction_id': instance.auctionId,
      'amount': instance.amount,
      'is_auto_bid': instance.isAutoBid,
      'max_bid_amount': instance.maxBidAmount,
    };

BuyNowRequest _$BuyNowRequestFromJson(Map<String, dynamic> json) =>
    BuyNowRequest(
      auctionId: json['auction_id'] as String,
      paymentMethodId: json['payment_method_id'] as String,
      shippingAddress: json['shipping_address'] as String?,
    );

Map<String, dynamic> _$BuyNowRequestToJson(BuyNowRequest instance) =>
    <String, dynamic>{
      'auction_id': instance.auctionId,
      'payment_method_id': instance.paymentMethodId,
      'shipping_address': instance.shippingAddress,
    };
