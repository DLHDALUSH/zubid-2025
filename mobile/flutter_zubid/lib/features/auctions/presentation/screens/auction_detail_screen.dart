import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/auction_model.dart';
import '../providers/auction_provider.dart';
import '../providers/auction_detail_provider.dart';
import '../widgets/auction_image_gallery.dart';
import '../widgets/auction_info_card.dart';
import '../widgets/bid_history_card.dart';
import '../widgets/bidding_panel.dart';
import '../widgets/seller_info_card.dart';
import '../widgets/shipping_info_card.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  final String auctionId;

  const AuctionDetailScreen({
    super.key,
    required this.auctionId,
  });

  @override
  ConsumerState<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingBidButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load auction details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(auctionDetailProvider(widget.auctionId).notifier).loadAuction();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showButton = _scrollController.offset > 200;
    if (showButton != _showFloatingBidButton) {
      setState(() {
        _showFloatingBidButton = showButton;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionState = ref.watch(auctionDetailProvider(widget.auctionId));
    final theme = Theme.of(context);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: auctionState.isLoading && auctionState.auction == null,
        child: auctionState.auction != null
            ? _buildAuctionDetail(auctionState.auction!)
            : _buildErrorOrEmpty(),
      ),
      floatingActionButton: _showFloatingBidButton && auctionState.auction?.isLive == true
          ? FloatingActionButton.extended(
              onPressed: () => _showBiddingBottomSheet(auctionState.auction!),
              icon: const Icon(Icons.gavel),
              label: const Text('Place Bid'),
            )
          : null,
    );
  }

  Widget _buildAuctionDetail(AuctionModel auction) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar with Image Gallery
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: AuctionImageGallery(
              images: auction.images ?? [],
              heroTag: 'auction-${auction.id}',
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                auction.isWatched ? Icons.favorite : Icons.favorite_border,
                color: auction.isWatched ? Colors.red : Colors.white,
              ),
              onPressed: () => _toggleWatchlist(auction),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _shareAuction(auction),
            ),
          ],
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Auction Info
                AuctionInfoCard(auction: auction),
                
                const SizedBox(height: 16),
                
                // Bidding Panel (if auction is live)
                if (auction.isLive) ...[
                  BiddingPanel(auction: auction),
                  const SizedBox(height: 16),
                ],
                
                // Bid History
                BidHistoryCard(auctionId: auction.id.toString()),
                
                const SizedBox(height: 16),
                
                // Seller Info
                SellerInfoCard(seller: auction.seller),
                
                const SizedBox(height: 16),
                
                // Shipping Info
                ShippingInfoCard(auction: auction),
                
                const SizedBox(height: 16),
                
                // Description
                _buildDescriptionCard(auction),
                
                const SizedBox(height: 16),
                
                // Similar Auctions
                _buildSimilarAuctions(),
                
                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(AuctionModel auction) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auction.description,
              style: theme.textTheme.bodyMedium,
            ),
            
            if (auction.condition?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Condition: ${auction.condition}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarAuctions() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Similar Auctions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // TODO: Implement similar auctions list
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Text(
                  'Similar auctions will be shown here',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOrEmpty() {
    final theme = Theme.of(context);
    final error = ref.watch(auctionDetailProvider(widget.auctionId)).error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auction Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                error != null ? Icons.error_outline : Icons.inventory_2_outlined,
                size: 64,
                color: error != null 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                error != null ? 'Error Loading Auction' : 'Auction Not Found',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error ?? 'The auction you\'re looking for doesn\'t exist',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleWatchlist(AuctionModel auction) async {
    final success = await ref.read(auctionDetailProvider(widget.auctionId).notifier)
        .toggleWatchlist();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? auction.isWatched 
                    ? 'Removed from watchlist' 
                    : 'Added to watchlist'
                : 'Failed to update watchlist',
          ),
          backgroundColor: success ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _shareAuction(AuctionModel auction) {
    // TODO: Implement share functionality
    AppLogger.userAction('Share auction: ${auction.id}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
      ),
    );
  }

  void _showBiddingBottomSheet(AuctionModel auction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BiddingPanel(
        auction: auction,
        isBottomSheet: true,
      ),
    );
  }
}
