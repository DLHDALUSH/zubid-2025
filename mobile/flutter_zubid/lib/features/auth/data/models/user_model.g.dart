// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as int,
      username: fields[1] as String,
      email: fields[2] as String,
      firstName: fields[3] as String?,
      lastName: fields[4] as String?,
      phoneNumber: fields[5] as String?,
      profilePhotoUrl: fields[6] as String?,
      idNumber: fields[7] as String?,
      address: fields[8] as String?,
      city: fields[9] as String?,
      country: fields[10] as String?,
      postalCode: fields[11] as String?,
      dateOfBirth: fields[12] as DateTime?,
      role: fields[13] as String,
      isActive: fields[14] as bool,
      isVerified: fields[15] as bool,
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime,
      rating: fields[18] as double?,
      totalBids: fields[19] as int?,
      totalWins: fields[20] as int?,
      totalSpent: fields[21] as double?,
      emailVerified: fields[22] as bool?,
      phoneVerified: fields[23] as bool?,
      preferredLanguage: fields[24] as String?,
      timezone: fields[25] as String?,
      preferences: (fields[26] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(27)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.firstName)
      ..writeByte(4)
      ..write(obj.lastName)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.profilePhotoUrl)
      ..writeByte(7)
      ..write(obj.idNumber)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.city)
      ..writeByte(10)
      ..write(obj.country)
      ..writeByte(11)
      ..write(obj.postalCode)
      ..writeByte(12)
      ..write(obj.dateOfBirth)
      ..writeByte(13)
      ..write(obj.role)
      ..writeByte(14)
      ..write(obj.isActive)
      ..writeByte(15)
      ..write(obj.isVerified)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt)
      ..writeByte(18)
      ..write(obj.rating)
      ..writeByte(19)
      ..write(obj.totalBids)
      ..writeByte(20)
      ..write(obj.totalWins)
      ..writeByte(21)
      ..write(obj.totalSpent)
      ..writeByte(22)
      ..write(obj.emailVerified)
      ..writeByte(23)
      ..write(obj.phoneVerified)
      ..writeByte(24)
      ..write(obj.preferredLanguage)
      ..writeByte(25)
      ..write(obj.timezone)
      ..writeByte(26)
      ..write(obj.preferences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      idNumber: json['id_number'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      role: json['role'] as String? ?? 'user',
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      rating: (json['rating'] as num?)?.toDouble(),
      totalBids: json['total_bids'] as int?,
      totalWins: json['total_wins'] as int?,
      totalSpent: (json['total_spent'] as num?)?.toDouble(),
      emailVerified: json['email_verified'] as bool?,
      phoneVerified: json['phone_verified'] as bool?,
      preferredLanguage: json['preferred_language'] as String?,
      timezone: json['timezone'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'profile_photo_url': instance.profilePhotoUrl,
      'id_number': instance.idNumber,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'postal_code': instance.postalCode,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'role': instance.role,
      'is_active': instance.isActive,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'rating': instance.rating,
      'total_bids': instance.totalBids,
      'total_wins': instance.totalWins,
      'total_spent': instance.totalSpent,
      'email_verified': instance.emailVerified,
      'phone_verified': instance.phoneVerified,
      'preferred_language': instance.preferredLanguage,
      'timezone': instance.timezone,
      'preferences': instance.preferences,
    };
