import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/auction_model.dart';
import '../providers/bidding_provider.dart';

class BiddingPanel extends ConsumerStatefulWidget {
  final AuctionModel auction;
  final bool isBottomSheet;

  const BiddingPanel({
    super.key,
    required this.auction,
    this.isBottomSheet = false,
  });

  @override
  ConsumerState<BiddingPanel> createState() => _BiddingPanelState();
}

class _BiddingPanelState extends ConsumerState<BiddingPanel> {
  final _bidController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _bidController.text = (widget.auction.minimumBid ?? 0.0).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final biddingState =
        ref.watch(biddingProvider(widget.auction.id.toString()));

    if (widget.isBottomSheet) {
      return _buildBottomSheetContent(theme, biddingState);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBiddingContent(theme, biddingState),
      ),
    );
  }

  Widget _buildBottomSheetContent(ThemeData theme, BiddingState biddingState) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            'Place Your Bid',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          _buildBiddingContent(theme, biddingState),
        ],
      ),
    );
  }

  Widget _buildBiddingContent(ThemeData theme, BiddingState biddingState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Price Info
          _buildCurrentPriceInfo(theme),

          const SizedBox(height: 20),

          // Bid Amount Input - Direct entry
          _buildBidInput(theme),

          const SizedBox(height: 20),

          // Action Buttons
          _buildActionButtons(theme, biddingState),

          // Buy Now Button (if available)
          if (widget.auction.hasBuyNow) ...[
            const SizedBox(height: 12),
            _buildBuyNowButton(theme, biddingState),
          ],

          // Error Message
          if (biddingState.hasError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                biddingState.error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentPriceInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Bid',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '\$${widget.auction.currentPrice.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Minimum Bid',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '\$${(widget.auction.minimumBid ?? 0.0).toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBidInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Your Bid Amount',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _bidController,
          label: 'Bid Amount',
          prefixText: '\$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a bid amount';
            }

            final bidAmount = double.tryParse(value);
            if (bidAmount == null) {
              return 'Please enter a valid amount';
            }

            if (bidAmount < (widget.auction.minimumBid ?? 0.0)) {
              return 'Bid must be at least \$${(widget.auction.minimumBid ?? 0.0).toStringAsFixed(2)}';
            }

            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Minimum bid: \$${(widget.auction.minimumBid ?? 0.0).toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, BiddingState biddingState) {
    return CustomButton(
      text: 'Place Bid',
      onPressed: biddingState.isPlacingBid ? null : _placeBid,
      isLoading: biddingState.isPlacingBid,
      icon: Icons.gavel,
    );
  }

  Widget _buildBuyNowButton(ThemeData theme, BiddingState biddingState) {
    return CustomButton(
      text: 'Buy It Now - \$${widget.auction.buyNowPrice!.toStringAsFixed(2)}',
      onPressed: biddingState.isBuyingNow ? null : _buyNow,
      isLoading: biddingState.isBuyingNow,
      icon: Icons.shopping_cart,
      backgroundColor: Colors.green,
    );
  }

  Future<void> _placeBid() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bidAmount = double.parse(_bidController.text);

    AppLogger.userAction(
        'Placing bid: \$${bidAmount.toStringAsFixed(2)} on auction ${widget.auction.id}');

    final success = await ref
        .read(biddingProvider(widget.auction.id.toString()).notifier)
        .placeBid(bidAmount);

    if (mounted) {
      if (success) {
        if (widget.isBottomSheet) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Bid placed successfully for \$${bidAmount.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message from state
        final errorMessage =
            ref.read(biddingProvider(widget.auction.id.toString())).error ??
                'Failed to place bid. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _placeBid,
            ),
          ),
        );
      }
    }
  }

  Future<void> _buyNow() async {
    AppLogger.userAction('Buy now clicked for auction ${widget.auction.id}');

    if (widget.isBottomSheet && mounted) {
      Navigator.of(context).pop();
    }

    if (mounted) {
      context.push('/buy-now', extra: widget.auction);
    }
  }
}
