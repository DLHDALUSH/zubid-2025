// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      savePaymentMethod: json['savePaymentMethod'] as bool? ?? false,
      returnUrl: json['returnUrl'] as String?,
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'paymentMethodId': instance.paymentMethodId,
      'description': instance.description,
      'referenceId': instance.referenceId,
      'referenceType': instance.referenceType,
      'metadata': instance.metadata,
      'savePaymentMethod': instance.savePaymentMethod,
      'returnUrl': instance.returnUrl,
    };

PaymentResponse _$PaymentResponseFromJson(Map<String, dynamic> json) =>
    PaymentResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      clientSecret: json['clientSecret'] as String?,
      paymentIntentId: json['paymentIntentId'] as String?,
      confirmationUrl: json['confirmationUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentResponseToJson(PaymentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'clientSecret': instance.clientSecret,
      'paymentIntentId': instance.paymentIntentId,
      'confirmationUrl': instance.confirmationUrl,
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };

CardDetails _$CardDetailsFromJson(Map<String, dynamic> json) => CardDetails(
      number: json['number'] as String,
      expMonth: json['expMonth'] as String,
      expYear: json['expYear'] as String,
      cvc: json['cvc'] as String,
      holderName: json['holderName'] as String?,
    );

Map<String, dynamic> _$CardDetailsToJson(CardDetails instance) =>
    <String, dynamic>{
      'number': instance.number,
      'expMonth': instance.expMonth,
      'expYear': instance.expYear,
      'cvc': instance.cvc,
      'holderName': instance.holderName,
    };

PayPalDetails _$PayPalDetailsFromJson(Map<String, dynamic> json) =>
    PayPalDetails(
      email: json['email'] as String,
      authorizationCode: json['authorizationCode'] as String?,
    );

Map<String, dynamic> _$PayPalDetailsToJson(PayPalDetails instance) =>
    <String, dynamic>{
      'email': instance.email,
      'authorizationCode': instance.authorizationCode,
    };

BankDetails _$BankDetailsFromJson(Map<String, dynamic> json) => BankDetails(
      accountNumber: json['accountNumber'] as String,
      routingNumber: json['routingNumber'] as String,
      accountType: json['accountType'] as String,
      accountHolderName: json['accountHolderName'] as String?,
      bankName: json['bankName'] as String?,
    );

Map<String, dynamic> _$BankDetailsToJson(BankDetails instance) =>
    <String, dynamic>{
      'accountNumber': instance.accountNumber,
      'routingNumber': instance.routingNumber,
      'accountType': instance.accountType,
      'accountHolderName': instance.accountHolderName,
      'bankName': instance.bankName,
    };

FibDetails _$FibDetailsFromJson(Map<String, dynamic> json) => FibDetails(
      accountNumber: json['accountNumber'] as String,
      accountHolderName: json['accountHolderName'] as String,
      branchCode: json['branchCode'] as String?,
      iban: json['iban'] as String?,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$FibDetailsToJson(FibDetails instance) =>
    <String, dynamic>{
      'accountNumber': instance.accountNumber,
      'accountHolderName': instance.accountHolderName,
      'branchCode': instance.branchCode,
      'iban': instance.iban,
      'phoneNumber': instance.phoneNumber,
    };

ZainCashDetails _$ZainCashDetailsFromJson(Map<String, dynamic> json) =>
    ZainCashDetails(
      phoneNumber: json['phoneNumber'] as String,
      pin: json['pin'] as String,
      accountHolderName: json['accountHolderName'] as String?,
    );

Map<String, dynamic> _$ZainCashDetailsToJson(ZainCashDetails instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'pin': instance.pin,
      'accountHolderName': instance.accountHolderName,
    };

RefundRequest _$RefundRequestFromJson(Map<String, dynamic> json) =>
    RefundRequest(
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      reason: json['reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RefundRequestToJson(RefundRequest instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'amount': instance.amount,
      'reason': instance.reason,
      'metadata': instance.metadata,
    };

RefundResponse _$RefundResponseFromJson(Map<String, dynamic> json) =>
    RefundResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionId: json['transactionId'] as String,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RefundResponseToJson(RefundResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'transactionId': instance.transactionId,
      'reason': instance.reason,
      'createdAt': instance.createdAt.toIso8601String(),
    };
