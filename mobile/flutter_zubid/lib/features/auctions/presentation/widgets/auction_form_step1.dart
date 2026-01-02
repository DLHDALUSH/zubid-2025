import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auction_creation_provider.dart';

class AuctionFormStep1 extends ConsumerStatefulWidget {
  const AuctionFormStep1({super.key});

  @override
  ConsumerState<AuctionFormStep1> createState() => _AuctionFormStep1State();
}

class _AuctionFormStep1State extends ConsumerState<AuctionFormStep1> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  
  String _selectedCondition = 'New';
  final List<String> _conditions = [
    'New',
    'Like New',
    'Excellent',
    'Very Good',
    'Good',
    'Fair',
    'Poor',
  ];

  @override
  void initState() {
    super.initState();
    final draftAuction = ref.read(auctionCreationProvider).draftAuction;
    if (draftAuction != null) {
      _titleController.text = draftAuction.title;
      _descriptionController.text = draftAuction.description;
      _brandController.text = draftAuction.brand ?? '';
      _modelController.text = draftAuction.model ?? '';
      _selectedCondition = draftAuction.condition;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
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
              'Basic Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Provide the basic details about your item',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title Field
            CustomTextField(
              controller: _titleController,
              label: 'Auction Title',
              hint: 'Enter a descriptive title for your auction',
              maxLength: 80,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.length < 10) {
                  return 'Title must be at least 10 characters';
                }
                return null;
              },
              onChanged: _updateDraft,
            ),
            
            const SizedBox(height: 16),
            
            // Description Field
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your item in detail...',
              maxLines: 6,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                if (value.length < 50) {
                  return 'Description must be at least 50 characters';
                }
                return null;
              },
              onChanged: _updateDraft,
            ),
            
            const SizedBox(height: 16),
            
            // Condition Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCondition,
              decoration: InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _conditions.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCondition = value;
                  });
                  _updateDraft();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a condition';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Brand Field (Optional)
            CustomTextField(
              controller: _brandController,
              label: 'Brand (Optional)',
              hint: 'Enter the brand name',
              onChanged: _updateDraft,
            ),
            
            const SizedBox(height: 16),
            
            // Model Field (Optional)
            CustomTextField(
              controller: _modelController,
              label: 'Model (Optional)',
              hint: 'Enter the model name/number',
              onChanged: _updateDraft,
            ),
            
            const SizedBox(height: 24),
            
            // Tips Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                        'Tips for a Great Listing',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    '• Use specific keywords in your title\n'
                    '• Be honest about the item\'s condition\n'
                    '• Include all relevant details in the description\n'
                    '• Mention any defects or issues upfront\n'
                    '• Add brand and model for better searchability',
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

  void _updateDraft([String? value]) {
    // For now, we'll just validate the form
    // The actual draft saving will be handled when moving to next step
    _formKey.currentState?.validate();
  }
}
