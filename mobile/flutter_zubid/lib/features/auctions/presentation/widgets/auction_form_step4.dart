import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/create_auction_model.dart';
import '../providers/auction_creation_provider.dart';

class AuctionFormStep4 extends ConsumerStatefulWidget {
  const AuctionFormStep4({super.key});

  @override
  ConsumerState<AuctionFormStep4> createState() => _AuctionFormStep4State();
}

class _AuctionFormStep4State extends ConsumerState<AuctionFormStep4> {
  final _formKey = GlobalKey<FormState>();
  final _shippingCostController = TextEditingController();
  final _internationalShippingController = TextEditingController();
  final _handlingTimeController = TextEditingController();
  final _returnPolicyController = TextEditingController();
  final _shippingNotesController = TextEditingController();
  
  String _selectedShippingMethod = 'Standard Shipping';
  bool _allowInternationalShipping = false;
  bool _freeShipping = false;
  int _handlingTime = 1;
  
  final List<String> _shippingMethods = [
    'Standard Shipping',
    'Express Shipping',
    'Overnight Shipping',
    'Local Pickup',
    'Freight Shipping',
  ];

  @override
  void initState() {
    super.initState();
    _handlingTimeController.text = _handlingTime.toString();
    
    final draftAuction = ref.read(auctionCreationProvider).draftAuction;
    if (draftAuction != null) {
      _shippingCostController.text = draftAuction.shippingInfo.domesticShippingCost.toStringAsFixed(2);
      _selectedShippingMethod = draftAuction.shippingInfo.shippingMethod;
      _allowInternationalShipping = draftAuction.allowInternationalShipping;
      _freeShipping = draftAuction.shippingInfo.freeShipping;
      _handlingTime = draftAuction.handlingTime;
      _handlingTimeController.text = _handlingTime.toString();
      
      if (draftAuction.shippingInfo.internationalShippingCost != null) {
        _internationalShippingController.text = 
            draftAuction.shippingInfo.internationalShippingCost!.toStringAsFixed(2);
      }
      
      if (draftAuction.returnPolicy != null) {
        _returnPolicyController.text = draftAuction.returnPolicy!;
      }
      
      if (draftAuction.shippingInfo.shippingNotes != null) {
        _shippingNotesController.text = draftAuction.shippingInfo.shippingNotes!;
      }
    }
  }

