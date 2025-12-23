import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auction_creation_provider.dart';

class AuctionFormStep3 extends ConsumerStatefulWidget {
  const AuctionFormStep3({super.key});

  @override
  ConsumerState<AuctionFormStep3> createState() => _AuctionFormStep3State();
}

class _AuctionFormStep3State extends ConsumerState<AuctionFormStep3> {
  final _formKey = GlobalKey<FormState>();
  final _startingBidController = TextEditingController();
  final _buyNowPriceController = TextEditingController();
  
  DateTime? _selectedEndTime;
  bool _hasBuyNowPrice = false;
  int _selectedDuration = 7; // days
  
  final List<int> _durationOptions = [1, 3, 5, 7, 10, 14, 21, 30];

  @override
  void initState() {
    super.initState();
    final draftAuction = ref.read(auctionCreationProvider).draftAuction;
    if (draftAuction != null) {
      _startingBidController.text = draftAuction.startingBid.toStringAsFixed(2);
      if (draftAuction.buyNowPrice != null) {
        _hasBuyNowPrice = true;
        _buyNowPriceController.text = draftAuction.buyNowPrice!.toStringAsFixed(2);
      }
      _selectedEndTime = draftAuction.endTime;
    } else {
      // Set default end time
      _selectedEndTime = DateTime.now().add(Duration(days: _selectedDuration));
    }
  }

  @override
  void dispose() {
    _startingBidController.dispose();
    _buyNowPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing & Duration',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Set your starting bid and auction duration',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Starting Bid
            CustomTextField(
              controller: _startingBidController,
              label: 'Starting Bid',
              hint: '0.00',
              prefixText: '\$',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Starting bid is required';
                }
                final bid = double.tryParse(value);
                if (bid == null || bid <= 0) {
                  return 'Please enter a valid starting bid';
                }
                if (bid < 0.01) {
                  return 'Starting bid must be at least \$0.01';
                }
                return null;
              },
              onChanged: _updateDraft,
            ),
            
            const SizedBox(height: 16),
            
            // Buy Now Price Toggle
            CheckboxListTile(
              title: const Text('Enable Buy It Now'),
              subtitle: const Text('Allow buyers to purchase immediately'),
              value: _hasBuyNowPrice,
              onChanged: (value) {
                setState(() {
                  _hasBuyNowPrice = value ?? false;
                  if (!_hasBuyNowPrice) {
                    _buyNowPriceController.clear();
                  }
                });
                _updateDraft();
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            // Buy Now Price Field
            if (_hasBuyNowPrice) ...[
              const SizedBox(height: 8),
              CustomTextField(
                controller: _buyNowPriceController,
                label: 'Buy It Now Price',
                hint: '0.00',
                prefixText: '\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (_hasBuyNowPrice) {
                    if (value == null || value.isEmpty) {
                      return 'Buy It Now price is required';
                    }
                    final buyNowPrice = double.tryParse(value);
                    final startingBid = double.tryParse(_startingBidController.text);
                    
                    if (buyNowPrice == null || buyNowPrice <= 0) {
                      return 'Please enter a valid Buy It Now price';
                    }
                    if (startingBid != null && buyNowPrice <= startingBid) {
                      return 'Buy It Now price must be higher than starting bid';
                    }
                  }
                  return null;
                },
                onChanged: _updateDraft,
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Duration Selection
            Text(
              'Auction Duration',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _durationOptions.map((days) {
                final isSelected = _selectedDuration == days;
                return FilterChip(
                  label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDuration = days;
                        _selectedEndTime = DateTime.now().add(Duration(days: days));
                      });
                      _updateDraft();
                    }
                  },
                  backgroundColor: isSelected 
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceVariant,
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // End Time Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auction will end on:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedEndTime != null
                              ? _formatDateTime(_selectedEndTime!)
                              : 'Not set',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Pricing Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pricing Tips',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    '• Research similar items to set competitive prices\n'
                    '• Lower starting bids can attract more bidders\n'
                    '• Buy It Now prices should be fair market value\n'
                    '• Longer auctions may get more visibility\n'
                    '• Consider ending auctions on weekends',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      height: 1.4,
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

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$month $day, $year at $displayHour:$minute $amPm';
  }

  void _updateDraft([String? value]) {
    // Validate form and update draft
    _formKey.currentState?.validate();
  }
}
