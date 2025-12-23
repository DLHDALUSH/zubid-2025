import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../auctions/data/models/auction_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/purchase_request_model.dart';
import '../../data/repositories/orders_repository.dart';

// State class for buy now functionality
class BuyNowState {
  final bool isProcessing;
  final String? error;
  final OrderModel? order;
  final ShippingAddress? shippingAddress;
  final String? paymentMethod;
  final PurchaseSummary? purchaseSummary;
  final bool useShippingAsBilling;

  const BuyNowState({
    this.isProcessing = false,
    this.error,
    this.order,
    this.shippingAddress,
    this.paymentMethod,
    this.purchaseSummary,
    this.useShippingAsBilling = true,
  });

  BuyNowState copyWith({
    bool? isProcessing,
    String? error,
    OrderModel? order,
    ShippingAddress? shippingAddress,
    String? paymentMethod,
    PurchaseSummary? purchaseSummary,
    bool? useShippingAsBilling,
  }) {
    return BuyNowState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      order: order ?? this.order,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      purchaseSummary: purchaseSummary ?? this.purchaseSummary,
      useShippingAsBilling: useShippingAsBilling ?? this.useShippingAsBilling,
    );
  }

  bool get hasError => error != null;
  bool get hasShippingAddress => shippingAddress != null;
  bool get hasPaymentMethod => paymentMethod != null && paymentMethod!.isNotEmpty;
  bool get canPurchase => hasShippingAddress && hasPaymentMethod && !isProcessing;
}

// Notifier for buy now functionality
class BuyNowNotifier extends StateNotifier<BuyNowState> {
  final OrdersRepository _repository;

  BuyNowNotifier(this._repository) : super(const BuyNowState());

  // Set shipping address
  void setShippingAddress(ShippingAddress address) {
    state = state.copyWith(shippingAddress: address, error: null);
    _updatePurchaseSummary();
  }

  // Set payment method
  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method, error: null);
  }

  // Toggle use shipping as billing
  void toggleUseShippingAsBilling(bool value) {
    state = state.copyWith(useShippingAsBilling: value);
  }

  // Update purchase summary
  Future<void> _updatePurchaseSummary() async {
    if (!state.hasShippingAddress) return;

    try {
      // This would typically be called with the auction ID
      // For now, we'll skip the API call and use a placeholder
      AppLogger.info('Updating purchase summary');
    } catch (e) {
      AppLogger.error('Failed to update purchase summary', e);
    }
  }

  // Process purchase
  Future<bool> processPurchase(AuctionModel auction) async {
    if (!state.canPurchase) {
      state = state.copyWith(error: 'Please complete all required fields');
      return false;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      AppLogger.info('Processing purchase for auction: ${auction.id}');

      final request = PurchaseRequest(
        auctionId: auction.id,
        paymentMethod: state.paymentMethod!,
        shippingAddress: state.shippingAddress!,
        useShippingAsBilling: state.useShippingAsBilling,
      );

      final response = await _repository.purchaseAuction(request);

      if (response.success) {
        state = state.copyWith(
          isProcessing: false,
          order: response.order,
        );
        
        AppLogger.info('Purchase completed successfully');
        return true;
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Purchase failed for auction ${auction.id}', e);
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Reset state
  void reset() {
    state = const BuyNowState();
  }

  // Load purchase summary for auction
  Future<void> loadPurchaseSummary(int auctionId) async {
    if (!state.hasShippingAddress) return;

    try {
      AppLogger.info('Loading purchase summary for auction: $auctionId');
      
      final summary = await _repository.getPurchaseSummary(
        auctionId,
        state.shippingAddress!,
      );
      
      state = state.copyWith(purchaseSummary: summary);
      
      AppLogger.info('Purchase summary loaded successfully');
    } catch (e) {
      AppLogger.error('Failed to load purchase summary for auction $auctionId', e);
      // Don't set error state for summary loading failure
    }
  }
}

// Provider for buy now functionality
final buyNowProvider = StateNotifierProvider<BuyNowNotifier, BuyNowState>((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return BuyNowNotifier(repository);
});

// Provider for orders repository
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository();
});

// Convenience providers
final shippingAddressProvider = Provider<ShippingAddress?>((ref) {
  return ref.watch(buyNowProvider).shippingAddress;
});

final paymentMethodProvider = Provider<String?>((ref) {
  return ref.watch(buyNowProvider).paymentMethod;
});

final purchaseSummaryProvider = Provider<PurchaseSummary?>((ref) {
  return ref.watch(buyNowProvider).purchaseSummary;
});

final canPurchaseProvider = Provider<bool>((ref) {
  return ref.watch(buyNowProvider).canPurchase;
});
