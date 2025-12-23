// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentMethodModelAdapter extends TypeAdapter<PaymentMethodModel> {
  @override
  final int typeId = 7;

  @override
  PaymentMethodModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentMethodModel(
      id: fields[0] as String,
      type: fields[1] as String,
      cardLast4: fields[2] as String?,
      cardBrand: fields[3] as String?,
      cardExpMonth: fields[4] as String?,
      cardExpYear: fields[5] as String?,
      email: fields[6] as String?,
      bankName: fields[7] as String?,
      accountLast4: fields[8] as String?,
      isDefault: fields[9] as bool,
      isVerified: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentMethodModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.cardLast4)
      ..writeByte(3)
      ..write(obj.cardBrand)
      ..writeByte(4)
      ..write(obj.cardExpMonth)
      ..writeByte(5)
      ..write(obj.cardExpYear)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.bankName)
      ..writeByte(8)
      ..write(obj.accountLast4)
      ..writeByte(9)
      ..write(obj.isDefault)
      ..writeByte(10)
      ..write(obj.isVerified)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(
      id: json['id'] as String,
      type: json['type'] as String,
      cardLast4: json['card_last4'] as String?,
      cardBrand: json['card_brand'] as String?,
      cardExpMonth: json['card_exp_month'] as String?,
      cardExpYear: json['card_exp_year'] as String?,
      email: json['email'] as String?,
      bankName: json['bank_name'] as String?,
      accountLast4: json['account_last4'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'card_last4': instance.cardLast4,
      'card_brand': instance.cardBrand,
      'card_exp_month': instance.cardExpMonth,
      'card_exp_year': instance.cardExpYear,
      'email': instance.email,
      'bank_name': instance.bankName,
      'account_last4': instance.accountLast4,
      'is_default': instance.isDefault,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
