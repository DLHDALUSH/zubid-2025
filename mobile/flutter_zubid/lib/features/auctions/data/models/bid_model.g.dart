// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BidModelAdapter extends TypeAdapter<BidModel> {
  @override
  final int typeId = 3;

  @override
  BidModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BidModel(
      id: fields[0] as int,
      auctionId: fields[1] as int,
      userId: fields[2] as int,
      amount: fields[3] as double,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      isWinning: fields[6] as bool,
      isAutoBid: fields[7] as bool,
      maxBidAmount: fields[8] as double?,
      username: fields[9] as String,
      userAvatar: fields[10] as String?,
      userRating: fields[11] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BidModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.auctionId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.isWinning)
      ..writeByte(7)
      ..write(obj.isAutoBid)
      ..writeByte(8)
      ..write(obj.maxBidAmount)
      ..writeByte(9)
      ..write(obj.username)
      ..writeByte(10)
      ..write(obj.userAvatar)
      ..writeByte(11)
      ..write(obj.userRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BidModel _$BidModelFromJson(Map<String, dynamic> json) => BidModel(
      id: (json['id'] as num).toInt(),
      auctionId: (json['auction_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isWinning: json['is_winning'] as bool? ?? false,
      isAutoBid: json['is_auto_bid'] as bool? ?? false,
      maxBidAmount: (json['max_bid_amount'] as num?)?.toDouble(),
      username: json['user_username'] as String,
      userAvatar: json['user_avatar'] as String?,
      userRating: (json['user_rating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BidModelToJson(BidModel instance) => <String, dynamic>{
      'id': instance.id,
      'auction_id': instance.auctionId,
      'user_id': instance.userId,
      'amount': instance.amount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_winning': instance.isWinning,
      'is_auto_bid': instance.isAutoBid,
      'max_bid_amount': instance.maxBidAmount,
      'user_username': instance.username,
      'user_avatar': instance.userAvatar,
      'user_rating': instance.userRating,
    };
