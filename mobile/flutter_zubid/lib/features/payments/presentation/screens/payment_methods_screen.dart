import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../data/models/payment_method_model.dart';
import '../providers/payment_methods_provider.dart';
import '../widgets/payment_method_card.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    // Load payment methods when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentMethodsProvider.notifier).loadPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentMethodsState = ref.watch(paymentMethodsProvider);

    return LoadingOverlay(
      isLoading: paymentMethodsState.isLoading && !paymentMethodsState.hasPaymentMethods,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Methods'),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          actions: [
            IconButton(
              onPressed: () => _addPaymentMethod(),
              icon: const Icon(Icons.add),
              tooltip: 'Add Payment Method',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(paymentMethodsProvider.notifier).loadPaymentMethods();
          },
          child: _buildBody(theme, paymentMethodsState),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addPaymentMethod(),
          child: const Icon(Icons.add),
          tooltip: 'Add Payment Method',
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, PaymentMethodsState state) {
    if (state.hasError && !state.hasPaymentMethods) {
      return _buildErrorState(theme, state.error!);
    }

    if (!state.hasPaymentMethods && !state.isLoading) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.paymentMethods.length + (state.hasError ? 1 : 0),
      itemBuilder: (context, index) {
        // Show error banner at top if there's an error
        if (state.hasError && index == 0) {
          return _buildErrorBanner(theme, state.error!);
        }

        final paymentMethodIndex = state.hasError ? index - 1 : index;
        final paymentMethod = state.paymentMethods[paymentMethodIndex];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PaymentMethodCard(
            paymentMethod: paymentMethod,
            onTap: () => _viewPaymentMethodDetails(paymentMethod),
            onSetDefault: paymentMethod.isDefault 
                ? null 
                : () => _setDefaultPaymentMethod(paymentMethod),
            onDelete: () => _deletePaymentMethod(paymentMethod),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Methods',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a payment method to make purchases and place bids.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add Payment Method',
            onPressed: () => _addPaymentMethod(),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
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
            'Error Loading Payment Methods',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Try Again',
            onPressed: () => ref.read(paymentMethodsProvider.notifier).loadPaymentMethods(),
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme, String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(paymentMethodsProvider.notifier).clearError(),
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  void _addPaymentMethod() {
    context.pushNamed('add-payment-method');
  }

  void _viewPaymentMethodDetails(PaymentMethodModel paymentMethod) {
    context.pushNamed(
      'payment-method-details',
      pathParameters: {'id': paymentMethod.id},
    );
  }

  Future<void> _setDefaultPaymentMethod(PaymentMethodModel paymentMethod) async {
    final success = await ref
        .read(paymentMethodsProvider.notifier)
        .setDefaultPaymentMethod(paymentMethod.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${paymentMethod.displayName} set as default'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deletePaymentMethod(PaymentMethodModel paymentMethod) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${paymentMethod.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(paymentMethodsProvider.notifier)
          .deletePaymentMethod(paymentMethod.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
