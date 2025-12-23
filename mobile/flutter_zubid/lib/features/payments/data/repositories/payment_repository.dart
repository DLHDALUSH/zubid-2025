import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/payment_method_model.dart';
import '../models/payment_request_model.dart';
import '../models/add_payment_method_request.dart';
import '../models/transaction_model.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  // Payment Methods
  Future<ApiResult<List<PaymentMethodModel>>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get('/payment-methods');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final paymentMethods = data
            .map((json) => PaymentMethodModel.fromJson(json))
            .toList();
        
        AppLogger.info('Retrieved ${paymentMethods.length} payment methods');
        return ApiResult.success(paymentMethods);
      } else {
        return ApiResult.failure('Failed to load payment methods');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to get payment methods: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error getting payment methods: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  Future<ApiResult<PaymentMethodModel>> addPaymentMethod(
    AddPaymentMethodRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/payment-methods',
        data: request.toJson(),
      );
      
      if (response.statusCode == 201) {
        final paymentMethod = PaymentMethodModel.fromJson(response.data['data']);
        AppLogger.info('Added payment method: ${paymentMethod.id}');
        return ApiResult.success(paymentMethod);
      } else {
        return ApiResult.failure('Failed to add payment method');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to add payment method: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error adding payment method: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  Future<ApiResult<bool>> deletePaymentMethod(String paymentMethodId) async {
    try {
      final response = await _apiClient.delete('/payment-methods/$paymentMethodId');
      
      if (response.statusCode == 200) {
        AppLogger.info('Deleted payment method: $paymentMethodId');
        return ApiResult.success(true);
      } else {
        return ApiResult.failure('Failed to delete payment method');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to delete payment method: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error deleting payment method: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  Future<ApiResult<PaymentMethodModel>> setDefaultPaymentMethod(
    String paymentMethodId,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/payment-methods/$paymentMethodId/default',
      );
      
      if (response.statusCode == 200) {
        final paymentMethod = PaymentMethodModel.fromJson(response.data['data']);
        AppLogger.info('Set default payment method: $paymentMethodId');
        return ApiResult.success(paymentMethod);
      } else {
        return ApiResult.failure('Failed to set default payment method');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to set default payment method: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error setting default payment method: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  // Payments
  Future<ApiResult<PaymentResponse>> processPayment(
    PaymentRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/payments/process',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final paymentResponse = PaymentResponse.fromJson(response.data['data']);
        AppLogger.info('Payment processed: ${paymentResponse.id}');
        return ApiResult.success(paymentResponse);
      } else {
        return ApiResult.failure('Payment processing failed');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to process payment: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error processing payment: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  Future<ApiResult<PaymentResponse>> confirmPayment(
    String paymentIntentId,
    String? paymentMethodId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/payments/confirm',
        data: {
          'payment_intent_id': paymentIntentId,
          if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
        },
      );
      
      if (response.statusCode == 200) {
        final paymentResponse = PaymentResponse.fromJson(response.data['data']);
        AppLogger.info('Payment confirmed: ${paymentResponse.id}');
        return ApiResult.success(paymentResponse);
      } else {
        return ApiResult.failure('Payment confirmation failed');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to confirm payment: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error confirming payment: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  // Transactions
  Future<ApiResult<List<TransactionModel>>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
        if (status != null) 'status': status,
      };

      final response = await _apiClient.get(
        '/transactions',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final transactions = data
            .map((json) => TransactionModel.fromJson(json))
            .toList();
        
        AppLogger.info('Retrieved ${transactions.length} transactions');
        return ApiResult.success(transactions);
      } else {
        return ApiResult.failure('Failed to load transactions');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to get transactions: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error getting transactions: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  Future<ApiResult<TransactionModel>> getTransaction(String transactionId) async {
    try {
      final response = await _apiClient.get('/transactions/$transactionId');
      
      if (response.statusCode == 200) {
        final transaction = TransactionModel.fromJson(response.data['data']);
        AppLogger.info('Retrieved transaction: $transactionId');
        return ApiResult.success(transaction);
      } else {
        return ApiResult.failure('Failed to load transaction');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to get transaction: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error getting transaction: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  // Refunds
  Future<ApiResult<RefundResponse>> processRefund(
    RefundRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/payments/refund',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final refundResponse = RefundResponse.fromJson(response.data['data']);
        AppLogger.info('Refund processed: ${refundResponse.id}');
        return ApiResult.success(refundResponse);
      } else {
        return ApiResult.failure('Refund processing failed');
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to process refund: ${e.message}');
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected error processing refund: $e');
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown error';
        
        switch (statusCode) {
          case 400:
            return 'Invalid payment information: $message';
          case 401:
            return 'Authentication required. Please log in again.';
          case 402:
            return 'Payment required: $message';
          case 403:
            return 'Payment not authorized: $message';
          case 404:
            return 'Payment method or transaction not found';
          case 409:
            return 'Payment conflict: $message';
          case 422:
            return 'Payment validation failed: $message';
          case 429:
            return 'Too many payment requests. Please try again later.';
          case 500:
            return 'Payment server error. Please try again later.';
          default:
            return 'Payment failed: $message';
        }
      case DioExceptionType.cancel:
        return 'Payment request was cancelled';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred during payment processing';
    }
  }
}

// Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PaymentRepository(apiClient);
});