  @override
  void dispose() {
    _shippingCostController.dispose();
    _internationalShippingController.dispose();
    _handlingTimeController.dispose();
    _returnPolicyController.dispose();
    _shippingNotesController.dispose();
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
              'Shipping & Review',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Set shipping options and review your listing',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Shipping Method
            DropdownButtonFormField<String>(
              value: _selectedShippingMethod,
              decoration: InputDecoration(
                labelText: 'Shipping Method',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _shippingMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedShippingMethod = value;
                  });
                  _saveDraft();
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Free Shipping Toggle
            CheckboxListTile(
              title: const Text('Free Shipping'),
              subtitle: const Text('Offer free shipping to buyers'),
              value: _freeShipping,
              onChanged: (value) {
                setState(() {
                  _freeShipping = value ?? false;
                  if (_freeShipping) {
                    _shippingCostController.text = '0.00';
                  }
                });
                _saveDraft();
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            // Shipping Cost
            if (!_freeShipping) ...[
              const SizedBox(height: 8),
              CustomTextField(
                controller: _shippingCostController,
                label: 'Domestic Shipping Cost',
                hint: '0.00',
                prefixText: '\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (!_freeShipping) {
                    if (value == null || value.isEmpty) {
                      return 'Shipping cost is required';
                    }
                    final cost = double.tryParse(value);
                    if (cost == null || cost < 0) {
                      return 'Please enter a valid shipping cost';
                    }
                  }
                  return null;
                },
                onChanged: (value) => _saveDraft(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // International Shipping
            CheckboxListTile(
              title: const Text('International Shipping'),
              subtitle: const Text('Ship to international buyers'),
              value: _allowInternationalShipping,
              onChanged: (value) {
                setState(() {
                  _allowInternationalShipping = value ?? false;
                  if (!_allowInternationalShipping) {
                    _internationalShippingController.clear();
                  }
                });
                _saveDraft();
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            if (_allowInternationalShipping) ...[
              const SizedBox(height: 8),
              CustomTextField(
                controller: _internationalShippingController,
                label: 'International Shipping Cost',
                hint: '0.00',
                prefixText: '\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (_allowInternationalShipping) {
                    if (value == null || value.isEmpty) {
                      return 'International shipping cost is required';
                    }
                    final cost = double.tryParse(value);
                    if (cost == null || cost < 0) {
                      return 'Please enter a valid shipping cost';
                    }
                  }
                  return null;
                },
                onChanged: (value) => _saveDraft(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Handling Time
            CustomTextField(
              controller: _handlingTimeController,
              label: 'Handling Time (days)',
              hint: '1',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Handling time is required';
                }
                final days = int.tryParse(value);
                if (days == null || days < 1 || days > 30) {
                  return 'Handling time must be between 1 and 30 days';
                }
                return null;
              },
              onChanged: (value) {
                final days = int.tryParse(value);
                if (days != null) {
                  _handlingTime = days;
                }
                _saveDraft();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Return Policy
            CustomTextField(
              controller: _returnPolicyController,
              label: 'Return Policy (Optional)',
              hint: 'Describe your return policy...',
              maxLines: 3,
              maxLength: 500,
              onChanged: (value) => _saveDraft(),
            ),
            
            const SizedBox(height: 16),
            
            // Shipping Notes
            CustomTextField(
              controller: _shippingNotesController,
              label: 'Shipping Notes (Optional)',
              hint: 'Additional shipping information...',
              maxLines: 2,
              maxLength: 200,
              onChanged: (value) => _saveDraft(),
            ),
            
            const SizedBox(height: 24),
            
            // Review Section
            _buildReviewSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(ThemeData theme) {
    final creationState = ref.watch(auctionCreationProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Listing',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Validation Status
              Row(
                children: [
                  Icon(
                    creationState.canCreateAuction ? Icons.check_circle : Icons.error,
                    color: creationState.canCreateAuction ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    creationState.canCreateAuction 
                        ? 'Ready to create auction'
                        : 'Please complete all required fields',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: creationState.canCreateAuction ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Checklist
              _buildChecklistItem(
                theme,
                'Basic information completed',
                creationState.draftAuction?.title.isNotEmpty == true,
              ),
              _buildChecklistItem(
                theme,
                'Category selected',
                creationState.selectedCategory != null,
              ),
              _buildChecklistItem(
                theme,
                'Images added',
                creationState.hasImages,
              ),
              _buildChecklistItem(
                theme,
                'Pricing set',
                creationState.draftAuction?.startingBid != null,
              ),
              _buildChecklistItem(
                theme,
                'Shipping configured',
                _formKey.currentState?.validate() == true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(ThemeData theme, String text, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isCompleted ? Colors.green : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCompleted 
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _saveDraft() {
    // Create shipping info
    final shippingInfo = ShippingInfo(
      domesticShippingCost: _freeShipping ? 0.0 : (double.tryParse(_shippingCostController.text) ?? 0.0),
      internationalShippingCost: _allowInternationalShipping 
          ? (double.tryParse(_internationalShippingController.text) ?? 0.0)
          : null,
      shippingMethod: _selectedShippingMethod,
      shipsTo: _allowInternationalShipping ? ['Worldwide'] : ['Domestic'],
      shippingNotes: _shippingNotesController.text.isEmpty ? null : _shippingNotesController.text,
      freeShipping: _freeShipping,
    );

    // Get current draft and update with shipping info
    final currentState = ref.read(auctionCreationProvider);
    if (currentState.selectedCategory != null) {
      // This would normally create a complete CreateAuctionRequest
      // For now, we'll just validate the form
      _formKey.currentState?.validate();
    }
  }
}
