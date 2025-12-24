import 'package:json_annotation/json_annotation.dart';

part 'payment_request_model.g.dart';

@JsonSerializable()
class PaymentRequest {
  final double amount;
  final String currency;
  final String paymentMethodId;
  final String? description;
  final String? referenceId;
  final String? referenceType;
  final Map<String, dynamic>? metadata;
  final bool savePaymentMethod;
  final String? returnUrl;

  const PaymentRequest({
    required this.amount,
    required this.currency,
    required this.paymentMethodId,
    this.description,
    this.referenceId,
    this.referenceType,
    this.metadata,
    this.savePaymentMethod = false,
    this.returnUrl,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}

@JsonSerializable()
class PaymentResponse {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final String? clientSecret;
  final String? paymentIntentId;
  final String? confirmationUrl;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const PaymentResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    this.clientSecret,
    this.paymentIntentId,
    this.confirmationUrl,
    this.errorMessage,
    this.metadata,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);

  bool get requiresAction => status == 'requires_action';
  bool get isSucceeded => status == 'succeeded';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
}



@JsonSerializable()
class CardDetails {
  final String number;
  final String expMonth;
  final String expYear;
  final String cvc;
  final String? holderName;

  const CardDetails({
    required this.number,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
    this.holderName,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) =>
      _$CardDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CardDetailsToJson(this);
}

@JsonSerializable()
class PayPalDetails {
  final String email;
  final String? authorizationCode;

  const PayPalDetails({
    required this.email,
    this.authorizationCode,
  });

  factory PayPalDetails.fromJson(Map<String, dynamic> json) =>
      _$PayPalDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PayPalDetailsToJson(this);
}

@JsonSerializable()
class BankDetails {
  final String accountNumber;
  final String routingNumber;
  final String accountType; // 'checking', 'savings'
  final String? accountHolderName;
  final String? bankName;

  const BankDetails({
    required this.accountNumber,
    required this.routingNumber,
    required this.accountType,
    this.accountHolderName,
    this.bankName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) =>
      _$BankDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BankDetailsToJson(this);
}

@JsonSerializable()
class FibDetails {
  final String accountNumber;
  final String accountHolderName;
  final String? branchCode;
  final String? iban; // International Bank Account Number
  final String phoneNumber; // For verification

  const FibDetails({
    required this.accountNumber,
    required this.accountHolderName,
    this.branchCode,
    this.iban,
    required this.phoneNumber,
  });

  factory FibDetails.fromJson(Map<String, dynamic> json) =>
      _$FibDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$FibDetailsToJson(this);
}

@JsonSerializable()
class ZainCashDetails {
  final String phoneNumber; // ZAIN mobile number
  final String pin; // ZAIN CASH PIN
  final String? accountHolderName;

  const ZainCashDetails({
    required this.phoneNumber,
    required this.pin,
    this.accountHolderName,
  });

  factory ZainCashDetails.fromJson(Map<String, dynamic> json) =>
      _$ZainCashDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ZainCashDetailsToJson(this);
}

@JsonSerializable()
class RefundRequest {
  final String transactionId;
  final double? amount; // Null for full refund
  final String? reason;
  final Map<String, dynamic>? metadata;

  const RefundRequest({
    required this.transactionId,
    this.amount,
    this.reason,
    this.metadata,
  });

  factory RefundRequest.fromJson(Map<String, dynamic> json) =>
      _$RefundRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefundRequestToJson(this);
}

@JsonSerializable()
class RefundResponse {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final String transactionId;
  final String? reason;
  final DateTime createdAt;

  const RefundResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.transactionId,
    this.reason,
    required this.createdAt,
  });

  factory RefundResponse.fromJson(Map<String, dynamic> json) =>
      _$RefundResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefundResponseToJson(this);
}
