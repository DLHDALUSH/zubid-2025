import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/add_payment_method_request.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentMethodsState {
  final bool isLoading;
  final String? error;
  final List<PaymentMethodModel> paymentMethods;
  final PaymentMethodModel? defaultPaymentMethod;

  const PaymentMethodsState({
    this.isLoading = false,
    this.error,
    this.paymentMethods = const [],
    this.defaultPaymentMethod,
  });

  PaymentMethodsState copyWith({
    bool? isLoading,
    String? error,
    List<PaymentMethodModel>? paymentMethods,
    PaymentMethodModel? defaultPaymentMethod,
  }) {
    return PaymentMethodsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
    );
  }

  bool get hasError => error != null;
  bool get hasPaymentMethods => paymentMethods.isNotEmpty;
}

class PaymentMethodsNotifier extends StateNotifier<PaymentMethodsState> {
  final PaymentRepository _repository;

  PaymentMethodsNotifier(this._repository) : super(const PaymentMethodsState());

  Future<void> loadPaymentMethods() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getPaymentMethods();

    result.when(
      success: (paymentMethods) {
        final defaultMethod = paymentMethods
            .where((method) => method.isDefault)
            .firstOrNull;

        state = PaymentMethodsState(
          isLoading: false,
          paymentMethods: paymentMethods,
          defaultPaymentMethod: defaultMethod,
        );
        AppLogger.info('Loaded ${paymentMethods.length} payment methods');
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to load payment methods: $error');
      },
    );
  }

  Future<bool> addPaymentMethod(AddPaymentMethodRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.addPaymentMethod(request);

    return result.when(
      success: (paymentMethod) {
        final updatedMethods = [...state.paymentMethods, paymentMethod];
        final defaultMethod = paymentMethod.isDefault 
            ? paymentMethod 
            : state.defaultPaymentMethod;

        state = state.copyWith(
          isLoading: false,
          paymentMethods: updatedMethods,
          defaultPaymentMethod: defaultMethod,
        );
        
        AppLogger.info('Added payment method: ${paymentMethod.id}');
        return true;
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to add payment method: $error');
        return false;
      },
    );
  }

  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.deletePaymentMethod(paymentMethodId);

    return result.when(
      success: (_) {
        final updatedMethods = state.paymentMethods
            .where((method) => method.id != paymentMethodId)
            .toList();
        
        final defaultMethod = state.defaultPaymentMethod?.id == paymentMethodId
            ? null
            : state.defaultPaymentMethod;

        state = state.copyWith(
          isLoading: false,
          paymentMethods: updatedMethods,
          defaultPaymentMethod: defaultMethod,
        );
        
        AppLogger.info('Deleted payment method: $paymentMethodId');
        return true;
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to delete payment method: $error');
        return false;
      },
    );
  }

  Future<bool> setDefaultPaymentMethod(String paymentMethodId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.setDefaultPaymentMethod(paymentMethodId);

    return result.when(
      success: (updatedMethod) {
        final updatedMethods = state.paymentMethods.map((method) {
          if (method.id == paymentMethodId) {
            return updatedMethod;
          } else if (method.isDefault) {
            return method.copyWith(isDefault: false);
          }
          return method;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          paymentMethods: updatedMethods,
          defaultPaymentMethod: updatedMethod,
        );
        
        AppLogger.info('Set default payment method: $paymentMethodId');
        return true;
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to set default payment method: $error');
        return false;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  PaymentMethodModel? getPaymentMethodById(String id) {
    return state.paymentMethods
        .where((method) => method.id == id)
        .firstOrNull;
  }

  List<PaymentMethodModel> getPaymentMethodsByType(String type) {
    return state.paymentMethods
        .where((method) => method.type == type)
        .toList();
  }

  List<PaymentMethodModel> getVerifiedPaymentMethods() {
    return state.paymentMethods
        .where((method) => method.isVerified && !method.isExpired)
        .toList();
  }
}

// Providers
final paymentMethodsProvider = StateNotifierProvider<PaymentMethodsNotifier, PaymentMethodsState>((ref) {
  final repository = ref.read(paymentRepositoryProvider);
  return PaymentMethodsNotifier(repository);
});

// Computed providers
final defaultPaymentMethodProvider = Provider<PaymentMethodModel?>((ref) {
  return ref.watch(paymentMethodsProvider).defaultPaymentMethod;
});

final verifiedPaymentMethodsProvider = Provider<List<PaymentMethodModel>>((ref) {
  final state = ref.watch(paymentMethodsProvider);
  return state.paymentMethods
      .where((method) => method.isVerified && !method.isExpired)
      .toList();
});

final cardPaymentMethodsProvider = Provider<List<PaymentMethodModel>>((ref) {
  final state = ref.watch(paymentMethodsProvider);
  return state.paymentMethods
      .where((method) => method.type == 'card')
      .toList();
});

final paypalPaymentMethodsProvider = Provider<List<PaymentMethodModel>>((ref) {
  final state = ref.watch(paymentMethodsProvider);
  return state.paymentMethods
      .where((method) => method.type == 'paypal')
      .toList();
});
