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
      cardLast4: json['cardLast4'] as String?,
      cardBrand: json['cardBrand'] as String?,
      cardExpMonth: json['cardExpMonth'] as String?,
      cardExpYear: json['cardExpYear'] as String?,
      email: json['email'] as String?,
      bankName: json['bankName'] as String?,
      accountLast4: json['accountLast4'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'cardLast4': instance.cardLast4,
      'cardBrand': instance.cardBrand,
      'cardExpMonth': instance.cardExpMonth,
      'cardExpYear': instance.cardExpYear,
      'email': instance.email,
      'bankName': instance.bankName,
      'accountLast4': instance.accountLast4,
      'isDefault': instance.isDefault,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
