import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class OrderModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  @JsonKey(name: 'order_number')
  final String orderNumber;

  @HiveField(2)
  @JsonKey(name: 'user_id')
  final int userId;

  @HiveField(3)
  @JsonKey(name: 'auction_id')
  final int auctionId;

  @HiveField(4)
  @JsonKey(name: 'auction_title')
  final String auctionTitle;

  @HiveField(5)
  @JsonKey(name: 'auction_image')
  final String? auctionImage;

  @HiveField(6)
  @JsonKey(name: 'seller_id')
  final int sellerId;

  @HiveField(7)
  @JsonKey(name: 'seller_name')
  final String sellerName;

  @HiveField(8)
  @JsonKey(name: 'purchase_price')
  final double purchasePrice;

  @HiveField(9)
  @JsonKey(name: 'shipping_cost')
  final double shippingCost;

  @HiveField(10)
  @JsonKey(name: 'tax_amount')
  final double taxAmount;

  @HiveField(11)
  @JsonKey(name: 'total_amount')
  final double totalAmount;

  @HiveField(12)
  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  @HiveField(13)
  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  @HiveField(14)
  @JsonKey(name: 'order_status')
  final String orderStatus;

  @HiveField(15)
  @JsonKey(name: 'shipping_address')
  final ShippingAddress shippingAddress;

  @HiveField(16)
  @JsonKey(name: 'billing_address')
  final BillingAddress? billingAddress;

  @HiveField(17)
  @JsonKey(name: 'tracking_number')
  final String? trackingNumber;

  @HiveField(18)
  @JsonKey(name: 'estimated_delivery')
  final DateTime? estimatedDelivery;

  @HiveField(19)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(20)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(21)
  @JsonKey(name: 'shipped_at')
  final DateTime? shippedAt;

  @HiveField(22)
  @JsonKey(name: 'delivered_at')
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.auctionId,
    required this.auctionTitle,
    this.auctionImage,
    required this.sellerId,
    required this.sellerName,
    required this.purchasePrice,
    required this.shippingCost,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.shippingAddress,
    this.billingAddress,
    this.trackingNumber,
    this.estimatedDelivery,
    required this.createdAt,
    required this.updatedAt,
    this.shippedAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  // Computed properties
  bool get isPending => orderStatus.toLowerCase() == 'pending';
  bool get isConfirmed => orderStatus.toLowerCase() == 'confirmed';
  bool get isProcessing => orderStatus.toLowerCase() == 'processing';
  bool get isShipped => orderStatus.toLowerCase() == 'shipped';
  bool get isDelivered => orderStatus.toLowerCase() == 'delivered';
  bool get isCancelled => orderStatus.toLowerCase() == 'cancelled';
  bool get isRefunded => orderStatus.toLowerCase() == 'refunded';

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isPaymentPending => paymentStatus.toLowerCase() == 'pending';
  bool get isPaymentFailed => paymentStatus.toLowerCase() == 'failed';

  String get formattedPurchasePrice => '\$${purchasePrice.toStringAsFixed(2)}';
  String get formattedShippingCost => '\$${shippingCost.toStringAsFixed(2)}';
  String get formattedTaxAmount => '\$${taxAmount.toStringAsFixed(2)}';
  String get formattedTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';

  String get statusDisplayText {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return 'Order Pending';
      case 'confirmed':
        return 'Order Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return orderStatus;
    }
  }

  String get paymentStatusDisplayText {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return 'Payment Successful';
      case 'pending':
        return 'Payment Pending';
      case 'failed':
        return 'Payment Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus;
    }
  }

  bool get canCancel => isPending || isConfirmed;
  bool get canTrack => isShipped && trackingNumber != null;
  bool get hasEstimatedDelivery => estimatedDelivery != null;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

@HiveType(typeId: 5)
@JsonSerializable()
class ShippingAddress {
  @HiveField(0)
  @JsonKey(name: 'full_name')
  final String fullName;

  @HiveField(1)
  @JsonKey(name: 'address_line_1')
  final String addressLine1;

  @HiveField(2)
  @JsonKey(name: 'address_line_2')
  final String? addressLine2;

  @HiveField(3)
  final String city;

  @HiveField(4)
  final String state;

  @HiveField(5)
  @JsonKey(name: 'postal_code')
  final String postalCode;

  @HiveField(6)
  final String country;

  @HiveField(7)
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  const ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phoneNumber,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => _$ShippingAddressFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingAddressToJson(this);

  String get formattedAddress {
    final parts = <String>[
      fullName,
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2!,
      '$city, $state $postalCode',
      country,
    ];
    return parts.join('\n');
  }
}

@HiveType(typeId: 6)
@JsonSerializable()
class BillingAddress {
  @HiveField(0)
  @JsonKey(name: 'full_name')
  final String fullName;

  @HiveField(1)
  @JsonKey(name: 'address_line_1')
  final String addressLine1;

  @HiveField(2)
  @JsonKey(name: 'address_line_2')
  final String? addressLine2;

  @HiveField(3)
  final String city;

  @HiveField(4)
  final String state;

  @HiveField(5)
  @JsonKey(name: 'postal_code')
  final String postalCode;

  @HiveField(6)
  final String country;

  const BillingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory BillingAddress.fromJson(Map<String, dynamic> json) => _$BillingAddressFromJson(json);
  Map<String, dynamic> toJson() => _$BillingAddressToJson(this);

  String get formattedAddress {
    final parts = <String>[
      fullName,
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2!,
      '$city, $state $postalCode',
      country,
    ];
    return parts.join('\n');
  }
}
