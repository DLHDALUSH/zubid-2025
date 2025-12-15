import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auction_card.dart';
import '../auction/auction_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWishlist();
    });
  }

  Future<void> _loadWishlist() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    setState(() => _isLoading = true);
    await context.read<AuctionProvider>().loadWishlist();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = context.watch<AuctionProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          if (auctionProvider.wishlist.isNotEmpty)
            TextButton(
              onPressed: () {},
              child: Text('${auctionProvider.wishlist.length} items'),
            ),
        ],
      ),
      body: !authProvider.isLoggedIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Login to view your wishlist', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadWishlist,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : auctionProvider.wishlist.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text('Your wishlist is empty', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Text('Tap the ❤️ on any auction to save it here!', style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: auctionProvider.wishlist.length,
                          itemBuilder: (context, index) {
                            final auction = auctionProvider.wishlist[index];
                            return AuctionCard(
                              auction: auction,
                              isInWishlist: true,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AuctionDetailScreen(auctionId: auction.id)),
                                );
                                // Refresh wishlist when returning
                                _loadWishlist();
                              },
                              onWishlistTap: () async {
                                final success = await auctionProvider.toggleWishlist(auction.id);
                                if (success && mounted && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Removed from wishlist'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
            ),
    );
  }
}

