import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_provider.dart';
import '../../theme/app_theme.dart';
import 'add_auction_screen.dart';

class ManageAuctionsScreen extends StatefulWidget {
  const ManageAuctionsScreen({super.key});

  @override
  State<ManageAuctionsScreen> createState() => _ManageAuctionsScreenState();
}

class _ManageAuctionsScreenState extends State<ManageAuctionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuctionProvider>().loadAuctions();
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = context.watch<AuctionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Auctions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAuctionScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Auction'),
        backgroundColor: AppColors.primary,
      ),
      body: auctionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: auctionProvider.auctions.length,
              itemBuilder: (context, index) {
                final auction = auctionProvider.auctions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: auction.imageUrl != null
                            ? DecorationImage(image: NetworkImage(auction.imageUrl!), fit: BoxFit.cover)
                            : null,
                        color: Colors.grey[300],
                      ),
                      child: auction.imageUrl == null ? const Icon(Icons.image) : null,
                    ),
                    title: Text(auction.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${auction.currentBid.toStringAsFixed(2)}'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: auction.hasEnded ? Colors.grey : Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            auction.hasEnded ? 'Ended' : 'Active',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddAuctionScreen(auction: auction)));
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, auction.id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteDialog(BuildContext context, int auctionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Auction'),
        content: const Text('Are you sure you want to delete this auction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auction deleted'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

