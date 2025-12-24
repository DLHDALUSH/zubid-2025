// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 4;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      id: fields[0] as int,
      orderNumber: fields[1] as String,
      userId: fields[2] as int,
      auctionId: fields[3] as int,
      auctionTitle: fields[4] as String,
      auctionImage: fields[5] as String?,
      sellerId: fields[6] as int,
      sellerName: fields[7] as String,
      purchasePrice: fields[8] as double,
      shippingCost: fields[9] as double,
      taxAmount: fields[10] as double,
      totalAmount: fields[11] as double,
      paymentMethod: fields[12] as String,
      paymentStatus: fields[13] as String,
      orderStatus: fields[14] as String,
      shippingAddress: fields[15] as ShippingAddress,
      billingAddress: fields[16] as BillingAddress?,
      trackingNumber: fields[17] as String?,
      estimatedDelivery: fields[18] as DateTime?,
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
      shippedAt: fields[21] as DateTime?,
      deliveredAt: fields[22] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.auctionId)
      ..writeByte(4)
      ..write(obj.auctionTitle)
      ..writeByte(5)
      ..write(obj.auctionImage)
      ..writeByte(6)
      ..write(obj.sellerId)
      ..writeByte(7)
      ..write(obj.sellerName)
      ..writeByte(8)
      ..write(obj.purchasePrice)
      ..writeByte(9)
      ..write(obj.shippingCost)
      ..writeByte(10)
      ..write(obj.taxAmount)
      ..writeByte(11)
      ..write(obj.totalAmount)
      ..writeByte(12)
      ..write(obj.paymentMethod)
      ..writeByte(13)
      ..write(obj.paymentStatus)
      ..writeByte(14)
      ..write(obj.orderStatus)
      ..writeByte(15)
      ..write(obj.shippingAddress)
      ..writeByte(16)
      ..write(obj.billingAddress)
      ..writeByte(17)
      ..write(obj.trackingNumber)
      ..writeByte(18)
      ..write(obj.estimatedDelivery)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(21)
      ..write(obj.shippedAt)
      ..writeByte(22)
      ..write(obj.deliveredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShippingAddressAdapter extends TypeAdapter<ShippingAddress> {
  @override
  final int typeId = 5;

  @override
  ShippingAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShippingAddress(
      fullName: fields[0] as String,
      addressLine1: fields[1] as String,
      addressLine2: fields[2] as String?,
      city: fields[3] as String,
      state: fields[4] as String,
      postalCode: fields[5] as String,
      country: fields[6] as String,
      phoneNumber: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShippingAddress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fullName)
      ..writeByte(1)
      ..write(obj.addressLine1)
      ..writeByte(2)
      ..write(obj.addressLine2)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.postalCode)
      ..writeByte(6)
      ..write(obj.country)
      ..writeByte(7)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillingAddressAdapter extends TypeAdapter<BillingAddress> {
  @override
  final int typeId = 6;

  @override
  BillingAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillingAddress(
      fullName: fields[0] as String,
      addressLine1: fields[1] as String,
      addressLine2: fields[2] as String?,
      city: fields[3] as String,
      state: fields[4] as String,
      postalCode: fields[5] as String,
      country: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BillingAddress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.fullName)
      ..writeByte(1)
      ..write(obj.addressLine1)
      ..writeByte(2)
      ..write(obj.addressLine2)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.postalCode)
      ..writeByte(6)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: (json['id'] as num).toInt(),
      orderNumber: json['order_number'] as String,
      userId: (json['user_id'] as num).toInt(),
      auctionId: (json['auction_id'] as num).toInt(),
      auctionTitle: json['auction_title'] as String,
      auctionImage: json['auction_image'] as String?,
      sellerId: (json['seller_id'] as num).toInt(),
      sellerName: json['seller_name'] as String,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      shippingAddress: ShippingAddress.fromJson(
          json['shipping_address'] as Map<String, dynamic>),
      billingAddress: json['billing_address'] == null
          ? null
          : BillingAddress.fromJson(
              json['billing_address'] as Map<String, dynamic>),
      trackingNumber: json['tracking_number'] as String?,
      estimatedDelivery: json['estimated_delivery'] == null
          ? null
          : DateTime.parse(json['estimated_delivery'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      shippedAt: json['shipped_at'] == null
          ? null
          : DateTime.parse(json['shipped_at'] as String),
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'user_id': instance.userId,
      'auction_id': instance.auctionId,
      'auction_title': instance.auctionTitle,
      'auction_image': instance.auctionImage,
      'seller_id': instance.sellerId,
      'seller_name': instance.sellerName,
      'purchase_price': instance.purchasePrice,
      'shipping_cost': instance.shippingCost,
      'tax_amount': instance.taxAmount,
      'total_amount': instance.totalAmount,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'order_status': instance.orderStatus,
      'shipping_address': instance.shippingAddress,
      'billing_address': instance.billingAddress,
      'tracking_number': instance.trackingNumber,
      'estimated_delivery': instance.estimatedDelivery?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'shipped_at': instance.shippedAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
    };

ShippingAddress _$ShippingAddressFromJson(Map<String, dynamic> json) =>
    ShippingAddress(
      fullName: json['full_name'] as String,
      addressLine1: json['address_line_1'] as String,
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      phoneNumber: json['phone_number'] as String?,
    );

Map<String, dynamic> _$ShippingAddressToJson(ShippingAddress instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'address_line_1': instance.addressLine1,
      'address_line_2': instance.addressLine2,
      'city': instance.city,
      'state': instance.state,
      'postal_code': instance.postalCode,
      'country': instance.country,
      'phone_number': instance.phoneNumber,
    };

BillingAddress _$BillingAddressFromJson(Map<String, dynamic> json) =>
    BillingAddress(
      fullName: json['full_name'] as String,
      addressLine1: json['address_line_1'] as String,
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
    );

Map<String, dynamic> _$BillingAddressToJson(BillingAddress instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'address_line_1': instance.addressLine1,
      'address_line_2': instance.addressLine2,
      'city': instance.city,
      'state': instance.state,
      'postal_code': instance.postalCode,
      'country': instance.country,
    };
