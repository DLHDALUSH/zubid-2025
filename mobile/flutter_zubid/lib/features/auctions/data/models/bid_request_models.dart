import 'package:json_annotation/json_annotation.dart';

part 'bid_request_models.g.dart';

@JsonSerializable()
class PlaceBidRequest {
  @JsonKey(name: 'auction_id')
  final String auctionId;
  
  final double amount;
  
  @JsonKey(name: 'is_auto_bid')
  final bool? isAutoBid;
  
  @JsonKey(name: 'max_bid_amount')
  final double? maxBidAmount;

  const PlaceBidRequest({
    required this.auctionId,
    required this.amount,
    this.isAutoBid,
    this.maxBidAmount,
  });

  factory PlaceBidRequest.fromJson(Map<String, dynamic> json) => 
      _$PlaceBidRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$PlaceBidRequestToJson(this);
}

@JsonSerializable()
class BuyNowRequest {
  @JsonKey(name: 'auction_id')
  final String auctionId;

  @JsonKey(name: 'payment_method_id')
  final String paymentMethodId;

  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;

  const BuyNowRequest({
    required this.auctionId,
    required this.paymentMethodId,
    this.shippingAddress,
  });

  factory BuyNowRequest.fromJson(Map<String, dynamic> json) =>
      _$BuyNowRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BuyNowRequestToJson(this);
}
