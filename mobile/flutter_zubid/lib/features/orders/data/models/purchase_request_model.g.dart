// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseRequest _$PurchaseRequestFromJson(Map<String, dynamic> json) =>
    PurchaseRequest(
      auctionId: (json['auction_id'] as num).toInt(),
      paymentMethod: json['payment_method'] as String,
      shippingAddress: ShippingAddress.fromJson(
          json['shipping_address'] as Map<String, dynamic>),
      billingAddress: json['billing_address'] == null
          ? null
          : BillingAddress.fromJson(
              json['billing_address'] as Map<String, dynamic>),
      useShippingAsBilling: json['use_shipping_as_billing'] as bool? ?? true,
    );

Map<String, dynamic> _$PurchaseRequestToJson(PurchaseRequest instance) =>
    <String, dynamic>{
      'auction_id': instance.auctionId,
      'payment_method': instance.paymentMethod,
      'shipping_address': instance.shippingAddress,
      'billing_address': instance.billingAddress,
      'use_shipping_as_billing': instance.useShippingAsBilling,
    };

PurchaseResponse _$PurchaseResponseFromJson(Map<String, dynamic> json) =>
    PurchaseResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      order: json['order'] == null
          ? null
          : OrderModel.fromJson(json['order'] as Map<String, dynamic>),
      paymentUrl: json['payment_url'] as String?,
      paymentIntentId: json['payment_intent_id'] as String?,
      clientSecret: json['client_secret'] as String?,
    );

Map<String, dynamic> _$PurchaseResponseToJson(PurchaseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'order': instance.order,
      'payment_url': instance.paymentUrl,
      'payment_intent_id': instance.paymentIntentId,
      'client_secret': instance.clientSecret,
    };

PaymentConfirmationRequest _$PaymentConfirmationRequestFromJson(
        Map<String, dynamic> json) =>
    PaymentConfirmationRequest(
      orderId: (json['order_id'] as num).toInt(),
      paymentIntentId: json['payment_intent_id'] as String,
      paymentMethodId: json['payment_method_id'] as String?,
    );

Map<String, dynamic> _$PaymentConfirmationRequestToJson(
        PaymentConfirmationRequest instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'payment_intent_id': instance.paymentIntentId,
      'payment_method_id': instance.paymentMethodId,
    };

PaymentConfirmationResponse _$PaymentConfirmationResponseFromJson(
        Map<String, dynamic> json) =>
    PaymentConfirmationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      order: json['order'] == null
          ? null
          : OrderModel.fromJson(json['order'] as Map<String, dynamic>),
      paymentStatus: json['payment_status'] as String?,
    );

Map<String, dynamic> _$PaymentConfirmationResponseToJson(
        PaymentConfirmationResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'order': instance.order,
      'payment_status': instance.paymentStatus,
    };

OrderCancellationRequest _$OrderCancellationRequestFromJson(
        Map<String, dynamic> json) =>
    OrderCancellationRequest(
      orderId: (json['order_id'] as num).toInt(),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$OrderCancellationRequestToJson(
        OrderCancellationRequest instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'reason': instance.reason,
    };

OrderTrackingResponse _$OrderTrackingResponseFromJson(
        Map<String, dynamic> json) =>
    OrderTrackingResponse(
      orderId: (json['order_id'] as num).toInt(),
      trackingNumber: json['tracking_number'] as String,
      carrier: json['carrier'] as String,
      trackingUrl: json['tracking_url'] as String?,
      status: json['status'] as String,
      estimatedDelivery: json['estimated_delivery'] == null
          ? null
          : DateTime.parse(json['estimated_delivery'] as String),
      trackingEvents: (json['tracking_events'] as List<dynamic>?)
              ?.map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OrderTrackingResponseToJson(
        OrderTrackingResponse instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'tracking_number': instance.trackingNumber,
      'carrier': instance.carrier,
      'tracking_url': instance.trackingUrl,
      'status': instance.status,
      'estimated_delivery': instance.estimatedDelivery?.toIso8601String(),
      'tracking_events': instance.trackingEvents,
    };

TrackingEvent _$TrackingEventFromJson(Map<String, dynamic> json) =>
    TrackingEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$TrackingEventToJson(TrackingEvent instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'status': instance.status,
      'description': instance.description,
      'location': instance.location,
    };
