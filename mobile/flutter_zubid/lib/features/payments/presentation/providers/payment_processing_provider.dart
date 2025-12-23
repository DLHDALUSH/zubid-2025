import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/payment_request_model.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentProcessingState {
  final bool isProcessing;
  final String? error;
  final PaymentResponse? currentPayment;
  final String? currentStep; // 'initiating', 'processing', 'confirming', 'completed'

  const PaymentProcessingState({
    this.isProcessing = false,
    this.error,
    this.currentPayment,
    this.currentStep,
  });

  PaymentProcessingState copyWith({
    bool? isProcessing,
    String? error,
    PaymentResponse? currentPayment,
    String? currentStep,
  }) {
    return PaymentProcessingState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      currentPayment: currentPayment ?? this.currentPayment,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  bool get hasError => error != null;
  bool get hasCurrentPayment => currentPayment != null;
  bool get requiresAction => currentPayment?.requiresAction == true;
  bool get isCompleted => currentPayment?.isSucceeded == true;
  bool get isFailed => currentPayment?.isFailed == true;
}

class PaymentProcessingNotifier extends StateNotifier<PaymentProcessingState> {
  final PaymentRepository _repository;

  PaymentProcessingNotifier(this._repository) : super(const PaymentProcessingState());

  Future<bool> processPayment(PaymentRequest request) async {
    state = PaymentProcessingState(
      isProcessing: true,
      currentStep: 'initiating',
    );

    AppLogger.info('Starting payment processing for amount: ${request.amount}');

    final result = await _repository.processPayment(request);

    return result.when(
      success: (paymentResponse) {
        state = PaymentProcessingState(
          isProcessing: false,
          currentPayment: paymentResponse,
          currentStep: paymentResponse.requiresAction ? 'confirming' : 'completed',
        );

        AppLogger.info('Payment processed: ${paymentResponse.id}, status: ${paymentResponse.status}');
        return true;
      },
      failure: (error) {
        state = PaymentProcessingState(
          isProcessing: false,
          error: error,
          currentStep: 'failed',
        );
        AppLogger.error('Payment processing failed: $error');
        return false;
      },
    );
  }

  Future<bool> confirmPayment(String paymentIntentId, [String? paymentMethodId]) async {
    state = state.copyWith(
      isProcessing: true,
      currentStep: 'confirming',
      error: null,
    );

    AppLogger.info('Confirming payment: $paymentIntentId');

    final result = await _repository.confirmPayment(paymentIntentId, paymentMethodId);

    return result.when(
      success: (paymentResponse) {
        state = state.copyWith(
          isProcessing: false,
          currentPayment: paymentResponse,
          currentStep: paymentResponse.isSucceeded ? 'completed' : 'failed',
        );

        AppLogger.info('Payment confirmed: ${paymentResponse.id}, status: ${paymentResponse.status}');
        return paymentResponse.isSucceeded;
      },
      failure: (error) {
        state = state.copyWith(
          isProcessing: false,
          error: error,
          currentStep: 'failed',
        );
        AppLogger.error('Payment confirmation failed: $error');
        return false;
      },
    );
  }

  Future<bool> processRefund(RefundRequest request) async {
    state = state.copyWith(
      isProcessing: true,
      currentStep: 'processing',
      error: null,
    );

    AppLogger.info('Processing refund for transaction: ${request.transactionId}');

    final result = await _repository.processRefund(request);

    return result.when(
      success: (refundResponse) {
        state = state.copyWith(
          isProcessing: false,
          currentStep: 'completed',
        );

        AppLogger.info('Refund processed: ${refundResponse.id}');
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          isProcessing: false,
          error: error,
          currentStep: 'failed',
        );
        AppLogger.error('Refund processing failed: $error');
        return false;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentPayment() {
    state = const PaymentProcessingState();
  }

  void setProcessingStep(String step) {
    state = state.copyWith(currentStep: step);
  }

  // Helper methods for common payment scenarios
  Future<bool> processBidPayment({
    required double amount,
    required String paymentMethodId,
    required String auctionId,
    required String bidId,
  }) async {
    final request = PaymentRequest(
      amount: amount,
      currency: 'USD',
      paymentMethodId: paymentMethodId,
      description: 'Bid payment for auction',
      referenceId: bidId,
      referenceType: 'bid',
      metadata: {
        'auction_id': auctionId,
        'bid_id': bidId,
      },
    );

    return await processPayment(request);
  }

  Future<bool> processPurchasePayment({
    required double amount,
    required String paymentMethodId,
    required String auctionId,
    required String orderId,
  }) async {
    final request = PaymentRequest(
      amount: amount,
      currency: 'USD',
      paymentMethodId: paymentMethodId,
      description: 'Purchase payment for auction',
      referenceId: orderId,
      referenceType: 'order',
      metadata: {
        'auction_id': auctionId,
        'order_id': orderId,
      },
    );

    return await processPayment(request);
  }

  Future<bool> processShippingPayment({
    required double amount,
    required String paymentMethodId,
    required String orderId,
  }) async {
    final request = PaymentRequest(
      amount: amount,
      currency: 'USD',
      paymentMethodId: paymentMethodId,
      description: 'Shipping payment',
      referenceId: orderId,
      referenceType: 'shipping',
      metadata: {
        'order_id': orderId,
      },
    );

    return await processPayment(request);
  }

  Future<bool> processSellerPayout({
    required double amount,
    required String paymentMethodId,
    required String auctionId,
    required String saleId,
  }) async {
    final request = PaymentRequest(
      amount: amount,
      currency: 'USD',
      paymentMethodId: paymentMethodId,
      description: 'Seller payout',
      referenceId: saleId,
      referenceType: 'payout',
      metadata: {
        'auction_id': auctionId,
        'sale_id': saleId,
      },
    );

    return await processPayment(request);
  }
}

// Providers
final paymentProcessingProvider = StateNotifierProvider<PaymentProcessingNotifier, PaymentProcessingState>((ref) {
  final repository = ref.read(paymentRepositoryProvider);
  return PaymentProcessingNotifier(repository);
});

// Computed providers
final isPaymentProcessingProvider = Provider<bool>((ref) {
  return ref.watch(paymentProcessingProvider).isProcessing;
});

final currentPaymentProvider = Provider<PaymentResponse?>((ref) {
  return ref.watch(paymentProcessingProvider).currentPayment;
});

final paymentRequiresActionProvider = Provider<bool>((ref) {
  return ref.watch(paymentProcessingProvider).requiresAction;
});

final paymentCompletedProvider = Provider<bool>((ref) {
  return ref.watch(paymentProcessingProvider).isCompleted;
});

final paymentFailedProvider = Provider<bool>((ref) {
  return ref.watch(paymentProcessingProvider).isFailed;
});
