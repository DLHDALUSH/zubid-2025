import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auctions/data/models/auction_model.dart';
import '../providers/buy_now_provider.dart';

class PurchaseSummaryCard extends ConsumerWidget {
  final AuctionModel auction;

  const PurchaseSummaryCard({
    super.key,
    required this.auction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final purchaseSummary = ref.watch(purchaseSummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Item Price
            _buildSummaryRow(
              theme,
              'Item Price',
              auction.formattedBuyNowPrice,
            ),
            
            const SizedBox(height: 8),
            
            // Shipping Cost
            _buildSummaryRow(
              theme,
              'Shipping',
              purchaseSummary?.formattedShippingCost ?? _calculateShipping(),
            ),
            
            const SizedBox(height: 8),
            
            // Tax
            _buildSummaryRow(
              theme,
              'Tax',
              purchaseSummary?.formattedTaxAmount ?? _calculateTax(),
            ),
            
            const SizedBox(height: 16),
            
            // Divider
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            
            const SizedBox(height: 16),
            
            // Total
            _buildSummaryRow(
              theme,
              'Total',
              purchaseSummary?.formattedTotalAmount ?? _calculateTotal(),
              isTotal: true,
            ),
            
            const SizedBox(height: 16),
            
            // Additional Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Additional Information',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '• Secure payment processing by Stripe\n'
                    '• 30-day return policy\n'
                    '• Buyer protection guarantee\n'
                    '• Tracking information provided',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            if (auction.shipping.hasReturnPolicy) ...[
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_return_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Return Policy: ${auction.shipping.returnPolicy}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.bodyLarge,
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  String _calculateShipping() {
    // Default shipping calculation
    // In a real app, this would be calculated based on shipping address
    final shippingCost = auction.shipping.hasShippingCost 
        ? auction.shipping.shippingCost 
        : 9.99;
    return '\$${shippingCost.toStringAsFixed(2)}';
  }

  String _calculateTax() {
    // Default tax calculation (8.5% sales tax)
    final itemPrice = auction.buyNowPrice ?? auction.currentBid;
    final shippingCost = auction.shipping.hasShippingCost 
        ? auction.shipping.shippingCost 
        : 9.99;
    final taxRate = 0.085; // 8.5%
    final tax = (itemPrice ?? 0.0) * taxRate;
    return '\$${tax.toStringAsFixed(2)}';
  }

  String _calculateTotal() {
    final itemPrice = auction.buyNowPrice ?? auction.currentBid;
    final shippingCost = auction.shipping.hasShippingCost 
        ? auction.shipping.shippingCost 
        : 9.99;
    final taxRate = 0.085; // 8.5%
    final tax = (itemPrice ?? 0.0) * taxRate;
    final total = (itemPrice ?? 0.0) + shippingCost + tax;
    return '\$${total.toStringAsFixed(2)}';
  }
}
