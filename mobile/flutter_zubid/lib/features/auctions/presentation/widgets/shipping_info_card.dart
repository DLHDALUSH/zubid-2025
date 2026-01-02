import 'package:flutter/material.dart';

import '../../data/models/auction_model.dart';

class ShippingInfoCard extends StatelessWidget {
  final AuctionModel auction;

  const ShippingInfoCard({
    super.key,
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Shipping & Handling',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Shipping Cost
            _buildInfoRow(
              theme,
              'Shipping Cost',
              auction.shippingCostValue > 0
                  ? '\$${auction.shippingCostValue.toStringAsFixed(2)}'
                  : 'Free Shipping',
              Icons.attach_money,
              auction.shippingCostValue == 0 ? Colors.green : null,
            ),

            const SizedBox(height: 12),

            // Shipping Method
            if (auction.shippingMethodValue.isNotEmpty)
              _buildInfoRow(
                theme,
                'Shipping Method',
                auction.shippingMethodValue,
                Icons.local_shipping,
              ),

            const SizedBox(height: 12),

            // Estimated Delivery
            if (auction.estimatedDeliveryValue.isNotEmpty)
              _buildInfoRow(
                theme,
                'Estimated Delivery',
                auction.estimatedDeliveryValue,
                Icons.schedule,
              ),

            const SizedBox(height: 12),

            // Ships From
            if (auction.shipsFromValue.isNotEmpty)
              _buildInfoRow(
                theme,
                'Ships From',
                auction.shipsFromValue,
                Icons.location_on,
              ),

            const SizedBox(height: 12),

            // Ships To
            if (auction.shipsToValue.isNotEmpty)
              _buildInfoRow(
                theme,
                'Ships To',
                auction.shipsToValue,
                Icons.public,
              ),

            // Handling Time
            if (auction.handlingTimeValue.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                theme,
                'Handling Time',
                auction.handlingTimeValue,
                Icons.access_time,
              ),
            ],

            // Return Policy
            if (auction.returnPolicyValue.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Icon(
                    Icons.keyboard_return,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Return Policy',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                auction.returnPolicyValue,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            
            // Additional Shipping Notes
            if (auction.shippingNotesValue.isNotEmpty) ...[
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Additional Information',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      auction.shippingNotesValue,
                      style: theme.textTheme.bodySmall,
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

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon, [
    Color? valueColor,
  ]) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
