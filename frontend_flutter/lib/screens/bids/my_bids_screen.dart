import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auction_provider.dart';
import '../../theme/app_theme.dart';
import '../auction/auction_detail_screen.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionProvider>().loadMyBids();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = context.watch<AuctionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids'),
      ),
      body: RefreshIndicator(
        onRefresh: () => auctionProvider.loadMyBids(),
        child: auctionProvider.myBids.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gavel, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No bids yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Start bidding on auctions!', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: auctionProvider.myBids.length,
                itemBuilder: (context, index) {
                  final bid = auctionProvider.myBids[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: bid.auctionImage != null
                            ? CachedNetworkImage(
                                imageUrl: bid.auctionImage!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image),
                              ),
                      ),
                      title: Text(
                        bid.auctionTitle ?? 'Auction #${bid.auctionId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Your bid: \$${bid.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bid.auctionStatus == 'active'
                              ? AppColors.success.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bid.auctionStatus?.toUpperCase() ?? 'UNKNOWN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: bid.auctionStatus == 'active' ? AppColors.success : Colors.grey,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AuctionDetailScreen(auctionId: bid.auctionId)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

