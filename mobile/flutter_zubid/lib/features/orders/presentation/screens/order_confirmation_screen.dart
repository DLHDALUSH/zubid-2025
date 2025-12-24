import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/widgets/custom_button.dart';
import '../providers/buy_now_provider.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final buyNowState = ref.watch(buyNowProvider);
    final order = buyNowState.order;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        automaticallyImplyLeading: false,
      ),
      body: order == null
          ? _buildErrorState(context, theme)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success Icon and Message
                  _buildSuccessHeader(theme),
                  
                  const SizedBox(height: 32),
                  
                  // Order Details Card
                  _buildOrderDetailsCard(theme, order),
                  
                  const SizedBox(height: 24),
                  
                  // Item Details Card
                  _buildItemDetailsCard(theme, order),
                  
                  const SizedBox(height: 24),
                  
                  // Shipping Information
                  _buildShippingCard(theme, order),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Information
                  _buildPaymentCard(theme, order),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  _buildActionButtons(theme, context),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme) {
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
            'Order Not Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find your order details.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Go to Home',
            onPressed: () => GoRouter.of(context).go('/'),
            icon: Icons.home,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Order Confirmed!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Thank you for your purchase. Your order has been confirmed and will be processed shortly.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(ThemeData theme, order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailRow(theme, 'Order Number', order.orderNumber),
            const SizedBox(height: 8),
            _buildDetailRow(theme, 'Order Date', order.formattedCreatedAt),
            const SizedBox(height: 8),
            _buildDetailRow(theme, 'Status', order.statusDisplayText),
            const SizedBox(height: 8),
            _buildDetailRow(theme, 'Total Amount', order.formattedTotalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetailsCard(ThemeData theme, order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Item Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: order.auctionImage != null
                        ? CachedNetworkImage(
                            imageUrl: order.auctionImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.image,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.image,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.auctionTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seller: ${order.sellerName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.formattedPurchasePrice,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingCard(ThemeData theme, order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Address',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              order.shippingAddress.formattedAddress,
              style: theme.textTheme.bodyLarge,
            ),
            
            if (order.shippingAddress.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                'Phone: ${order.shippingAddress.phoneNumber}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(ThemeData theme, order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailRow(theme, 'Payment Method', order.paymentMethod),
            const SizedBox(height: 8),
            _buildDetailRow(theme, 'Payment Status', order.paymentStatusDisplayText),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your payment is secure and protected by our payment processor.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Track Order',
            onPressed: () {
              // TODO: Navigate to order tracking screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order tracking coming soon!'),
                ),
              );
            },
            icon: Icons.local_shipping_outlined,
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Continue Shopping',
            onPressed: () => context.go('/auctions'),
            variant: ButtonVariant.outlined,
            icon: Icons.shopping_bag_outlined,
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Go to Home',
            onPressed: () => context.go('/'),
            variant: ButtonVariant.text,
            icon: Icons.home_outlined,
          ),
        ),
      ],
    );
  }
}
