import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../data/models/auction_model.dart';
import '../providers/my_auctions_provider.dart';
import '../widgets/auction_card.dart';

class MyAuctionsScreen extends ConsumerStatefulWidget {
  const MyAuctionsScreen({super.key});

  @override
  ConsumerState<MyAuctionsScreen> createState() => _MyAuctionsScreenState();
}

class _MyAuctionsScreenState extends ConsumerState<MyAuctionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myAuctionsProvider.notifier).loadAuctions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myAuctionsProvider.notifier).loadMoreAuctions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auctionsState = ref.watch(myAuctionsProvider);

    return LoadingOverlay(
      isLoading: auctionsState.isLoading && auctionsState.auctions.isEmpty,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Auctions'),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          actions: [
            IconButton(
              onPressed: () => context.pushNamed('create-auction'),
              icon: const Icon(Icons.add),
              tooltip: 'Create Auction',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Ended'),
              Tab(text: 'Sold'),
              Tab(text: 'Drafts'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAuctionsList('active'),
            _buildAuctionsList('ended'),
            _buildAuctionsList('sold'),
            _buildAuctionsList('draft'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed('create-auction'),
          child: const Icon(Icons.add),
          tooltip: 'Create Auction',
        ),
      ),
    );
  }

  Widget _buildAuctionsList(String status) {
    final auctionsState = ref.watch(myAuctionsProvider);
    final filteredAuctions = _filterAuctionsByStatus(auctionsState.auctions, status);

    if (auctionsState.hasError && auctionsState.auctions.isEmpty) {
      return _buildErrorState(auctionsState.error!);
    }

    if (filteredAuctions.isEmpty && !auctionsState.isLoading) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(myAuctionsProvider.notifier).refreshAuctions();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredAuctions.length + (auctionsState.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredAuctions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final auction = filteredAuctions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AuctionCard(
              auction: auction,
              onTap: () => _viewAuctionDetails(auction),
              showActions: true,
              onEdit: () => _editAuction(auction),
              onDelete: () => _deleteAuction(auction),
              onEndEarly: auction.isActive ? () => _endAuctionEarly(auction) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    final theme = Theme.of(context);
    
    String title;
    String subtitle;
    IconData icon;
    
    switch (status) {
      case 'active':
        title = 'No Active Auctions';
        subtitle = 'You don\'t have any active auctions at the moment.';
        icon = Icons.gavel;
        break;
      case 'ended':
        title = 'No Ended Auctions';
        subtitle = 'Your ended auctions will appear here.';
        icon = Icons.schedule;
        break;
      case 'sold':
        title = 'No Sold Items';
        subtitle = 'Your sold auctions will appear here.';
        icon = Icons.sold;
        break;
      case 'draft':
        title = 'No Draft Auctions';
        subtitle = 'Your draft auctions will appear here.';
        icon = Icons.draft;
        break;
      default:
        title = 'No Auctions';
        subtitle = 'No auctions found.';
        icon = Icons.inbox;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Your First Auction',
            onPressed: () => context.pushNamed('create-auction'),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Auctions',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Try Again',
            onPressed: () => ref.read(myAuctionsProvider.notifier).refreshAuctions(),
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  List<AuctionModel> _filterAuctionsByStatus(List<AuctionModel> auctions, String status) {
    switch (status) {
      case 'active':
        return auctions.where((auction) => auction.isActive).toList();
      case 'ended':
        return auctions.where((auction) => auction.hasEnded && !auction.hasSold).toList();
      case 'sold':
        return auctions.where((auction) => auction.hasSold).toList();
      case 'draft':
        return auctions.where((auction) => auction.status == 'draft').toList();
      default:
        return auctions;
    }
  }

  void _viewAuctionDetails(AuctionModel auction) {
    context.pushNamed('auction-detail', pathParameters: {'id': auction.id.toString()});
  }

  void _editAuction(AuctionModel auction) {
    // TODO: Navigate to edit auction screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit auction coming soon!')),
    );
  }

  Future<void> _deleteAuction(AuctionModel auction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Auction'),
        content: Text('Are you sure you want to delete "${auction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(myAuctionsProvider.notifier)
          .deleteAuction(auction.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _endAuctionEarly(AuctionModel auction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Auction Early'),
        content: Text('Are you sure you want to end "${auction.title}" early?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Auction'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(myAuctionsProvider.notifier)
          .endAuctionEarly(auction.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auction ended successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
