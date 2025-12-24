import '../../../../core/network/api_client.dart';
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

      final response = PurchaseResponse.fromJson(result.data);
      AppLogger.info('Purchase initiated successfully: ${response.message}');
      return response;
    } catch (e) {
      AppLogger.error('Error processing purchase for auction ${request.auctionId}', error: e);
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

      final response = PaymentConfirmationResponse.fromJson(result.data);
      AppLogger.info('Payment confirmation processed: ${response.message}');
      return response;
    } catch (e) {
      AppLogger.error('Error confirming payment for order ${request.orderId}', error: e);
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

      final List<dynamic> ordersJson = result.data['orders'] ?? [];
      final orders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();

      AppLogger.info('Successfully fetched ${orders.length} user orders');
      return orders;
    } catch (e) {
      AppLogger.error('Error fetching user orders', error: e);
      rethrow;
    }
  }

  // Get order details
  Future<OrderModel> getOrder(int orderId) async {
    try {
      AppLogger.info('Fetching order details: $orderId');
      
      final result = await _apiClient.get('/orders/$orderId');

      final order = OrderModel.fromJson(result.data['order']);
      AppLogger.info('Successfully fetched order: ${order.orderNumber}');
      return order;
    } catch (e) {
      AppLogger.error('Error fetching order $orderId', error: e);
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
      
      AppLogger.info('Successfully cancelled order: ${request.orderId}');
    } catch (e) {
      AppLogger.error('Error cancelling order ${request.orderId}', error: e);
      rethrow;
    }
  }

  // Get order tracking information
  Future<OrderTrackingResponse> getOrderTracking(int orderId) async {
    try {
      AppLogger.info('Fetching tracking info for order: $orderId');
      
      final result = await _apiClient.get('/orders/$orderId/tracking');
      
      final tracking = OrderTrackingResponse.fromJson(result.data);
      AppLogger.info('Successfully fetched tracking info for order: $orderId');
      return tracking;
    } catch (e) {
      AppLogger.error('Error fetching tracking info for order $orderId', error: e);
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
      
      final summary = PurchaseSummary.fromJson(result.data);
      AppLogger.info('Successfully fetched purchase summary for auction: $auctionId');
      return summary;
    } catch (e) {
      AppLogger.error('Error fetching purchase summary for auction $auctionId', error: e);
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
