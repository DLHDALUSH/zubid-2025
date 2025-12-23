// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethodId: json['payment_method_id'] as String,
      description: json['description'] as String?,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      savePaymentMethod: json['save_payment_method'] as bool? ?? false,
      returnUrl: json['return_url'] as String?,
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'payment_method_id': instance.paymentMethodId,
      'description': instance.description,
      'reference_id': instance.referenceId,
      'reference_type': instance.referenceType,
      'metadata': instance.metadata,
      'save_payment_method': instance.savePaymentMethod,
      'return_url': instance.returnUrl,
    };

PaymentResponse _$PaymentResponseFromJson(Map<String, dynamic> json) =>
    PaymentResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      clientSecret: json['client_secret'] as String?,
      paymentIntentId: json['payment_intent_id'] as String?,
      confirmationUrl: json['confirmation_url'] as String?,
      errorMessage: json['error_message'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentResponseToJson(PaymentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'client_secret': instance.clientSecret,
      'payment_intent_id': instance.paymentIntentId,
      'confirmation_url': instance.confirmationUrl,
      'error_message': instance.errorMessage,
      'metadata': instance.metadata,
    };

AddPaymentMethodRequest _$AddPaymentMethodRequestFromJson(
        Map<String, dynamic> json) =>
    AddPaymentMethodRequest(
      type: json['type'] as String,
      token: json['token'] as String?,
      cardDetails: json['card_details'] == null
          ? null
          : CardDetails.fromJson(json['card_details'] as Map<String, dynamic>),
      paypalDetails: json['paypal_details'] == null
          ? null
          : PayPalDetails.fromJson(
              json['paypal_details'] as Map<String, dynamic>),
      bankDetails: json['bank_details'] == null
          ? null
          : BankDetails.fromJson(json['bank_details'] as Map<String, dynamic>),
      fibDetails: json['fib_details'] == null
          ? null
          : FibDetails.fromJson(json['fib_details'] as Map<String, dynamic>),
      zainCashDetails: json['zain_cash_details'] == null
          ? null
          : ZainCashDetails.fromJson(
              json['zain_cash_details'] as Map<String, dynamic>),
      setAsDefault: json['set_as_default'] as bool? ?? false,
    );

Map<String, dynamic> _$AddPaymentMethodRequestToJson(
        AddPaymentMethodRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'token': instance.token,
      'card_details': instance.cardDetails,
      'paypal_details': instance.paypalDetails,
      'bank_details': instance.bankDetails,
      'fib_details': instance.fibDetails,
      'zain_cash_details': instance.zainCashDetails,
      'set_as_default': instance.setAsDefault,
    };

CardDetails _$CardDetailsFromJson(Map<String, dynamic> json) => CardDetails(
      number: json['number'] as String,
      expMonth: json['exp_month'] as String,
      expYear: json['exp_year'] as String,
      cvc: json['cvc'] as String,
      holderName: json['holder_name'] as String?,
    );

Map<String, dynamic> _$CardDetailsToJson(CardDetails instance) =>
    <String, dynamic>{
      'number': instance.number,
      'exp_month': instance.expMonth,
      'exp_year': instance.expYear,
      'cvc': instance.cvc,
      'holder_name': instance.holderName,
    };

PayPalDetails _$PayPalDetailsFromJson(Map<String, dynamic> json) =>
    PayPalDetails(
      email: json['email'] as String,
      authorizationCode: json['authorization_code'] as String?,
    );

Map<String, dynamic> _$PayPalDetailsToJson(PayPalDetails instance) =>
    <String, dynamic>{
      'email': instance.email,
      'authorization_code': instance.authorizationCode,
    };

BankDetails _$BankDetailsFromJson(Map<String, dynamic> json) => BankDetails(
      accountNumber: json['account_number'] as String,
      routingNumber: json['routing_number'] as String,
      accountType: json['account_type'] as String,
      accountHolderName: json['account_holder_name'] as String?,
      bankName: json['bank_name'] as String?,
    );

Map<String, dynamic> _$BankDetailsToJson(BankDetails instance) =>
    <String, dynamic>{
      'account_number': instance.accountNumber,
      'routing_number': instance.routingNumber,
      'account_type': instance.accountType,
      'account_holder_name': instance.accountHolderName,
      'bank_name': instance.bankName,
    };

RefundRequest _$RefundRequestFromJson(Map<String, dynamic> json) =>
    RefundRequest(
      transactionId: json['transaction_id'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      reason: json['reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RefundRequestToJson(RefundRequest instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
      'amount': instance.amount,
      'reason': instance.reason,
      'metadata': instance.metadata,
    };

FibDetails _$FibDetailsFromJson(Map<String, dynamic> json) => FibDetails(
      accountNumber: json['account_number'] as String,
      accountHolderName: json['account_holder_name'] as String,
      branchCode: json['branch_code'] as String?,
      iban: json['iban'] as String?,
      phoneNumber: json['phone_number'] as String,
    );

Map<String, dynamic> _$FibDetailsToJson(FibDetails instance) =>
    <String, dynamic>{
      'account_number': instance.accountNumber,
      'account_holder_name': instance.accountHolderName,
      'branch_code': instance.branchCode,
      'iban': instance.iban,
      'phone_number': instance.phoneNumber,
    };

ZainCashDetails _$ZainCashDetailsFromJson(Map<String, dynamic> json) =>
    ZainCashDetails(
      phoneNumber: json['phone_number'] as String,
      pin: json['pin'] as String,
      accountHolderName: json['account_holder_name'] as String?,
    );

Map<String, dynamic> _$ZainCashDetailsToJson(ZainCashDetails instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'pin': instance.pin,
      'account_holder_name': instance.accountHolderName,
    };

RefundRequest _$RefundRequestFromJson(Map<String, dynamic> json) =>
    RefundRequest(
      transactionId: json['transaction_id'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      reason: json['reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RefundRequestToJson(RefundRequest instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
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
      transactionId: json['transaction_id'] as String,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RefundResponseToJson(RefundResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'transaction_id': instance.transactionId,
      'reason': instance.reason,
      'created_at': instance.createdAt.toIso8601String(),
    };
