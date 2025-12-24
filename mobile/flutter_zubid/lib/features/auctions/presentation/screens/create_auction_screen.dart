import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/auction_creation_provider.dart';
import '../widgets/auction_form_step1.dart';
import '../widgets/auction_form_step2.dart';
import '../widgets/auction_form_step3.dart';
import '../widgets/auction_form_step4.dart';

class CreateAuctionScreen extends ConsumerStatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  ConsumerState<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends ConsumerState<CreateAuctionScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final creationState = ref.watch(auctionCreationProvider);

    return LoadingOverlay(
      isLoading: creationState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Auction'),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          actions: [
            if (_currentStep > 0)
              TextButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
          ],
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(theme),
            
            // Form Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: const [
                  AuctionFormStep1(), // Basic Information
                  AuctionFormStep2(), // Images and Category
                  AuctionFormStep3(), // Pricing and Duration
                  AuctionFormStep4(), // Shipping and Review
                ],
              ),
            ),
            
            // Navigation Buttons
            _buildNavigationButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Step Indicators
          Row(
            children: List.generate(_totalSteps, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    // Step Circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.onPrimary,
                                size: 16,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    
                    // Connector Line
                    if (index < _totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // Step Labels
          Row(
            children: [
              Expanded(
                child: Text(
                  'Basic Info',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _currentStep == 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: _currentStep == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Images',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _currentStep == 1
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: _currentStep == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Pricing',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _currentStep == 2
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: _currentStep == 2 ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Review',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _currentStep == 3
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: _currentStep == 3 ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: CustomButton(
                text: 'Previous',
                onPressed: _previousStep,
                variant: ButtonVariant.outlined,
                icon: Icons.arrow_back,
              ),
            ),
            const SizedBox(width: 16),
          ],

          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: CustomButton(
              text: _currentStep == _totalSteps - 1 ? 'Create Auction' : 'Next',
              onPressed: _currentStep == _totalSteps - 1 ? _createAuction : _nextStep,
              icon: _currentStep == _totalSteps - 1 ? Icons.check : Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createAuction() async {
    final creationState = ref.read(auctionCreationProvider);

    if (creationState.draftAuction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref
        .read(auctionCreationProvider.notifier)
        .createAuction(creationState.draftAuction!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auction created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(creationState.error ?? 'Failed to create auction'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
