// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuctionModelAdapter extends TypeAdapter<AuctionModel> {
  @override
  final int typeId = 2;

  @override
  AuctionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuctionModel(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String,
      startingPrice: fields[3] as double,
      currentPrice: fields[4] as double,
      buyNowPrice: fields[5] as double?,
      reservePrice: fields[6] as double?,
      startTime: fields[7] as DateTime,
      endTime: fields[8] as DateTime,
      status: fields[9] as String,
      categoryId: fields[10] as int,
      categoryName: fields[11] as String,
      sellerId: fields[12] as int,
      sellerUsername: fields[13] as String,
      sellerRating: fields[14] as double?,
      imageUrls: (fields[15] as List).cast<String>(),
      thumbnailUrl: fields[16] as String?,
      bidCount: fields[17] as int,
      viewCount: fields[18] as int,
      watchCount: fields[19] as int,
      isFeatured: fields[20] as bool,
      isWatched: fields[21] as bool,
      shippingCost: fields[22] as double?,
      shippingInfo: fields[23] as String?,
      condition: fields[24] as String?,
      location: fields[25] as String?,
      createdAt: fields[26] as DateTime,
      updatedAt: fields[27] as DateTime,
      sellerAvatar: fields[28] as String?,
      sellerVerified: fields[29] as bool?,
      shippingMethod: fields[30] as String?,
      estimatedDelivery: fields[31] as String?,
      shipsFrom: fields[32] as String?,
      shipsTo: fields[33] as String?,
      handlingTime: fields[34] as String?,
      returnPolicy: fields[35] as String?,
      shippingNotes: fields[36] as String?,
      images: (fields[37] as List?)?.cast<String>(),
      minimumBid: fields[38] as double?,
      currentBid: fields[39] as double?,
      hasSold: fields[40] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, AuctionModel obj) {
    writer
      ..writeByte(41)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startingPrice)
      ..writeByte(4)
      ..write(obj.currentPrice)
      ..writeByte(5)
      ..write(obj.buyNowPrice)
      ..writeByte(6)
      ..write(obj.reservePrice)
      ..writeByte(7)
      ..write(obj.startTime)
      ..writeByte(8)
      ..write(obj.endTime)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.categoryId)
      ..writeByte(11)
      ..write(obj.categoryName)
      ..writeByte(12)
      ..write(obj.sellerId)
      ..writeByte(13)
      ..write(obj.sellerUsername)
      ..writeByte(14)
      ..write(obj.sellerRating)
      ..writeByte(15)
      ..write(obj.imageUrls)
      ..writeByte(16)
      ..write(obj.thumbnailUrl)
      ..writeByte(17)
      ..write(obj.bidCount)
      ..writeByte(18)
      ..write(obj.viewCount)
      ..writeByte(19)
      ..write(obj.watchCount)
      ..writeByte(20)
      ..write(obj.isFeatured)
      ..writeByte(21)
      ..write(obj.isWatched)
      ..writeByte(22)
      ..write(obj.shippingCost)
      ..writeByte(23)
      ..write(obj.shippingInfo)
      ..writeByte(24)
      ..write(obj.condition)
      ..writeByte(25)
      ..write(obj.location)
      ..writeByte(26)
      ..write(obj.createdAt)
      ..writeByte(27)
      ..write(obj.updatedAt)
      ..writeByte(28)
      ..write(obj.sellerAvatar)
      ..writeByte(29)
      ..write(obj.sellerVerified)
      ..writeByte(30)
      ..write(obj.shippingMethod)
      ..writeByte(31)
      ..write(obj.estimatedDelivery)
      ..writeByte(32)
      ..write(obj.shipsFrom)
      ..writeByte(33)
      ..write(obj.shipsTo)
      ..writeByte(34)
      ..write(obj.handlingTime)
      ..writeByte(35)
      ..write(obj.returnPolicy)
      ..writeByte(36)
      ..write(obj.shippingNotes)
      ..writeByte(37)
      ..write(obj.images)
      ..writeByte(38)
      ..write(obj.minimumBid)
      ..writeByte(39)
      ..write(obj.currentBid)
      ..writeByte(40)
      ..write(obj.hasSold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuctionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuctionModel _$AuctionModelFromJson(Map<String, dynamic> json) => AuctionModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      startingPrice: (json['starting_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      buyNowPrice: (json['buy_now_price'] as num?)?.toDouble(),
      reservePrice: (json['reserve_price'] as num?)?.toDouble(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      categoryId: (json['category_id'] as num).toInt(),
      categoryName: json['category_name'] as String,
      sellerId: (json['seller_id'] as num).toInt(),
      sellerUsername: json['seller_username'] as String,
      sellerRating: (json['seller_rating'] as num?)?.toDouble(),
      imageUrls: (json['image_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      bidCount: (json['bid_count'] as num).toInt(),
      viewCount: (json['view_count'] as num).toInt(),
      watchCount: (json['watch_count'] as num).toInt(),
      isFeatured: json['is_featured'] as bool,
      isWatched: json['is_watched'] as bool,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble(),
      shippingInfo: json['shipping_info'] as String?,
      condition: json['condition'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sellerAvatar: json['seller_avatar'] as String?,
      sellerVerified: json['seller_verified'] as bool?,
      shippingMethod: json['shipping_method'] as String?,
      estimatedDelivery: json['estimated_delivery'] as String?,
      shipsFrom: json['ships_from'] as String?,
      shipsTo: json['ships_to'] as String?,
      handlingTime: json['handling_time'] as String?,
      returnPolicy: json['return_policy'] as String?,
      shippingNotes: json['shipping_notes'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      minimumBid: (json['minimum_bid'] as num?)?.toDouble(),
      currentBid: (json['current_bid'] as num?)?.toDouble(),
      hasSold: json['has_sold'] as bool?,
    );

Map<String, dynamic> _$AuctionModelToJson(AuctionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'starting_price': instance.startingPrice,
      'current_price': instance.currentPrice,
      'buy_now_price': instance.buyNowPrice,
      'reserve_price': instance.reservePrice,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'status': instance.status,
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'seller_id': instance.sellerId,
      'seller_username': instance.sellerUsername,
      'seller_rating': instance.sellerRating,
      'image_urls': instance.imageUrls,
      'thumbnail_url': instance.thumbnailUrl,
      'bid_count': instance.bidCount,
      'view_count': instance.viewCount,
      'watch_count': instance.watchCount,
      'is_featured': instance.isFeatured,
      'is_watched': instance.isWatched,
      'shipping_cost': instance.shippingCost,
      'shipping_info': instance.shippingInfo,
      'condition': instance.condition,
      'location': instance.location,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'seller_avatar': instance.sellerAvatar,
      'seller_verified': instance.sellerVerified,
      'shipping_method': instance.shippingMethod,
      'estimated_delivery': instance.estimatedDelivery,
      'ships_from': instance.shipsFrom,
      'ships_to': instance.shipsTo,
      'handling_time': instance.handlingTime,
      'return_policy': instance.returnPolicy,
      'shipping_notes': instance.shippingNotes,
      'images': instance.images,
      'minimum_bid': instance.minimumBid,
      'current_bid': instance.currentBid,
      'has_sold': instance.hasSold,
    };
