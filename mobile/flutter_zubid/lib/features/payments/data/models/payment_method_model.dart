import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_method_model.g.dart';

@HiveType(typeId: 7)
@JsonSerializable()
class PaymentMethodModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'card', 'paypal', 'bank_transfer', 'wallet'

  @HiveField(2)
  final String? cardLast4;

  @HiveField(3)
  final String? cardBrand; // 'visa', 'mastercard', 'amex', etc.

  @HiveField(4)
  final String? cardExpMonth;

  @HiveField(5)
  final String? cardExpYear;

  @HiveField(6)
  final String? email; // For PayPal

  @HiveField(7)
  final String? bankName; // For bank transfers

  @HiveField(8)
  final String? accountLast4; // For bank accounts

  @HiveField(9)
  final bool isDefault;

  @HiveField(10)
  final bool isVerified;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    this.cardLast4,
    this.cardBrand,
    this.cardExpMonth,
    this.cardExpYear,
    this.email,
    this.bankName,
    this.accountLast4,
    this.isDefault = false,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);

  // Computed properties
  String get displayName {
    switch (type) {
      case 'fib':
        return 'FIB •••• ${accountLast4 ?? '****'}';
      case 'zain_cash':
        return 'ZAIN CASH ${email ?? ''}';
      case 'visa':
        return 'VISA •••• ${cardLast4 ?? '****'}';
      case 'mastercard':
        return 'MASTERCARD •••• ${cardLast4 ?? '****'}';
      case 'card':
        return '${cardBrand?.toUpperCase() ?? 'Card'} •••• ${cardLast4 ?? '****'}';
      case 'paypal':
        return 'PayPal ${email ?? ''}';
      case 'bank_transfer':
        return '${bankName ?? 'Bank'} •••• ${accountLast4 ?? '****'}';
      case 'wallet':
        return 'Digital Wallet';
      default:
        return 'Payment Method';
    }
  }

  String get displayIcon {
    switch (type) {
      case 'fib':
        return '🏛️'; // Bank building for FIB
      case 'zain_cash':
        return '📱'; // Mobile phone for ZAIN CASH
      case 'visa':
        return '💳'; // Credit card for VISA
      case 'mastercard':
        return '💳'; // Credit card for MASTERCARD
      case 'card':
        switch (cardBrand?.toLowerCase()) {
          case 'visa':
            return '💳';
          case 'mastercard':
            return '💳';
          case 'amex':
            return '💳';
          default:
            return '💳';
        }
      case 'paypal':
        return '🅿️';
      case 'bank_transfer':
        return '🏦';
      case 'wallet':
        return '💰';
      default:
        return '💳';
    }
  }

  bool get isExpired {
    if (cardExpMonth == null || cardExpYear == null) return false;
    
    final now = DateTime.now();
    final expMonth = int.tryParse(cardExpMonth!) ?? 12;
    final expYear = int.tryParse(cardExpYear!) ?? now.year;
    
    final expDate = DateTime(expYear, expMonth + 1, 0); // Last day of exp month
    return now.isAfter(expDate);
  }

  String get statusText {
    if (isExpired) return 'Expired';
    if (!isVerified) return 'Unverified';
    if (isDefault) return 'Default';
    return 'Active';
  }

  PaymentMethodModel copyWith({
    String? id,
    String? type,
    String? cardLast4,
    String? cardBrand,
    String? cardExpMonth,
    String? cardExpYear,
    String? email,
    String? bankName,
    String? accountLast4,
    bool? isDefault,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardBrand: cardBrand ?? this.cardBrand,
      cardExpMonth: cardExpMonth ?? this.cardExpMonth,
      cardExpYear: cardExpYear ?? this.cardExpYear,
      email: email ?? this.email,
      bankName: bankName ?? this.bankName,
      accountLast4: accountLast4 ?? this.accountLast4,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PaymentMethodModel(id: $id, type: $type, displayName: $displayName)';
}
