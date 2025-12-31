import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/buy_now_provider.dart';

class PaymentMethodSelector extends ConsumerStatefulWidget {
  const PaymentMethodSelector({super.key});

  @override
  ConsumerState<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends ConsumerState<PaymentMethodSelector> {
  String? _selectedMethod;

  final List<PaymentMethodOption> _paymentMethods = [
    const PaymentMethodOption(
      id: 'stripe',
      name: 'Credit/Debit Card',
      description: 'Visa, Mastercard, American Express',
      icon: Icons.credit_card,
      isEnabled: true,
    ),
    const PaymentMethodOption(
      id: 'paypal',
      name: 'PayPal',
      description: 'Pay with your PayPal account',
      icon: Icons.account_balance_wallet,
      isEnabled: true,
    ),
    const PaymentMethodOption(
      id: 'apple_pay',
      name: 'Apple Pay',
      description: 'Pay with Touch ID or Face ID',
      icon: Icons.phone_iphone,
      isEnabled: false, // TODO: Enable based on platform
    ),
    const PaymentMethodOption(
      id: 'google_pay',
      name: 'Google Pay',
      description: 'Pay with Google Pay',
      icon: Icons.android,
      isEnabled: false, // TODO: Enable based on platform
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentMethod = ref.watch(paymentMethodProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ..._paymentMethods.map((method) => _buildPaymentMethodTile(
              theme,
              method,
              _selectedMethod == method.id,
            )),
            
            if (_selectedMethod == 'stripe') ...[
              const SizedBox(height: 16),
              _buildCreditCardForm(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    ThemeData theme,
    PaymentMethodOption method,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: method.isEnabled ? () => _selectPaymentMethod(method.id) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected 
                  ? theme.colorScheme.primaryContainer.withOpacity(0.1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  method.icon,
                  color: method.isEnabled 
                      ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: method.isEnabled 
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        method.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: method.isEnabled 
                              ? theme.colorScheme.onSurface.withOpacity(0.6)
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (method.isEnabled)
                  Radio<String>(
                    value: method.id,
                    groupValue: _selectedMethod,
                    onChanged: (value) => _selectPaymentMethod(value!),
                    activeColor: theme.colorScheme.primary,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Information',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Secure payment processing will be handled by Stripe. You\'ll be redirected to enter your card details securely.',
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
    );
  }

  void _selectPaymentMethod(String methodId) {
    setState(() {
      _selectedMethod = methodId;
    });
    
    ref.read(buyNowProvider.notifier).setPaymentMethod(methodId);
  }
}

class PaymentMethodOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isEnabled;

  const PaymentMethodOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isEnabled = true,
  });
}
