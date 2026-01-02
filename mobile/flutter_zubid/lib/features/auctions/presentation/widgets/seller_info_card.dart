import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SellerInfoCard extends StatelessWidget {
  final SellerInfo seller;

  const SellerInfoCard({
    super.key,
    required this.seller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Seller Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Seller Details
            Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: seller.hasAvatar
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: seller.avatar!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Icon(
                              Icons.person,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 30,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Seller Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username and Verification
                      Row(
                        children: [
                          Text(
                            seller.username,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (seller.isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Rating
                      if (seller.rating != null)
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < seller.rating!.floor()
                                    ? Icons.star
                                    : index < seller.rating!
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${seller.rating!.toStringAsFixed(1)} (${seller.reviewCount} reviews)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // Member Since
                      Text(
                        'Member since ${_formatMemberSince(seller.memberSince)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats
            Row(
              children: [
                _buildStatItem(
                  theme,
                  'Active Auctions',
                  seller.activeAuctions.toString(),
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  theme,
                  'Total Sales',
                  seller.totalSales.toString(),
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  theme,
                  'Success Rate',
                  '${seller.successRate.toStringAsFixed(0)}%',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewSellerProfile(),
                    icon: const Icon(Icons.person),
                    label: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactSeller(),
                    icon: const Icon(Icons.message),
                    label: const Text('Contact'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  void _viewSellerProfile() {
    // TODO: Navigate to seller profile
  }

  void _contactSeller() {
    // TODO: Open contact seller dialog
  }
}

// Seller Info Model (should be part of AuctionModel)
class SellerInfo {
  final int id;
  final String username;
  final String? avatar;
  final bool isVerified;
  final double? rating;
  final int reviewCount;
  final DateTime memberSince;
  final int activeAuctions;
  final int totalSales;
  final double successRate;

  const SellerInfo({
    required this.id,
    required this.username,
    this.avatar,
    this.isVerified = false,
    this.rating,
    this.reviewCount = 0,
    required this.memberSince,
    this.activeAuctions = 0,
    this.totalSales = 0,
    this.successRate = 0.0,
  });

  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
}
