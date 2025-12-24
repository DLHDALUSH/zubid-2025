import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/payment_repository.dart';

class TransactionsState {
  final bool isLoading;
  final String? error;
  final List<TransactionModel> transactions;
  final bool hasMoreData;
  final int currentPage;
  final String? filterType;
  final String? filterStatus;

  const TransactionsState({
    this.isLoading = false,
    this.error,
    this.transactions = const [],
    this.hasMoreData = true,
    this.currentPage = 1,
    this.filterType,
    this.filterStatus,
  });

  TransactionsState copyWith({
    bool? isLoading,
    String? error,
    List<TransactionModel>? transactions,
    bool? hasMoreData,
    int? currentPage,
    String? filterType,
    String? filterStatus,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      transactions: transactions ?? this.transactions,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      filterType: filterType ?? this.filterType,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  bool get hasError => error != null;
  bool get hasTransactions => transactions.isNotEmpty;
}

class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final PaymentRepository _repository;

  TransactionsNotifier(this._repository) : super(const TransactionsState());

  Future<void> loadTransactions({
    bool refresh = false,
    String? type,
    String? status,
  }) async {
    if (refresh) {
      state = TransactionsState(
        isLoading: true,
        filterType: type,
        filterStatus: status,
      );
    } else if (state.isLoading) {
      return; // Already loading
    } else {
      state = state.copyWith(
        isLoading: true,
        error: null,
        filterType: type,
        filterStatus: status,
      );
    }

    final result = await _repository.getTransactions(
      page: refresh ? 1 : state.currentPage,
      limit: 20,
      type: type ?? state.filterType,
      status: status ?? state.filterStatus,
    );

    result.when(
      success: (transactions) {
        if (refresh) {
          state = TransactionsState(
            isLoading: false,
            transactions: transactions,
            hasMoreData: transactions.length >= 20,
            currentPage: 1,
            filterType: type ?? state.filterType,
            filterStatus: status ?? state.filterStatus,
          );
        } else {
          final allTransactions = [...state.transactions, ...transactions];
          state = state.copyWith(
            isLoading: false,
            transactions: allTransactions,
            hasMoreData: transactions.length >= 20,
            currentPage: state.currentPage + 1,
          );
        }
        AppLogger.info('Loaded ${transactions.length} transactions');
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to load transactions: $error');
      },
    );
  }

  Future<void> refreshTransactions() async {
    await loadTransactions(
      refresh: true,
      type: state.filterType,
      status: state.filterStatus,
    );
  }

  Future<void> loadMoreTransactions() async {
    if (!state.hasMoreData || state.isLoading) return;
    await loadTransactions();
  }

  Future<TransactionModel?> getTransaction(String transactionId) async {
    // First check if we already have it in state
    final existingTransaction = state.transactions
        .where((t) => t.id == transactionId)
        .firstOrNull;
    
    if (existingTransaction != null) {
      return existingTransaction;
    }

    // Fetch from API
    final result = await _repository.getTransaction(transactionId);
    
    return result.when(
      success: (transaction) {
        // Add to state if not already present
        final updatedTransactions = [...state.transactions, transaction];
        state = state.copyWith(transactions: updatedTransactions);
        
        AppLogger.info('Retrieved transaction: $transactionId');
        return transaction;
      },
      error: (error) {
        AppLogger.error('Failed to get transaction: $error');
        return null;
      },
    );
  }

  void setFilter({String? type, String? status}) {
    if (type != state.filterType || status != state.filterStatus) {
      loadTransactions(refresh: true, type: type, status: status);
    }
  }

  void clearFilter() {
    if (state.filterType != null || state.filterStatus != null) {
      loadTransactions(refresh: true);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateTransaction(TransactionModel updatedTransaction) {
    final updatedTransactions = state.transactions.map((transaction) {
      return transaction.id == updatedTransaction.id 
          ? updatedTransaction 
          : transaction;
    }).toList();
    
    state = state.copyWith(transactions: updatedTransactions);
    AppLogger.info('Updated transaction in state: ${updatedTransaction.id}');
  }

  void addTransaction(TransactionModel transaction) {
    final updatedTransactions = [transaction, ...state.transactions];
    state = state.copyWith(transactions: updatedTransactions);
    AppLogger.info('Added transaction to state: ${transaction.id}');
  }
}

// Providers
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  final repository = ref.read(paymentRepositoryProvider);
  return TransactionsNotifier(repository);
});

// Filtered providers
final paymentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider).transactions;
  return transactions.where((t) => t.isPayment).toList();
});

final refundTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider).transactions;
  return transactions.where((t) => t.isRefund).toList();
});

final completedTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider).transactions;
  return transactions.where((t) => t.isCompleted).toList();
});

final pendingTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider).transactions;
  return transactions.where((t) => t.isPending).toList();
});

final failedTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider).transactions;
  return transactions.where((t) => t.isFailed).toList();
});
