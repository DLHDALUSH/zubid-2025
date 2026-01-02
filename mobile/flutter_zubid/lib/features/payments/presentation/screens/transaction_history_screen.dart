import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';
import '../widgets/transaction_card.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String? _selectedType;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsProvider.notifier).loadTransactions(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionsProvider.notifier).loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsState = ref.watch(transactionsProvider);

    return LoadingOverlay(
      isLoading: transactionsState.isLoading && transactionsState.transactions.isEmpty,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          actions: [
            IconButton(
              onPressed: () => _showFilterDialog(),
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter Transactions',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Payments'),
              Tab(text: 'Refunds'),
              Tab(text: 'Pending'),
              Tab(text: 'Failed'),
            ],
            onTap: (index) => _onTabChanged(index),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTransactionsList(null, null),
            _buildTransactionsList('payment', null),
            _buildTransactionsList('refund', null),
            _buildTransactionsList(null, 'pending'),
            _buildTransactionsList(null, 'failed'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(String? type, String? status) {
    final transactionsState = ref.watch(transactionsProvider);
    final filteredTransactions = _filterTransactions(
      transactionsState.transactions, 
      type, 
      status,
    );

    if (transactionsState.hasError && transactionsState.transactions.isEmpty) {
      return _buildErrorState(transactionsState.error!);
    }

    if (filteredTransactions.isEmpty && !transactionsState.isLoading) {
      return _buildEmptyState(type, status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(transactionsProvider.notifier).refreshTransactions();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredTransactions.length + (transactionsState.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredTransactions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final transaction = filteredTransactions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TransactionCard(
              transaction: transaction,
              onTap: () => _viewTransactionDetails(transaction),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String? type, String? status) {
    final theme = Theme.of(context);
    
    String title;
    String subtitle;
    IconData icon;
    
    if (type == 'payment') {
      title = 'No Payments';
      subtitle = 'Your payment transactions will appear here.';
      icon = Icons.payment;
    } else if (type == 'refund') {
      title = 'No Refunds';
      subtitle = 'Your refund transactions will appear here.';
      icon = Icons.money_off;
    } else if (status == 'pending') {
      title = 'No Pending Transactions';
      subtitle = 'Your pending transactions will appear here.';
      icon = Icons.pending;
    } else if (status == 'failed') {
      title = 'No Failed Transactions';
      subtitle = 'Your failed transactions will appear here.';
      icon = Icons.error_outline;
    } else {
      title = 'No Transactions';
      subtitle = 'Your transaction history will appear here.';
      icon = Icons.receipt_long;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Transactions',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(transactionsProvider.notifier).refreshTransactions(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
    String? type,
    String? status,
  ) {
    return transactions.where((transaction) {
      if (type != null && transaction.type.toLowerCase() != type.toLowerCase()) {
        return false;
      }
      if (status != null && transaction.status.toLowerCase() != status.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  void _onTabChanged(int index) {
    String? type;
    String? status;
    
    switch (index) {
      case 1: // Payments
        type = 'payment';
        break;
      case 2: // Refunds
        type = 'refund';
        break;
      case 3: // Pending
        status = 'pending';
        break;
      case 4: // Failed
        status = 'failed';
        break;
    }
    
    if (type != _selectedType || status != _selectedStatus) {
      _selectedType = type;
      _selectedStatus = status;
      ref.read(transactionsProvider.notifier).setFilter(
        type: type,
        status: status,
      );
    }
  }

  void _viewTransactionDetails(TransactionModel transaction) {
    context.pushNamed(
      'transaction-details',
      pathParameters: {'id': transaction.id},
    );
  }

  void _showFilterDialog() {
    // TODO: Implement advanced filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced filters coming soon!')),
    );
  }
}
