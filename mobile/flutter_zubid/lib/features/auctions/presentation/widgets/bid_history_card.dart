import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/bid_model.dart';
import '../providers/bidding_provider.dart';

class BidHistoryCard extends ConsumerWidget {
  final String auctionId;

  const BidHistoryCard({
    super.key,
    required this.auctionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final biddingState = ref.watch(biddingProvider(auctionId));

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
                  Icons.history,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bid History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (biddingState.hasBids)
                  Text(
                    '${biddingState.bids.length} bids',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Content
            if (biddingState.isLoading && !biddingState.hasBids)
              _buildLoadingState()
            else if (biddingState.hasError && !biddingState.hasBids)
              _buildErrorState(theme, biddingState.error!)
            else if (!biddingState.hasBids)
              _buildEmptyState(theme)
            else
              _buildBidList(theme, biddingState.bids),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load bid history',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.gavel_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No bids yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to place a bid!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidList(ThemeData theme, List<BidModel> bids) {
    // Show only the first 5 bids initially
    final displayBids = bids.take(5).toList();
    final hasMoreBids = bids.length > 5;

    return Column(
      children: [
        ...displayBids.map((bid) => _buildBidItem(theme, bid)),
        
        if (hasMoreBids) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showAllBids(bids),
            child: Text('View all ${bids.length} bids'),
          ),
        ],
      ],
    );
  }

  Widget _buildBidItem(ThemeData theme, BidModel bid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: bid.hasUserAvatar
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: bid.userAvatar!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          
          const SizedBox(width: 12),
          
          // Bid Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      bid.displayUsername,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (bid.userRating != null) ...[
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            bid.userRating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      bid.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (bid.isAutoBid) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AUTO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Bid Amount and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bid.formattedAmount,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: bid.isWinning ? Colors.green : null,
                ),
              ),
              if (bid.isWinning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'WINNING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllBids(List<BidModel> bids) {
    // TODO: Navigate to full bid history screen or show bottom sheet
    // For now, we'll just show a placeholder
  }
}
