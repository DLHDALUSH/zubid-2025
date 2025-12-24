import 'package:json_annotation/json_annotation.dart';

part 'add_payment_method_request.g.dart';

@JsonSerializable()
class AddPaymentMethodRequest {
  final String type; // 'card', 'fib', 'zain_cash'
  final String? cardNumber;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cvv;
  final String? cardHolderName;
  final String? fibAccountNumber;
  final String? zainCashNumber;
  final bool isDefault;

  const AddPaymentMethodRequest({
    required this.type,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.cvv,
    this.cardHolderName,
    this.fibAccountNumber,
    this.zainCashNumber,
    this.isDefault = false,
  });

  factory AddPaymentMethodRequest.fromJson(Map<String, dynamic> json) =>
      _$AddPaymentMethodRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddPaymentMethodRequestToJson(this);

  // Factory constructors for different payment types
  factory AddPaymentMethodRequest.card({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
    bool isDefault = false,
  }) {
    return AddPaymentMethodRequest(
      type: 'card',
      cardNumber: cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvv: cvv,
      cardHolderName: cardHolderName,
      isDefault: isDefault,
    );
  }

  factory AddPaymentMethodRequest.fib({
    required String fibAccountNumber,
    String? fibHolderName,
    String? fibPhoneNumber,
    String? fibBranch,
    String? fibIban,
    bool isDefault = false,
  }) {
    return AddPaymentMethodRequest(
      type: 'fib',
      fibAccountNumber: fibAccountNumber,
      cardHolderName: fibHolderName,
      isDefault: isDefault,
    );
  }

  factory AddPaymentMethodRequest.zainCash({
    required String zainPhoneNumber,
    String? zainPin,
    String? zainHolderName,
    bool isDefault = false,
  }) {
    return AddPaymentMethodRequest(
      type: 'zain_cash',
      zainCashNumber: zainPhoneNumber,
      isDefault: isDefault,
    );
  }

  factory AddPaymentMethodRequest.visa({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
    bool isDefault = false,
  }) {
    return AddPaymentMethodRequest(
      type: 'visa',
      cardNumber: cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvv: cvv,
      cardHolderName: cardHolderName,
      isDefault: isDefault,
    );
  }

  factory AddPaymentMethodRequest.mastercard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
    bool isDefault = false,
  }) {
    return AddPaymentMethodRequest(
      type: 'mastercard',
      cardNumber: cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvv: cvv,
      cardHolderName: cardHolderName,
      isDefault: isDefault,
    );
  }

  @override
  String toString() {
    return 'AddPaymentMethodRequest(type: $type, isDefault: $isDefault)';
  }
}
