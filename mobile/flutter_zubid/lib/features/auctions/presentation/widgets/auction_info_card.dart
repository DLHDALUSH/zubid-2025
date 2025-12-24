import 'package:flutter/material.dart';

import '../../data/models/auction_model.dart';

class AuctionInfoCard extends StatelessWidget {
  final AuctionModel auction;

  const AuctionInfoCard({
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
            // Title and Featured Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    auction.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (auction.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'FEATURED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Category and Item Number
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  auction.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.tag,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Item #${auction.id}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Price Information
            _buildPriceSection(theme),
            
            const SizedBox(height: 16),
            
            // Time and Status
            _buildTimeAndStatus(theme),
            
            const SizedBox(height: 16),
            
            // Stats Row
            _buildStatsRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme) {
    return Row(
      children: [
        // Current Price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Bid',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${auction.currentPrice.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Buy Now Price (if available)
        if (auction.hasBuyNow) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buy It Now',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${auction.buyNowPrice!.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Reserve Price Indicator
        if (auction.hasReserve)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: auction.reserveMet 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: auction.reserveMet ? Colors.green : Colors.orange,
              ),
            ),
            child: Text(
              auction.reserveMet ? 'Reserve Met' : 'Reserve Not Met',
              style: theme.textTheme.labelSmall?.copyWith(
                color: auction.reserveMet ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeAndStatus(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.statusText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (auction.isLive)
                  Text(
                    auction.timeRemainingText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (auction.isLive)
            Icon(
              Icons.access_time,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        _buildStatItem(
          theme,
          Icons.gavel,
          '${auction.bidCount}',
          'Bids',
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          theme,
          Icons.visibility,
          '${auction.viewCount}',
          'Views',
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          theme,
          Icons.favorite,
          '${auction.watchCount}',
          'Watching',
        ),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (auction.status.toLowerCase()) {
      case 'active':
        return auction.isLive ? Colors.green : Colors.blue;
      case 'ended':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (auction.status.toLowerCase()) {
      case 'active':
        return auction.isLive ? Icons.play_circle : Icons.pause_circle;
      case 'ended':
        return Icons.stop_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
