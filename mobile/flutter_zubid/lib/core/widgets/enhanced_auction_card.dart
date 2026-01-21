import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../features/auctions/data/models/auction_model.dart';
import '../config/app_config.dart';

class EnhancedAuctionCard extends StatefulWidget {
  final AuctionModel auction;
  final VoidCallback? onTap;
  final VoidCallback? onWatchlistToggle;
  final VoidCallback? onShare;
  final bool showBidButton;
  final bool isCompact;

  const EnhancedAuctionCard({
    super.key,
    required this.auction,
    this.onTap,
    this.onWatchlistToggle,
    this.onShare,
    this.showBidButton = true,
    this.isCompact = false,
  });

  @override
  State<EnhancedAuctionCard> createState() => _EnhancedAuctionCardState();
}

class _EnhancedAuctionCardState extends State<EnhancedAuctionCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnded = widget.auction.status == 'ended';
    final timeRemaining = widget.auction.endTime.difference(DateTime.now());
    final isUrgent = timeRemaining.inHours < 24 && timeRemaining.inSeconds > 0;

    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: () => _handleTapUp(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : 1.0,
            child: Container(
              margin: EdgeInsets.all(widget.isCompact ? 4 : 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(theme, isUrgent, isEnded),
                    _buildContentSection(theme, timeRemaining, isEnded),
                    if (widget.showBidButton && !widget.isCompact)
                      _buildActionSection(theme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  Widget _buildImageSection(ThemeData theme, bool isUrgent, bool isEnded) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: widget.isCompact ? 16 / 9 : 4 / 3,
            child: _buildImage(),
          ),
        ),
        _buildImageOverlays(theme, isUrgent, isEnded),
      ],
    );
  }

  Widget _buildImage() {
    final imageUrl = widget.auction.imageUrls.isNotEmpty
        ? AppConfig.getFullImageUrl(widget.auction.imageUrls.first)
        : null;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 48),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 48),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }

  Widget _buildImageOverlays(ThemeData theme, bool isUrgent, bool isEnded) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          // Status badges
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              children: [
                if (widget.auction.isFeatured)
                  _buildBadge('Featured', Colors.orange, Icons.star),
                if (isUrgent && !isEnded)
                  _buildBadge('Urgent', Colors.red, Icons.access_time)
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 1000.ms),
                if (isEnded) _buildBadge('Ended', Colors.grey, Icons.gavel),
              ],
            ),
          ),
          // Action buttons
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                if (widget.onWatchlistToggle != null)
                  _buildActionButton(
                    icon: widget.auction.isWatched
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.auction.isWatched ? Colors.red : Colors.white,
                    onPressed: widget.onWatchlistToggle,
                  ),
                if (widget.onShare != null)
                  _buildActionButton(
                    icon: Icons.share,
                    color: Colors.white,
                    onPressed: widget.onShare,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(
      ThemeData theme, Duration timeRemaining, bool isEnded) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.auction.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: widget.isCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Category and location
          Row(
            children: [
              Icon(Icons.category,
                  size: 14, color: theme.colorScheme.secondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.auction.categoryName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.auction.location != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.location_on,
                    size: 14, color: theme.colorScheme.secondary),
                const SizedBox(width: 2),
                Text(
                  widget.auction.location!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Price information
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Bid',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Text(
                      '\$${widget.auction.currentPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.auction.buyNowPrice != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Buy Now',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Text(
                      '\$${widget.auction.buyNowPrice!.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Time and bid info
          Row(
            children: [
              Expanded(
                child: _buildTimeRemaining(theme, timeRemaining, isEnded),
              ),
              Text(
                '${widget.auction.bidCount} bids',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemaining(
      ThemeData theme, Duration timeRemaining, bool isEnded) {
    if (isEnded) {
      return Row(
        children: [
          Icon(Icons.gavel, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            'Auction Ended',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      );
    }

    final isUrgent = timeRemaining.inHours < 24;
    final color = isUrgent ? Colors.red : theme.colorScheme.secondary;

    String timeText;
    if (timeRemaining.inDays > 0) {
      timeText = '${timeRemaining.inDays}d ${timeRemaining.inHours % 24}h';
    } else if (timeRemaining.inHours > 0) {
      timeText = '${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}m';
    } else if (timeRemaining.inMinutes > 0) {
      timeText = '${timeRemaining.inMinutes}m';
    } else {
      timeText = 'Ending soon';
    }

    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          timeText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onTap,
              icon: const Icon(Icons.gavel, size: 18),
              label: const Text('Place Bid'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (widget.auction.buyNowPrice != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onTap,
                icon: const Icon(Icons.shopping_cart, size: 18),
                label: const Text('Buy Now'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
