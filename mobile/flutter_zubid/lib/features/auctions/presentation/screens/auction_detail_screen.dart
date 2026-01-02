import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/auction_model.dart';
import '../providers/auction_detail_provider.dart';
import '../providers/bidding_provider.dart';
import '../widgets/auction_image_gallery.dart';
import '../widgets/auction_info_card.dart';
import '../widgets/bid_history_card.dart';
import '../widgets/bidding_panel.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  final String auctionId;

  const AuctionDetailScreen({
    super.key,
    required this.auctionId,
  });

  @override
  ConsumerState<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  bool _showFloatingBidButton = false;
  bool _isAppBarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
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
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showButton = _scrollController.offset > 300;
    final collapsed = _scrollController.offset > 200;

    if (showButton != _showFloatingBidButton) {
      setState(() => _showFloatingBidButton = showButton);
      if (showButton) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }

    if (collapsed != _isAppBarCollapsed) {
      setState(() => _isAppBarCollapsed = collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionState = ref.watch(auctionDetailProvider(widget.auctionId));
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isAppBarCollapsed
          ? (theme.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: LoadingOverlay(
          isLoading: auctionState.isLoading && auctionState.auction == null,
          child: auctionState.auction != null
              ? _buildAuctionDetail(auctionState.auction!)
              : _buildErrorOrEmpty(),
        ),
        floatingActionButton:
            _showFloatingBidButton && auctionState.auction?.isLive == true
                ? ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _fabAnimationController,
                      curve: Curves.easeOutBack,
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () =>
                          _showBiddingBottomSheet(auctionState.auction!),
                      icon: const Icon(Icons.gavel_rounded),
                      label: const Text(
                        'Place Bid',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      elevation: 4,
                    ),
                  )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildAuctionDetail(AuctionModel auction) {
    final theme = Theme.of(context);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Modern Hero Image with Gradient Overlay
        SliverAppBar(
          expandedHeight: 380,
          pinned: true,
          stretch: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          leading: _buildBackButton(theme),
          actions: [
            _buildActionButton(
              icon: auction.isWatched
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              color: auction.isWatched ? Colors.red : null,
              onPressed: () => _toggleWatchlist(auction),
            ),
            _buildActionButton(
              icon: Icons.share_rounded,
              onPressed: () => _shareAuction(auction),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Image Gallery
                AuctionImageGallery(
                  images: auction.images ?? [],
                  heroTag: 'auction-${auction.id}',
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
                // Status Badges at Top
                Positioned(
                  top: MediaQuery.of(context).padding.top + 56,
                  left: 16,
                  child: _buildTopBadges(auction),
                ),
                // Quick Info at Bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildQuickInfo(auction, theme),
                ),
              ],
            ),
          ),
        ),

        // Main Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pricing Card - Prominent Display
              _buildPricingCard(auction, theme),

              // Live Auction Timer (if live)
              if (auction.isLive) _buildLiveTimerSection(auction, theme),

              // Quick Actions
              if (auction.isLive) _buildQuickActions(auction, theme),

              // Detailed Info Section
              AuctionInfoCard(auction: auction),

              // Bidding Panel (if auction is live)
              if (auction.isLive) BiddingPanel(auction: auction),

              // Bid History
              BidHistoryCard(auctionId: auction.id.toString()),

              // Description
              _buildDescriptionSection(auction, theme),

              // Seller Info
              _buildSellerSection(auction, theme),

              // Buy Now (if available)
              if (auction.hasBuyNow) _buildBuyNowSection(auction, theme),

              // Safety Tips
              _buildSafetyTips(theme),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  // =============== NEW UI COMPONENTS ===============

  Widget _buildBackButton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTopBadges(AuctionModel auction) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (auction.isLive)
          _buildAnimatedBadge(
            text: 'LIVE',
            color: Colors.green,
            icon: Icons.circle,
            isAnimated: true,
          ),
        if (auction.isFeatured)
          _buildAnimatedBadge(
            text: 'FEATURED',
            color: Colors.amber.shade700,
            icon: Icons.star_rounded,
          ),
        if (auction.bidCount >= 10)
          _buildAnimatedBadge(
            text: 'HOT',
            color: Colors.deepOrange,
            icon: Icons.local_fire_department_rounded,
          ),
      ],
    );
  }

  Widget _buildAnimatedBadge({
    required String text,
    required Color color,
    required IconData icon,
    bool isAnimated = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAnimated)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Icon(icon, size: 8, color: Colors.white),
            )
          else
            Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(AuctionModel auction, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  auction.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.category_outlined,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      auction.categoryName,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.visibility_outlined,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${auction.viewCount}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '\$${auction.currentPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Bid',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${auction.currentPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${auction.bidCount} bids',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (auction.hasBuyNow)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.flash_on_rounded,
                          color: Colors.green, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Buy Now',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '\$${auction.buyNowPrice!.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              _buildStatItem(
                  theme, Icons.gavel_rounded, '${auction.bidCount}', 'Bids'),
              _buildStatDivider(theme),
              _buildStatItem(theme, Icons.visibility_rounded,
                  '${auction.viewCount}', 'Views'),
              _buildStatDivider(theme),
              _buildStatItem(theme, Icons.favorite_rounded,
                  '${auction.watchCount}', 'Watching'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      ThemeData theme, IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 40,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }

  Widget _buildLiveTimerSection(AuctionModel auction, ThemeData theme) {
    final isEndingSoon = auction.timeRemaining.inMinutes < 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEndingSoon
            ? Colors.red.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEndingSoon
              ? Colors.red.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEndingSoon
                  ? Colors.red.withValues(alpha: 0.2)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEndingSoon ? Icons.timer : Icons.access_time_rounded,
              color: isEndingSoon ? Colors.red : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEndingSoon ? 'Ending Soon!' : 'Time Remaining',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isEndingSoon ? Colors.red : null,
                    fontWeight: isEndingSoon ? FontWeight.bold : null,
                  ),
                ),
                Text(
                  auction.timeRemainingText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isEndingSoon ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ),
          if (isEndingSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'URGENT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AuctionModel auction, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              theme: theme,
              icon: Icons.gavel_rounded,
              label: 'Place Bid',
              isPrimary: true,
              onPressed: () => _showBiddingBottomSheet(auction),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              theme: theme,
              icon: auction.isWatched
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              label: auction.isWatched ? 'Watching' : 'Watch',
              isPrimary: false,
              onPressed: () => _toggleWatchlist(auction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: isPrimary
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isPrimary
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            auction.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          if (auction.condition?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Condition: ${auction.condition}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSellerSection(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              auction.sellerUsername.isNotEmpty
                  ? auction.sellerUsername[0].toUpperCase()
                  : 'S',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.sellerUsername,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      auction.sellerRating != null
                          ? '${auction.sellerRating!.toStringAsFixed(1)} rating'
                          : 'New seller',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyNowSection(AuctionModel auction, ThemeData theme) {
    final biddingState = ref.watch(biddingProvider(auction.id.toString()));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flash_on_rounded,
                    color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buy Now Available',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Skip the bidding and purchase immediately',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buy Now Price',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '\$${(auction.buyNowPrice ?? 0.0).toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: biddingState.isBuyingNow
                    ? null
                    : () => _handleBuyNow(auction),
                icon: biddingState.isBuyingNow
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.shopping_cart_rounded),
                label: Text(
                    biddingState.isBuyingNow ? 'Processing...' : 'Buy Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTips(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buyer Protection',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  'Your purchase is protected by our secure payment system',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBuyNow(AuctionModel auction) async {
    final theme = Theme.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text(
          'Are you sure you want to buy this item for \$${(auction.buyNowPrice ?? 0.0).toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(biddingProvider(auction.id.toString()).notifier)
          .buyNow('default_payment_method');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Purchase successful! Check your orders for details.'
                  : 'Purchase failed. Please try again.',
            ),
            backgroundColor: success ? Colors.green : theme.colorScheme.error,
          ),
        );
      }
    }
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
                error != null
                    ? Icons.error_outline
                    : Icons.inventory_2_outlined,
                size: 64,
                color: error != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
    final success = await ref
        .read(auctionDetailProvider(widget.auctionId).notifier)
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
          backgroundColor:
              success ? Colors.green : Theme.of(context).colorScheme.error,
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
