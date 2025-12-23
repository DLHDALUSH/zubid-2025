import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 8)
@JsonSerializable()
class TransactionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'payment', 'refund', 'payout', 'fee'

  @HiveField(2)
  final String status; // 'pending', 'completed', 'failed', 'cancelled'

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String? referenceId; // Order ID, Auction ID, etc.

  @HiveField(7)
  final String? referenceType; // 'order', 'auction', 'bid', etc.

  @HiveField(8)
  final String? paymentMethodId;

  @HiveField(9)
  final String? paymentMethodType;

  @HiveField(10)
  final String? paymentMethodLast4;

  @HiveField(11)
  final String? stripePaymentIntentId;

  @HiveField(12)
  final String? razorpayPaymentId;

  @HiveField(13)
  final String? paypalTransactionId;

  @HiveField(14)
  final double? feeAmount;

  @HiveField(15)
  final double? netAmount;

  @HiveField(16)
  final String? failureReason;

  @HiveField(17)
  final Map<String, dynamic>? metadata;

  @HiveField(18)
  final DateTime createdAt;

  @HiveField(19)
  final DateTime? updatedAt;

  @HiveField(20)
  final DateTime? completedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.description,
    this.referenceId,
    this.referenceType,
    this.paymentMethodId,
    this.paymentMethodType,
    this.paymentMethodLast4,
    this.stripePaymentIntentId,
    this.razorpayPaymentId,
    this.paypalTransactionId,
    this.feeAmount,
    this.netAmount,
    this.failureReason,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  // Computed properties
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String get formattedNetAmount {
    if (netAmount == null) return formattedAmount;
    return '\$${netAmount!.toStringAsFixed(2)}';
  }

  String get formattedFeeAmount {
    if (feeAmount == null) return '\$0.00';
    return '\$${feeAmount!.toStringAsFixed(2)}';
  }

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status.toUpperCase();
    }
  }

  String get typeDisplayText {
    switch (type.toLowerCase()) {
      case 'payment':
        return 'Payment';
      case 'refund':
        return 'Refund';
      case 'payout':
        return 'Payout';
      case 'fee':
        return 'Fee';
      default:
        return type.toUpperCase();
    }
  }

  String get paymentMethodDisplay {
    if (paymentMethodType == null) return 'Unknown';
    
    switch (paymentMethodType!.toLowerCase()) {
      case 'card':
        return 'Card •••• ${paymentMethodLast4 ?? '****'}';
      case 'paypal':
        return 'PayPal';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'wallet':
        return 'Digital Wallet';
      default:
        return paymentMethodType!;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isRefunded => status.toLowerCase() == 'refunded';

  bool get isPayment => type.toLowerCase() == 'payment';
  bool get isRefund => type.toLowerCase() == 'refund';
  bool get isPayout => type.toLowerCase() == 'payout';
  bool get isFee => type.toLowerCase() == 'fee';

  String get transactionIcon {
    if (isPayment) return '💳';
    if (isRefund) return '↩️';
    if (isPayout) return '💰';
    if (isFee) return '📊';
    return '💸';
  }

  TransactionModel copyWith({
    String? id,
    String? type,
    String? status,
    double? amount,
    String? currency,
    String? description,
    String? referenceId,
    String? referenceType,
    String? paymentMethodId,
    String? paymentMethodType,
    String? paymentMethodLast4,
    String? stripePaymentIntentId,
    String? razorpayPaymentId,
    String? paypalTransactionId,
    double? feeAmount,
    double? netAmount,
    String? failureReason,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      paymentMethodLast4: paymentMethodLast4 ?? this.paymentMethodLast4,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      paypalTransactionId: paypalTransactionId ?? this.paypalTransactionId,
      feeAmount: feeAmount ?? this.feeAmount,
      netAmount: netAmount ?? this.netAmount,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TransactionModel(id: $id, type: $type, amount: $formattedAmount, status: $status)';
}
