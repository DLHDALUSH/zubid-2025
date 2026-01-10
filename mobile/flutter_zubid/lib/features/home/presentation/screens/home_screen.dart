import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auctions/presentation/providers/auction_provider.dart';
import '../../../auctions/presentation/widgets/auction_card.dart';
import '../../../banners/presentation/widgets/banner_carousel.dart';
import '../../../banners/presentation/providers/banner_provider.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load auctions and banners when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(auctionProvider.notifier).loadAuctions(refresh: true);
      ref.read(bannerProvider.notifier).loadBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auctionState = ref.watch(auctionProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ZUBID Auctions',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/auctions'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(auctionProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Welcome Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to ZUBID',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'بازاڕی بکە بەو نرخەی خۆت بە دڵتە',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/auctions'),
                            icon: const Icon(Icons.gavel),
                            label: const Text('Browse Auctions'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/watchlist'),
                            icon: const Icon(Icons.favorite_outline),
                            label: const Text('My Watchlist'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Banner Carousel
            const SliverToBoxAdapter(
              child: BannerCarousel(),
            ),

            // Featured Auctions Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Auctions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/auctions'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Auctions List
            if (auctionState.isLoading && auctionState.auctions.isEmpty)
              const SliverToBoxAdapter(
                child: LoadingWidget(),
              )
            else if (auctionState.error != null &&
                auctionState.auctions.isEmpty)
              SliverToBoxAdapter(
                child: custom.CustomErrorWidget(
                  message: auctionState.error!,
                  onRetry: () => ref.read(auctionProvider.notifier).refresh(),
                ),
              )
            else if (auctionState.auctions.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.gavel_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No auctions available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to create an auction!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final auction = auctionState.auctions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AuctionCard(
                          auction: auction,
                          onTap: () =>
                              context.push('/auctions/detail/${auction.id}'),
                        ),
                      );
                    },
                    childCount: auctionState.auctions.length > 5
                        ? 5
                        : auctionState.auctions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
