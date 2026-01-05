import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import '../providers/auction_provider.dart';
import '../widgets/auction_card.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    // Load Watchlist when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: Load Watchlist from provider
      // ref.read(watchlistProvider.notifier).loadWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: Replace with actual Watchlist provider
    final auctionState = ref.watch(auctionProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Watchlist',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/auctions'),
            tooltip: 'Search Auctions',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh Watchlist
          await ref.read(auctionProvider.notifier).refresh();
        },
        child: auctionState.isLoading && auctionState.auctions.isEmpty
            ? const LoadingWidget()
            : auctionState.error != null && auctionState.auctions.isEmpty
                ? custom.CustomErrorWidget(
                    message: auctionState.error!,
                    onRetry: () => ref.read(auctionProvider.notifier).refresh(),
                  )
                : auctionState.auctions.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: auctionState.auctions.length,
                        itemBuilder: (context, index) {
                          final auction = auctionState.auctions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AuctionCard(
                              auction: auction,
                              onTap: () => context
                                  .push('/auctions/detail/${auction.id}'),
                              onWatchlistToggle: () =>
                                  _toggleWatchlist(auction),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No items in Watchlist',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add auctions to your Watchlist to see them here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/auctions'),
            icon: const Icon(Icons.search),
            label: const Text('Browse Auctions'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleWatchlist(dynamic auction) async {
    final success =
        await ref.read(auctionProvider.notifier).toggleWatchList(auction);

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
}
