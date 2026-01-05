import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/category_model.dart';
import '../../data/models/auction_search_filters.dart';
import '../providers/auction_provider.dart';
import '../widgets/auction_card.dart';
import '../widgets/auction_list_item.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/sort_bottom_sheet.dart';

enum ViewMode { grid, list }

class AuctionListScreen extends ConsumerStatefulWidget {
  final int? categoryId;
  final String? initialSearch;

  const AuctionListScreen({
    super.key,
    this.categoryId,
    this.initialSearch,
  });

  @override
  ConsumerState<AuctionListScreen> createState() => _AuctionListScreenState();
}

class _AuctionListScreenState extends ConsumerState<AuctionListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  ViewMode _viewMode = ViewMode.grid;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch ?? '';
    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final notifier = ref.read(auctionProvider.notifier);

    // Load categories if not loaded
    if (!ref.read(auctionProvider).hasCategories) {
      notifier.loadCategories();
    }

    // Load auctions with initial filters
    AuctionSearchFilters? filters;
    if (widget.categoryId != null) {
      filters = AuctionSearchFilters(categoryId: widget.categoryId);
    }

    if (filters != null) {
      notifier.applyFilters(filters);
    } else if (widget.initialSearch != null &&
        widget.initialSearch!.isNotEmpty) {
      notifier.searchAuctions(widget.initialSearch!);
    } else {
      notifier.loadAuctions(refresh: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(auctionProvider.notifier).loadMoreAuctions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionState = ref.watch(auctionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // View mode toggle
          IconButton(
            icon: Icon(
              _viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view,
            ),
            onPressed: () {
              setState(() {
                _viewMode =
                    _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
              });
            },
          ),

          // Sort button
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),

          // Filter button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterOptions,
              ),
              if (auctionState.hasFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: auctionState.isLoading && !auctionState.hasAuctions,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBarWidget(
                controller: _searchController,
                onSearch: _handleSearch,
                onClear: _handleClearSearch,
                isLoading: _isSearching,
              ),
            ),

            // Filter Summary
            if (auctionState.hasFilters) _buildFilterSummary(),

            // Auction List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: _buildAuctionList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScreenTitle() {
    if (widget.categoryId != null) {
      final categories = ref.watch(categoriesProvider);
      final category = categories.firstWhere(
        (c) => c.id == widget.categoryId,
        orElse: () => CategoryModel(
          id: 0,
          name: 'Category',
          description: '',
          auctionCount: 0,
          isActive: true,
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return category.name;
    }
    return 'Auctions';
  }

  Widget _buildFilterSummary() {
    final auctionState = ref.watch(auctionProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${auctionState.currentFilters?.activeFilterCount ?? 0} filters applied',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _handleClearFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionList() {
    final auctionState = ref.watch(auctionProvider);

    if (auctionState.hasError && !auctionState.hasAuctions) {
      return _buildErrorState();
    }

    if (!auctionState.hasAuctions && !auctionState.isLoading) {
      return _buildEmptyState();
    }

    return _viewMode == ViewMode.grid ? _buildGridView() : _buildListView();
  }

  Widget _buildGridView() {
    final auctions = ref.watch(auctionsProvider);
    final auctionState = ref.watch(auctionProvider);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: auctions.length + (auctionState.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= auctions.length) {
          return const Card(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final auction = auctions[index];
        return AuctionCard(
          auction: auction,
          onTap: () => context.push('/auctions/detail/${auction.id}'),
          onWatchlistToggle: () => _toggleWatchlist(auction),
        );
      },
    );
  }

  Widget _buildListView() {
    final auctions = ref.watch(auctionsProvider);
    final auctionState = ref.watch(auctionProvider);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: auctions.length + (auctionState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= auctions.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final auction = auctions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AuctionListItem(
            auction: auction,
            onTap: () => context.push('/auctions/detail/${auction.id}'),
            onWatchlistToggle: () => _toggleWatchlist(auction),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    final error = ref.watch(auctionErrorProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Unknown error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final hasFilters = ref.watch(auctionProvider).hasFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No Auctions Found' : 'No Auctions Available',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Check back later for new auctions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleClearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      await ref.read(auctionProvider.notifier).searchAuctions(query);
      AppLogger.userAction('Search performed: $query');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _handleClearSearch() async {
    _searchController.clear();
    await ref.read(auctionProvider.notifier).loadAuctions(refresh: true);
  }

  Future<void> _handleRefresh() async {
    await ref.read(auctionProvider.notifier).refresh();
  }

  Future<void> _handleClearFilters() async {
    await ref.read(auctionProvider.notifier).clearFilters();
  }

  Future<void> _toggleWatchlist(dynamic auction) async {
    final success =
        await ref.read(auctionProvider.notifier).toggleWatchlist(auction);

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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SortBottomSheet(
        currentSortBy: ref.read(auctionProvider).currentFilters?.sortBy,
        currentSortOrder: ref.read(auctionProvider).currentFilters?.sortOrder,
        onSortChanged: (sortBy, sortOrder) {
          final currentFilters = ref.read(auctionProvider).currentFilters ??
              AuctionSearchFilters.empty;
          final newFilters = currentFilters.copyWith(
            sortBy: sortBy,
            sortOrder: sortOrder,
          );
          ref.read(auctionProvider.notifier).applyFilters(newFilters);
        },
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        currentFilters: ref.read(auctionProvider).currentFilters ??
            AuctionSearchFilters.empty,
        categories: ref.read(categoriesProvider),
        onFiltersChanged: (filters) {
          ref.read(auctionProvider.notifier).applyFilters(filters);
        },
      ),
    );
  }
}
