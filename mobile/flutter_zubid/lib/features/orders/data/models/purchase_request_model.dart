import 'package:json_annotation/json_annotation.dart';
import 'order_model.dart';

part 'purchase_request_model.g.dart';

@JsonSerializable()
class PurchaseRequest {
  @JsonKey(name: 'auction_id')
  final int auctionId;

  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  @JsonKey(name: 'shipping_address')
  final ShippingAddress shippingAddress;

  @JsonKey(name: 'billing_address')
  final BillingAddress? billingAddress;

  @JsonKey(name: 'use_shipping_as_billing')
  final bool useShippingAsBilling;

  const PurchaseRequest({
    required this.auctionId,
    required this.paymentMethod,
    required this.shippingAddress,
    this.billingAddress,
    this.useShippingAsBilling = true,
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) => _$PurchaseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseRequestToJson(this);
}

@JsonSerializable()
class PurchaseResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'order')
  final OrderModel? order;

  @JsonKey(name: 'payment_url')
  final String? paymentUrl;

  @JsonKey(name: 'payment_intent_id')
  final String? paymentIntentId;

  @JsonKey(name: 'client_secret')
  final String? clientSecret;

  const PurchaseResponse({
    required this.success,
    required this.message,
    this.order,
    this.paymentUrl,
    this.paymentIntentId,
    this.clientSecret,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) => _$PurchaseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseResponseToJson(this);

  bool get requiresPayment => paymentUrl != null || paymentIntentId != null;
  bool get hasOrder => order != null;
}

@JsonSerializable()
class PaymentConfirmationRequest {
  @JsonKey(name: 'order_id')
  final int orderId;

  @JsonKey(name: 'payment_intent_id')
  final String paymentIntentId;

  @JsonKey(name: 'payment_method_id')
  final String? paymentMethodId;

  const PaymentConfirmationRequest({
    required this.orderId,
    required this.paymentIntentId,
    this.paymentMethodId,
  });

  factory PaymentConfirmationRequest.fromJson(Map<String, dynamic> json) => _$PaymentConfirmationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentConfirmationRequestToJson(this);
}

@JsonSerializable()
class PaymentConfirmationResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'order')
  final OrderModel? order;

  @JsonKey(name: 'payment_status')
  final String? paymentStatus;

  const PaymentConfirmationResponse({
    required this.success,
    required this.message,
    this.order,
    this.paymentStatus,
  });

  factory PaymentConfirmationResponse.fromJson(Map<String, dynamic> json) => _$PaymentConfirmationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentConfirmationResponseToJson(this);

  bool get isPaymentSuccessful => success && paymentStatus?.toLowerCase() == 'paid';
}

@JsonSerializable()
class OrderCancellationRequest {
  @JsonKey(name: 'order_id')
  final int orderId;

  @JsonKey(name: 'reason')
  final String reason;

  const OrderCancellationRequest({
    required this.orderId,
    required this.reason,
  });

  factory OrderCancellationRequest.fromJson(Map<String, dynamic> json) => _$OrderCancellationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OrderCancellationRequestToJson(this);
}

@JsonSerializable()
class OrderTrackingResponse {
  @JsonKey(name: 'order_id')
  final int orderId;

  @JsonKey(name: 'tracking_number')
  final String trackingNumber;

  @JsonKey(name: 'carrier')
  final String carrier;

  @JsonKey(name: 'tracking_url')
  final String? trackingUrl;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'estimated_delivery')
  final DateTime? estimatedDelivery;

  @JsonKey(name: 'tracking_events')
  final List<TrackingEvent> trackingEvents;

  const OrderTrackingResponse({
    required this.orderId,
    required this.trackingNumber,
    required this.carrier,
    this.trackingUrl,
    required this.status,
    this.estimatedDelivery,
    this.trackingEvents = const [],
  });

  factory OrderTrackingResponse.fromJson(Map<String, dynamic> json) => _$OrderTrackingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderTrackingResponseToJson(this);
}

@JsonSerializable()
class TrackingEvent {
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'location')
  final String? location;

  const TrackingEvent({
    required this.timestamp,
    required this.status,
    required this.description,
    this.location,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) => _$TrackingEventFromJson(json);
  Map<String, dynamic> toJson() => _$TrackingEventToJson(this);

  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
