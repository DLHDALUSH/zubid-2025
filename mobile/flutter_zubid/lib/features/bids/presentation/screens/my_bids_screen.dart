import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class MyBidsScreen extends ConsumerStatefulWidget {
  const MyBidsScreen({super.key});

  @override
  ConsumerState<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends ConsumerState<MyBidsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Bids',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Won'),
            Tab(text: 'Lost'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBidsTab(BidStatus.active),
          _buildBidsTab(BidStatus.won),
          _buildBidsTab(BidStatus.lost),
        ],
      ),
    );
  }

  Widget _buildBidsTab(BidStatus status) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh bids logic would go here
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Placeholder for now - would be replaced with actual bid data
          _buildEmptyState(status),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BidStatus status) {
    final theme = Theme.of(context);
    
    String title;
    String subtitle;
    IconData icon;
    
    switch (status) {
      case BidStatus.active:
        title = 'No Active Bids';
        subtitle = 'You don\'t have any active bids right now';
        icon = Icons.gavel_outlined;
        break;
      case BidStatus.won:
        title = 'No Won Auctions';
        subtitle = 'You haven\'t won any auctions yet';
        icon = Icons.emoji_events_outlined;
        break;
      case BidStatus.lost:
        title = 'No Lost Bids';
        subtitle = 'You don\'t have any lost bids';
        icon = Icons.close_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            if (status == BidStatus.active) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/auctions'),
                child: const Text('Browse Auctions'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum BidStatus {
  active,
  won,
  lost,
}
