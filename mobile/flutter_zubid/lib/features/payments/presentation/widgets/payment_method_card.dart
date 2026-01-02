import 'package:flutter/material.dart';

import '../../data/models/payment_method_model.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel paymentMethod;
  final VoidCallback? onTap;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;
  final bool showActions;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    this.onTap,
    this.onSetDefault,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Payment method icon
                  Container(
                    width: 48,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        paymentMethod.displayIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Payment method details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentMethod.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _buildStatusChip(theme),
                            if (paymentMethod.isDefault) ...[
                              const SizedBox(width: 8),
                              _buildDefaultChip(theme),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions menu
                  if (showActions)
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value),
                      itemBuilder: (context) => [
                        if (!paymentMethod.isDefault && onSetDefault != null)
                          const PopupMenuItem(
                            value: 'set_default',
                            child: Row(
                              children: [
                                Icon(Icons.star_outline),
                                SizedBox(width: 8),
                                Text('Set as Default'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              
              // Additional details for FIB
              if (paymentMethod.type == 'fib' && paymentMethod.accountLast4 != null) ...[
                const SizedBox(height: 12),
                Text(
                  'First Iraqi Bank Account',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              // Additional details for ZAIN CASH
              if (paymentMethod.type == 'zain_cash' && paymentMethod.email != null) ...[
                const SizedBox(height: 12),
                Text(
                  'ZAIN CASH Mobile Wallet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              // Additional details for VISA
              if (paymentMethod.type == 'visa' && paymentMethod.cardExpMonth != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Expires ${paymentMethod.cardExpMonth}/${paymentMethod.cardExpYear}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: paymentMethod.isExpired
                        ? Colors.red
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],

              // Additional details for MASTERCARD
              if (paymentMethod.type == 'mastercard' && paymentMethod.cardExpMonth != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Expires ${paymentMethod.cardExpMonth}/${paymentMethod.cardExpYear}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: paymentMethod.isExpired
                        ? Colors.red
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],

              // Additional details for cards
              if (paymentMethod.type == 'card' && paymentMethod.cardExpMonth != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Expires ${paymentMethod.cardExpMonth}/${paymentMethod.cardExpYear}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: paymentMethod.isExpired
                        ? Colors.red
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],

              // Additional details for PayPal
              if (paymentMethod.type == 'paypal' && paymentMethod.email != null) ...[
                const SizedBox(height: 12),
                Text(
                  paymentMethod.email!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],

              // Additional details for bank accounts
              if (paymentMethod.type == 'bank_transfer' && paymentMethod.bankName != null) ...[
                const SizedBox(height: 12),
                Text(
                  paymentMethod.bankName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color chipColor;
    Color textColor;
    
    if (paymentMethod.isExpired) {
      chipColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red;
    } else if (!paymentMethod.isVerified) {
      chipColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange;
    } else {
      chipColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        paymentMethod.statusText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDefaultChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Default',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'set_default':
        onSetDefault?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
