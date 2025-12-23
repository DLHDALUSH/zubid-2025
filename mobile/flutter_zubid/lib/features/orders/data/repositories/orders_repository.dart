import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/order_model.dart';
import '../models/purchase_request_model.dart';

class OrdersRepository {
  final ApiClient _apiClient = ApiClient();

  // Purchase an auction item (Buy Now)
  Future<PurchaseResponse> purchaseAuction(PurchaseRequest request) async {
    try {
      AppLogger.info('Processing purchase for auction: ${request.auctionId}');
      
      final result = await _apiClient.post(
        '/auctions/${request.auctionId}/purchase',
        data: request.toJson(),
      );
      
      return result.when(
        success: (data) {
          final response = PurchaseResponse.fromJson(data);
          AppLogger.info('Purchase initiated successfully: ${response.message}');
          return response;
        },
        failure: (error) {
          AppLogger.error('Failed to process purchase for auction ${request.auctionId}', error);
          throw Exception(error.message);
        },
      );
    } catch (e) {
      AppLogger.error('Error processing purchase for auction ${request.auctionId}', e);
      rethrow;
    }
  }

  // Confirm payment for an order
  Future<PaymentConfirmationResponse> confirmPayment(PaymentConfirmationRequest request) async {
    try {
      AppLogger.info('Confirming payment for order: ${request.orderId}');
      
      final result = await _apiClient.post(
        '/orders/${request.orderId}/confirm-payment',
        data: request.toJson(),
      );
      
      return result.when(
        success: (data) {
          final response = PaymentConfirmationResponse.fromJson(data);
          AppLogger.info('Payment confirmation processed: ${response.message}');
          return response;
        },
        failure: (error) {
          AppLogger.error('Failed to confirm payment for order ${request.orderId}', error);
          throw Exception(error.message);
        },
      );
    } catch (e) {
      AppLogger.error('Error confirming payment for order ${request.orderId}', e);
      rethrow;
    }
  }

  // Get user orders
  Future<List<OrderModel>> getUserOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      AppLogger.info('Fetching user orders: page=$page, limit=$limit, status=$status');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };
      
      final result = await _apiClient.get('/user/orders', queryParameters: queryParams);
      
      return result.when(
        success: (data) {
          final List<dynamic> ordersJson = data['orders'] ?? [];
          final orders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
          
          AppLogger.info('Successfully fetched ${orders.length} user orders');
          return orders;
        },
        failure: (error) {
          AppLogger.error('Failed to fetch user orders', error);
          throw Exception('Failed to load your orders: ${error.message}');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching user orders', e);
      rethrow;
    }
  }

  // Get order details
  Future<OrderModel> getOrder(int orderId) async {
    try {
      AppLogger.info('Fetching order details: $orderId');
      
      final result = await _apiClient.get('/orders/$orderId');
      
      return result.when(
        success: (data) {
          final order = OrderModel.fromJson(data['order']);
          AppLogger.info('Successfully fetched order: ${order.orderNumber}');
          return order;
        },
        failure: (error) {
          AppLogger.error('Failed to fetch order $orderId', error);
          throw Exception('Failed to load order details: ${error.message}');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching order $orderId', e);
      rethrow;
    }
  }

  // Cancel an order
  Future<void> cancelOrder(OrderCancellationRequest request) async {
    try {
      AppLogger.info('Cancelling order: ${request.orderId}');
      
      final result = await _apiClient.post(
        '/orders/${request.orderId}/cancel',
        data: request.toJson(),
      );
      
      result.when(
        success: (data) {
          AppLogger.info('Successfully cancelled order: ${request.orderId}');
        },
        failure: (error) {
          AppLogger.error('Failed to cancel order ${request.orderId}', error);
          throw Exception(error.message);
        },
      );
    } catch (e) {
      AppLogger.error('Error cancelling order ${request.orderId}', e);
      rethrow;
    }
  }

  // Get order tracking information
  Future<OrderTrackingResponse> getOrderTracking(int orderId) async {
    try {
      AppLogger.info('Fetching tracking info for order: $orderId');
      
      final result = await _apiClient.get('/orders/$orderId/tracking');
      
      return result.when(
        success: (data) {
          final tracking = OrderTrackingResponse.fromJson(data);
          AppLogger.info('Successfully fetched tracking info for order: $orderId');
          return tracking;
        },
        failure: (error) {
          AppLogger.error('Failed to fetch tracking info for order $orderId', error);
          throw Exception('Failed to load tracking information: ${error.message}');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching tracking info for order $orderId', e);
      rethrow;
    }
  }

  // Get purchase summary for an auction
  Future<PurchaseSummary> getPurchaseSummary(int auctionId, ShippingAddress shippingAddress) async {
    try {
      AppLogger.info('Fetching purchase summary for auction: $auctionId');
      
      final result = await _apiClient.post(
        '/auctions/$auctionId/purchase-summary',
        data: {
          'shipping_address': shippingAddress.toJson(),
        },
      );
      
      return result.when(
        success: (data) {
          final summary = PurchaseSummary.fromJson(data);
          AppLogger.info('Successfully fetched purchase summary for auction: $auctionId');
          return summary;
        },
        failure: (error) {
          AppLogger.error('Failed to fetch purchase summary for auction $auctionId', error);
          throw Exception('Failed to calculate purchase total: ${error.message}');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching purchase summary for auction $auctionId', e);
      rethrow;
    }
  }
}

// Purchase Summary Model
class PurchaseSummary {
  final double itemPrice;
  final double shippingCost;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final Map<String, dynamic> taxBreakdown;

  const PurchaseSummary({
    required this.itemPrice,
    required this.shippingCost,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    this.taxBreakdown = const {},
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseSummary(
      itemPrice: (json['item_price'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      taxBreakdown: json['tax_breakdown'] as Map<String, dynamic>? ?? {},
    );
  }

  String get formattedItemPrice => '\$${itemPrice.toStringAsFixed(2)}';
  String get formattedShippingCost => '\$${shippingCost.toStringAsFixed(2)}';
  String get formattedTaxAmount => '\$${taxAmount.toStringAsFixed(2)}';
  String get formattedTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';
}
