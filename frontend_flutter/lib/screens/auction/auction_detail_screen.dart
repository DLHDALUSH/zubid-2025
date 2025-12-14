import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/auction.dart';
import '../../models/bid.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../chat/chat_screen.dart';

class AuctionDetailScreen extends StatefulWidget {
  final int auctionId;

  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  Auction? _auction;
  List<Bid> _bids = [];
  bool _isLoading = true;
  bool _isBidding = false;
  final _bidController = TextEditingController();
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadAuction();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_auction != null && mounted) {
        setState(() {
          _timeRemaining = _auction!.timeRemaining;
        });
      }
    });
  }

  Future<void> _loadAuction() async {
    setState(() => _isLoading = true);
    final provider = context.read<AuctionProvider>();
    final auction = await provider.getAuction(widget.auctionId);
    final bids = await provider.getAuctionBids(widget.auctionId);
    if (mounted) {
      setState(() {
        _auction = auction;
        _bids = bids;
        _timeRemaining = auction?.timeRemaining ?? Duration.zero;
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration d) {
    if (d.isNegative || d == Duration.zero) return 'Ended';
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  Future<void> _placeBid() async {
    final amount = double.tryParse(_bidController.text);
    if (amount == null || _auction == null) return;

    if (amount <= _auction!.currentBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid must be higher than current bid')),
      );
      return;
    }

    setState(() => _isBidding = true);
    final success = await context.read<AuctionProvider>().placeBid(widget.auctionId, amount);
    setState(() => _isBidding = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid placed successfully! 🎉'), backgroundColor: AppColors.success),
      );
      _bidController.clear();
      await _loadAuction(); // Refresh auction and bids
    }
  }

  Future<void> _buyNow() async {
    if (_auction?.buyNowPrice == null) return;
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buy Now'),
        content: Text('Buy this item for \$${_auction!.buyNowPrice!.toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed == true) {
      // Place bid at buy now price
      final success = await context.read<AuctionProvider>().placeBid(widget.auctionId, _auction!.buyNowPrice!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item purchased! 🎉'), backgroundColor: AppColors.success),
        );
        await _loadAuction();
      }
    }
  }

  void _contactSeller() {
    if (_auction == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          sellerId: _auction!.sellerId,
          sellerName: _auction!.sellerName ?? 'Seller',
          auctionId: _auction!.id,
          auctionTitle: _auction!.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final auctionProvider = context.watch<AuctionProvider>();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _auction == null
              ? const Center(child: Text('Auction not found'))
              : RefreshIndicator(
                  onRefresh: _loadAuction,
                  child: CustomScrollView(
                    slivers: [
                      // Image Gallery App Bar
                      SliverAppBar(
                        expandedHeight: 300,
                        pinned: true,
                        actions: [
                          IconButton(
                            icon: Icon(
                              auctionProvider.isInWishlist(_auction!.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: auctionProvider.isInWishlist(_auction!.id)
                                  ? Colors.red
                                  : Colors.white,
                            ),
                            onPressed: authProvider.isLoggedIn
                                ? () => auctionProvider.toggleWishlist(_auction!.id)
                                : () => Navigator.pushNamed(context, '/login'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {},
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildImageGallery(),
                        ),
                      ),

                      // Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Category
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(_auction!.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                  if (_auction!.categoryName != null)
                                    Chip(
                                      label: Text(_auction!.categoryName!, style: const TextStyle(fontSize: 12)),
                                      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Timer Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _timeRemaining.inMinutes < 5 ? Colors.red : Colors.transparent, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer, color: _timeRemaining.inMinutes < 5 ? Colors.red : AppColors.primary),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Time Remaining', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        Text(
                                          _formatDuration(_timeRemaining),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: _timeRemaining.inMinutes < 5 ? Colors.red : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(_auction!.hasEnded ? 'ENDED' : 'LIVE',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _auction!.hasEnded ? Colors.grey : Colors.green,
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Price Info Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: isDark ? AppColors.primaryGradientDark : AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Current Bid', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                            Text('\$${_auction!.currentBid.toStringAsFixed(2)}',
                                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('Starting Price', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                            Text('\$${_auction!.startingPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(color: Colors.white70, fontSize: 16)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (_auction!.buyNowPrice != null) ...[
                                      const SizedBox(height: 12),
                                      const Divider(color: Colors.white30),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Buy Now Price', style: TextStyle(color: Colors.white70)),
                                          Text('\$${_auction!.buyNowPrice!.toStringAsFixed(2)}',
                                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Buy Now Button (prominent placement)
                              if (_auction!.buyNowPrice != null && !_auction!.hasEnded && authProvider.isLoggedIn) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _buyNow,
                                    icon: const Icon(Icons.shopping_cart),
                                    label: Text('Buy Now for \$${_auction!.buyNowPrice!.toStringAsFixed(2)}'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),

                              // Seller Info & Contact
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        (_auction!.sellerName ?? 'S')[0].toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Seller', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                          Text(_auction!.sellerName ?? 'ZUBID Admin', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    if (authProvider.isLoggedIn)
                                      ElevatedButton.icon(
                                        onPressed: _contactSeller,
                                        icon: const Icon(Icons.message, size: 18),
                                        label: const Text('Message'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Description
                              Text('Description', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 8),
                              Text(_auction!.description, style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 24),

                              // Bid History
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Bid History (${_bids.length})', style: Theme.of(context).textTheme.titleLarge),
                                  TextButton(
                                    onPressed: _loadAuction,
                                    child: const Text('Refresh'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildBidHistory(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

      // Bottom Bid Bar
      bottomNavigationBar: _auction != null && !_auction!.hasEnded
          ? Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: authProvider.isLoggedIn
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bidController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Min: \$${(_auction!.currentBid + 1).toStringAsFixed(0)}',
                              prefixText: '\$ ',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: isDark ? AppColors.primaryGradientDark : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _isBidding ? null : _placeBid,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            child: _isBidding
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Place Bid', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Login to Bid'),
                    ),
            )
          : null,
    );
  }

  Widget _buildImageGallery() {
    final images = _auction!.images.isNotEmpty
        ? _auction!.images
        : (_auction!.imageUrl != null ? [_auction!.imageUrl!] : <String>[]);
    final hasVideo = _auction!.videoUrl != null && _auction!.videoUrl!.isNotEmpty;
    final totalItems = images.length + (hasVideo ? 1 : 0);

    if (images.isEmpty && !hasVideo) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: totalItems,
          onPageChanged: (i) => setState(() => _currentImageIndex = i),
          itemBuilder: (_, i) {
            // Show video as last item
            if (hasVideo && i == images.length) {
              return _buildVideoThumbnail();
            }
            return CachedNetworkImage(
              imageUrl: images[i],
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Center(child: Icon(Icons.error)),
            );
          },
        ),
        if (totalItems > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalItems, (i) {
                final isVideo = hasVideo && i == images.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == i ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == i ? AppColors.primary : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isVideo ? const Icon(Icons.videocam, size: 6, color: Colors.white) : null,
                );
              }),
            ),
          ),
        // Video indicator badge
        if (hasVideo)
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Video', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoThumbnail() {
    return GestureDetector(
      onTap: () => _playVideo(),
      child: Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
              SizedBox(height: 16),
              Text('Tap to play video', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _playVideo() {
    if (_auction?.videoUrl == null) return;
    // Show video in a dialog or navigate to video player
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Video URL: ${_auction!.videoUrl}'),
            const SizedBox(height: 8),
            const Text('Video playback requires video_player package', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildBidHistory() {
    if (_bids.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No bids yet. Be the first!')),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _bids.length > 10 ? 10 : _bids.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final bid = _bids[i];
          final isHighest = i == 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isHighest ? AppColors.primary : Colors.grey,
              child: Text(
                (bid.username ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Text(bid.username ?? 'User ${bid.userId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isHighest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Highest', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ],
            ),
            subtitle: Text(_formatBidTime(bid.createdAt)),
            trailing: Text(
              '\$${bid.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isHighest ? AppColors.primary : null,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatBidTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

