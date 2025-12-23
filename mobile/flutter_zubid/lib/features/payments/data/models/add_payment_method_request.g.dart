// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_payment_method_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddPaymentMethodRequest _$AddPaymentMethodRequestFromJson(
        Map<String, dynamic> json) =>
    AddPaymentMethodRequest(
      type: json['type'] as String,
      cardNumber: json['cardNumber'] as String?,
      expiryMonth: json['expiryMonth'] as String?,
      expiryYear: json['expiryYear'] as String?,
      cvv: json['cvv'] as String?,
      cardHolderName: json['cardHolderName'] as String?,
      fibAccountNumber: json['fibAccountNumber'] as String?,
      zainCashNumber: json['zainCashNumber'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$AddPaymentMethodRequestToJson(
        AddPaymentMethodRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'cardNumber': instance.cardNumber,
      'expiryMonth': instance.expiryMonth,
      'expiryYear': instance.expiryYear,
      'cvv': instance.cvv,
      'cardHolderName': instance.cardHolderName,
      'fibAccountNumber': instance.fibAccountNumber,
      'zainCashNumber': instance.zainCashNumber,
      'isDefault': instance.isDefault,
    };
