import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/media_gallery_widget.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/auction_model.dart';
import '../providers/auction_detail_provider.dart';
import '../providers/bidding_provider.dart';

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
  final TextEditingController _bidController = TextEditingController();
  late AnimationController _fabAnimationController;
  bool _showFloatingBidButton = false;
  bool _isAppBarCollapsed = false;
  bool _showBidHistory = false;
  bool _showDescription = false;

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
    _bidController.dispose();
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
                      onPressed: () {
                        // Scroll to top where bid input is
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
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
              onPressed: () => _toggleWatchList(auction),
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
                // Media Gallery (Images and Videos)
                MediaGalleryWidget(
                  mediaUrls: auction.images?.isNotEmpty == true
                      ? auction.images!
                      : auction.imageUrls,
                  heroTag: 'auction-${auction.id}',
                  showThumbnails: false, // Hide thumbnails in hero section
                  autoPlay: false, // Don't auto-play videos in hero
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

        // Main Content - Redesigned Layout with Interactive Elements
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and Basic Info Section
              _buildTitleSection(auction, theme),

              // Compact Price and Timer Section (more interactive)
              _buildCompactPricingSection(auction, theme),

              // Action Buttons Row (Watch, Share)
              _buildActionButtons(auction, theme),

              // Inline Bid Input (prominent, if live)
              if (auction.isLive) _buildInlineBidInput(auction, theme),

              // Buy It Now Button (prominent)
              if (auction.isLive && auction.hasBuyNow)
                _buildBuyNowButton(auction, theme),

              // Condition and Details Section
              _buildConditionSection(auction, theme),

              // Seller Information Section
              _buildSellerSection(auction, theme),

              // Collapsible Description Section (more interactive)
              _buildCompactDescription(auction, theme),
              const SizedBox(height: 12),

              // Collapsible Bid History Section (more interactive)
              _buildCollapsibleBidHistory(auction, theme),

              // Shipping and Return Policy
              _buildShippingSection(auction, theme),

              const SizedBox(height: 100),
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

  // =============== NEW SIMPLIFIED COMPONENTS ===============

  Widget _buildCompactPricingSection(AuctionModel auction, ThemeData theme) {
    final isEndingSoon = auction.isLive && auction.timeRemaining.inMinutes < 60;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEndingSoon
              ? Colors.red.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Price and Timer Row
          Row(
            children: [
              // Current Bid
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Bid',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '\$${auction.currentPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
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
              // Timer
              if (auction.isLive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isEndingSoon
                        ? Colors.red.withValues(alpha: 0.1)
                        : theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: isEndingSoon
                            ? Colors.red
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        auction.timeRemainingText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isEndingSoon
                              ? Colors.red
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuctionModel auction, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Watch Button
          ElevatedButton.icon(
            onPressed: () => _toggleWatchList(auction),
            icon: Icon(
              auction.isWatched
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              size: 20,
            ),
            label: Text(auction.isWatched ? 'Watching' : 'Watch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: auction.isWatched
                  ? Colors.red.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest,
              foregroundColor:
                  auction.isWatched ? Colors.red : theme.colorScheme.onSurface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineBidInput(AuctionModel auction, ThemeData theme) {
    final biddingState = ref.watch(biddingProvider(auction.id.toString()));

    // Set default bid amount if controller is empty
    if (_bidController.text.isEmpty) {
      _bidController.text =
          (auction.minimumBid ?? auction.currentPrice + 1).toStringAsFixed(2);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Place Your Bid',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Bid Input
              Expanded(
                child: TextField(
                  controller: _bidController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    hintText: 'Enter amount',
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Place Bid Button
              ElevatedButton(
                onPressed:
                    biddingState.isPlacingBid ? null : () => _placeBid(auction),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: biddingState.isPlacingBid
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Bid',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Min bid: \$${(auction.minimumBid ?? auction.currentPrice + 1).toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          // Error Message
          if (biddingState.hasError) ...[
            const SizedBox(height: 8),
            Text(
              biddingState.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactDescription(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showDescription = !_showDescription),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.description_outlined,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Description',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _showDescription ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          if (_showDescription)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (auction.condition?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined,
                            size: 16, color: Colors.teal),
                        const SizedBox(width: 6),
                        Text(
                          'Condition: ${auction.condition}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleBidHistory(AuctionModel auction, ThemeData theme) {
    final biddingState = ref.watch(biddingProvider(auction.id.toString()));

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showBidHistory = !_showBidHistory),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.history,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bid History',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (biddingState.hasBids)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${biddingState.bids.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _showBidHistory ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          if (_showBidHistory && biddingState.hasBids)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children:
                    biddingState.bids.asMap().entries.take(10).map((entry) {
                  final index = entry.key;
                  final bid = entry.value;
                  final isWinner =
                      index == 0; // First bid is the highest/winner
                  final isLoser = index > 0; // All others are outbid

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? Colors.green.withValues(alpha: 0.1)
                          : isLoser
                              ? Colors.red.withValues(alpha: 0.05)
                              : null,
                      borderRadius: BorderRadius.circular(10),
                      border: isWinner
                          ? Border.all(
                              color: Colors.green.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Winner/Loser Icon
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isWinner
                                ? Colors.green
                                : Colors.red.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWinner
                                ? Icons.emoji_events_rounded
                                : Icons.arrow_downward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    bid.displayUsername,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isWinner
                                          ? Colors.green.shade700
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (isWinner)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'WINNING',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.red.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'OUTBID',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                bid.timeAgo,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          bid.formattedAmount,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isWinner ? Colors.green : Colors.red.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_showBidHistory && !biddingState.hasBids)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'No bids yet. Be the first!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Buy Now Button Section (separate from action buttons)
  Widget _buildBuyNowButton(AuctionModel auction, ThemeData theme) {
    final biddingState = ref.watch(biddingProvider(auction.id.toString()));

    // Calculate buy now price if not set (20% above current price, minimum $10 above)
    final buyNowPrice = auction.buyNowPrice ??
        (auction.currentPrice +
            (auction.currentPrice * 0.2).clamp(10.0, double.infinity));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: biddingState.isBuyingNow
              ? null
              : () => _handleBuyNow(auction, buyNowPrice),
          icon: biddingState.isBuyingNow
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.flash_on_rounded, size: 26),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                biddingState.isBuyingNow
                    ? 'Processing Purchase...'
                    : 'Buy It Now',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              if (!biddingState.isBuyingNow)
                Text(
                  '\$${buyNowPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Future<void> _placeBid(AuctionModel auction) async {
    final bidAmount = double.tryParse(_bidController.text);
    if (bidAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid bid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final minBid = auction.minimumBid ?? auction.currentPrice + 1;
    if (bidAmount < minBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid must be at least \$${minBid.toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref
        .read(biddingProvider(auction.id.toString()).notifier)
        .placeBid(bidAmount);

    if (!mounted) return;

    if (success) {
      // Refresh auction details
      await ref
          .read(auctionDetailProvider(auction.id.toString()).notifier)
          .refresh();

      if (!mounted) return;

      // Update bid input with new minimum
      final updatedAuction =
          ref.read(auctionDetailProvider(auction.id.toString())).auction;
      if (updatedAuction != null) {
        _bidController.text =
            (updatedAuction.minimumBid ?? updatedAuction.currentPrice + 1)
                .toStringAsFixed(2);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid placed: \$${bidAmount.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleBuyNow(AuctionModel auction, double buyNowPrice) async {
    final theme = Theme.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to buy this item for \$${buyNowPrice.toStringAsFixed(2)}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.flash_on, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'This will immediately end the auction',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Purchase'),
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

  Future<void> _toggleWatchList(AuctionModel auction) async {
    final success = await ref
        .read(auctionDetailProvider(widget.auctionId).notifier)
        .toggleWatchList();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? auction.isWatched
                    ? 'Removed from Watch List'
                    : 'Added to Watch List'
                : 'Failed to update Watch List',
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

  // =============== NEW REDESIGNED SECTIONS ===============

  Widget _buildTitleSection(AuctionModel auction, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            auction.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                auction.categoryName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${auction.viewCount} views',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPricingSection(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Bid',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${auction.currentPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${auction.bidCount} bids',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (auction.isLive) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeRemaining(auction.timeRemaining),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'remaining',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (auction.hasReserve) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: auction.reserveMet
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    auction.reserveMet ? Icons.check_circle : Icons.info,
                    size: 16,
                    color: auction.reserveMet
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    auction.reserveMet ? 'Reserve Met' : 'Reserve Not Met',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: auction.reserveMet
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
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

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }

  Widget _buildConditionSection(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Condition',
                  auction.condition ?? 'Not specified',
                  Icons.info_outline,
                  theme,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Watchers',
                  '${auction.watchCount}',
                  Icons.favorite_outline,
                  theme,
                ),
              ),
            ],
          ),
          if (auction.location != null) ...[
            const SizedBox(height: 12),
            _buildDetailItem(
              'Location',
              auction.location!,
              Icons.location_on_outlined,
              theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSellerSection(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              auction.sellerUsername.isNotEmpty
                  ? auction.sellerUsername[0].toUpperCase()
                  : 'S',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      auction.sellerUsername,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (auction.sellerVerified == true) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                if (auction.sellerRating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (auction.sellerRating ?? 0).floor()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '(${auction.sellerRating?.toStringAsFixed(1)})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to seller profile
            },
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildBiddingSection(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Place Your Bid',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bidController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Bid Amount',
                    prefixText: '\$',
                    hintText: 'Enter your bid',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bid amount';
                    }
                    final bidAmount = double.tryParse(value);
                    if (bidAmount == null) {
                      return 'Please enter a valid amount';
                    }
                    if (bidAmount <= auction.currentPrice) {
                      return 'Bid must be higher than current price';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _placeBid(auction),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Place Bid'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum bid: \$${(auction.currentPrice + 1).toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDescriptionSection(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text(
              auction.description.isNotEmpty
                  ? auction.description
                  : 'No description provided.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildBidHistorySection(AuctionModel auction, ThemeData theme) {
    final biddingState = ref.watch(biddingProvider(auction.id.toString()));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              'Bid History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${biddingState.bids.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          if (biddingState.bids.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No bids yet. Be the first to bid!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: biddingState.bids.length,
              itemBuilder: (context, index) {
                final bid = biddingState.bids[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      bid.username.isNotEmpty
                          ? bid.username[0].toUpperCase()
                          : 'B',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    bid.displayUsername,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _formatDateTime(bid.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Text(
                    '\$${bid.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildShippingSection(AuctionModel auction, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping & Returns',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (auction.shippingCost != null) ...[
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Shipping: \$${auction.shippingCost!.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (auction.shippingInfo != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    auction.shippingInfo!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact seller for shipping details',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
