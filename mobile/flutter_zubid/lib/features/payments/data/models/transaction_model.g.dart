// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 8;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      type: fields[1] as String,
      status: fields[2] as String,
      amount: fields[3] as double,
      currency: fields[4] as String,
      description: fields[5] as String?,
      referenceId: fields[6] as String?,
      referenceType: fields[7] as String?,
      paymentMethodId: fields[8] as String?,
      paymentMethodType: fields[9] as String?,
      paymentMethodLast4: fields[10] as String?,
      stripePaymentIntentId: fields[11] as String?,
      razorpayPaymentId: fields[12] as String?,
      paypalTransactionId: fields[13] as String?,
      feeAmount: fields[14] as double?,
      netAmount: fields[15] as double?,
      failureReason: fields[16] as String?,
      metadata: (fields[17] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime?,
      completedAt: fields[20] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.referenceId)
      ..writeByte(7)
      ..write(obj.referenceType)
      ..writeByte(8)
      ..write(obj.paymentMethodId)
      ..writeByte(9)
      ..write(obj.paymentMethodType)
      ..writeByte(10)
      ..write(obj.paymentMethodLast4)
      ..writeByte(11)
      ..write(obj.stripePaymentIntentId)
      ..writeByte(12)
      ..write(obj.razorpayPaymentId)
      ..writeByte(13)
      ..write(obj.paypalTransactionId)
      ..writeByte(14)
      ..write(obj.feeAmount)
      ..writeByte(15)
      ..write(obj.netAmount)
      ..writeByte(16)
      ..write(obj.failureReason)
      ..writeByte(17)
      ..write(obj.metadata)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String?,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      paymentMethodId: json['payment_method_id'] as String?,
      paymentMethodType: json['payment_method_type'] as String?,
      paymentMethodLast4: json['payment_method_last4'] as String?,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      paypalTransactionId: json['paypal_transaction_id'] as String?,
      feeAmount: (json['fee_amount'] as num?)?.toDouble(),
      netAmount: (json['net_amount'] as num?)?.toDouble(),
      failureReason: json['failure_reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'description': instance.description,
      'reference_id': instance.referenceId,
      'reference_type': instance.referenceType,
      'payment_method_id': instance.paymentMethodId,
      'payment_method_type': instance.paymentMethodType,
      'payment_method_last4': instance.paymentMethodLast4,
      'stripe_payment_intent_id': instance.stripePaymentIntentId,
      'razorpay_payment_id': instance.razorpayPaymentId,
      'paypal_transaction_id': instance.paypalTransactionId,
      'fee_amount': instance.feeAmount,
      'net_amount': instance.netAmount,
      'failure_reason': instance.failureReason,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };
