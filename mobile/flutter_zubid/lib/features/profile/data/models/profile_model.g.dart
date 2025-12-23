// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final int typeId = 1;

  @override
  ProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileModel(
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
      bio: fields[13] as String?,
      preferredLanguage: fields[14] as String?,
      timezone: fields[15] as String?,
      emailVerified: fields[16] as bool,
      phoneVerified: fields[17] as bool,
      profileCompleted: fields[18] as bool,
      rating: fields[19] as double?,
      totalBids: fields[20] as int,
      totalWins: fields[21] as int,
      totalSpent: fields[22] as double,
      memberSince: fields[23] as DateTime,
      lastActive: fields[24] as DateTime?,
      preferences: (fields[25] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[26] as DateTime?,
      updatedAt: fields[27] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer
      ..writeByte(28)
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
      ..write(obj.bio)
      ..writeByte(14)
      ..write(obj.preferredLanguage)
      ..writeByte(15)
      ..write(obj.timezone)
      ..writeByte(16)
      ..write(obj.emailVerified)
      ..writeByte(17)
      ..write(obj.phoneVerified)
      ..writeByte(18)
      ..write(obj.profileCompleted)
      ..writeByte(19)
      ..write(obj.rating)
      ..writeByte(20)
      ..write(obj.totalBids)
      ..writeByte(21)
      ..write(obj.totalWins)
      ..writeByte(22)
      ..write(obj.totalSpent)
      ..writeByte(23)
      ..write(obj.memberSince)
      ..writeByte(24)
      ..write(obj.lastActive)
      ..writeByte(25)
      ..write(obj.preferences)
      ..writeByte(26)
      ..write(obj.createdAt)
      ..writeByte(27)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: (json['id'] as num).toInt(),
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
      bio: json['bio'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      timezone: json['timezone'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      profileCompleted: json['profile_completed'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalBids: (json['total_bids'] as num?)?.toInt() ?? 0,
      totalWins: (json['total_wins'] as num?)?.toInt() ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      memberSince: DateTime.parse(json['member_since'] as String),
      lastActive: json['last_active'] == null
          ? null
          : DateTime.parse(json['last_active'] as String),
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
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
      'bio': instance.bio,
      'preferred_language': instance.preferredLanguage,
      'timezone': instance.timezone,
      'email_verified': instance.emailVerified,
      'phone_verified': instance.phoneVerified,
      'profile_completed': instance.profileCompleted,
      'rating': instance.rating,
      'total_bids': instance.totalBids,
      'total_wins': instance.totalWins,
      'total_spent': instance.totalSpent,
      'member_since': instance.memberSince.toIso8601String(),
      'last_active': instance.lastActive?.toIso8601String(),
      'preferences': instance.preferences,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
