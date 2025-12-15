import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auction_card.dart';
import '../auction/auction_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auctionProvider = context.read<AuctionProvider>();
      auctionProvider.loadCategories();
      auctionProvider.loadAuctions();
      auctionProvider.loadWishlist();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredAuctions(AuctionProvider provider) {
    var auctions = provider.auctions;

    // Filter by category
    if (provider.selectedCategoryId != null) {
      auctions = auctions.where((a) => a.categoryId == provider.selectedCategoryId).toList();
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      auctions = auctions.where((a) =>
        a.title.toLowerCase().contains(query) ||
        a.description.toLowerCase().contains(query)
      ).toList();
    }

    return auctions;
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = context.watch<AuctionProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredAuctions = _getFilteredAuctions(auctionProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await auctionProvider.loadCategories();
          await auctionProvider.loadAuctions();
          await auctionProvider.loadWishlist();
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: _isSearching,
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search auctions...',
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    )
                  : ShaderMask(
                      shaderCallback: (bounds) => (isDark
                          ? AppColors.primaryGradientDark
                          : AppColors.primaryGradient).createShader(bounds),
                      child: const Text(
                        'ZUBID',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) _searchController.clear();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),

            // Banner
            if (!_isSearching)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.primaryGradientDark : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('EVERYTHING', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('AVAILABLE', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),

            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: auctionProvider.categories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll ? null : auctionProvider.categories[index - 1];
                    final isSelected = isAll
                        ? auctionProvider.selectedCategoryId == null
                        : auctionProvider.selectedCategoryId == category?.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(isAll ? 'All' : category!.name),
                        selected: isSelected,
                        selectedColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          auctionProvider.selectCategory(isAll ? null : category?.id);
                          setState(() {}); // Trigger rebuild for filtering
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      auctionProvider.selectedCategoryId != null
                          ? auctionProvider.categories
                              .firstWhere((c) => c.id == auctionProvider.selectedCategoryId,
                                orElse: () => auctionProvider.categories.first)
                              .name
                          : 'Live Auctions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${filteredAuctions.length} items',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // Error Display
            if (auctionProvider.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Connection Error',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          auctionProvider.error ?? 'Failed to load auctions',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          auctionProvider.loadAuctions();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            // Auctions Grid
            else if (auctionProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredAuctions.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'No auctions match your search'
                            : 'No auctions in this category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          auctionProvider.selectCategory(null);
                          setState(() => _isSearching = false);
                        },
                        child: const Text('Clear filters'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final auction = filteredAuctions[index];
                      return AuctionCard(
                        auction: auction,
                        isInWishlist: auctionProvider.isInWishlist(auction.id),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AuctionDetailScreen(auctionId: auction.id)),
                        ),
                        onWishlistTap: authProvider.isLoggedIn
                            ? () async {
                                final success = await auctionProvider.toggleWishlist(auction.id);
                                if (success && mounted && context.mounted) {
                                  final isNowInWishlist = auctionProvider.isInWishlist(auction.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isNowInWishlist ? 'Added to wishlist' : 'Removed from wishlist'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              }
                            : () => Navigator.pushNamed(context, '/login'),
                      );
                    },
                    childCount: filteredAuctions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

