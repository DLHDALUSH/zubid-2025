import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';

class ProfileStats extends StatelessWidget {
  final ProfileModel profile;

  const ProfileStats({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Stats',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.gavel,
                    label: 'Total Bids',
                    value: profile.totalBids.toString(),
                    color: theme.colorScheme.primary,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.emoji_events,
                    label: 'Wins',
                    value: profile.totalWins.toString(),
                    color: Colors.amber,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.attach_money,
                    label: 'Total Spent',
                    value: '\$${profile.totalSpent.toStringAsFixed(0)}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Rating
            if (profile.rating != null)
              _buildRatingSection(context),
            
            // Win Rate
            if (profile.totalBids > 0)
              _buildWinRateSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final theme = Theme.of(context);
    final rating = profile.rating!;

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 12),
        
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Rating',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${rating.toStringAsFixed(1)}/5.0',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Rating Stars
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return Icon(
              starValue <= rating
                  ? Icons.star
                  : starValue - 0.5 <= rating
                      ? Icons.star_half
                      : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWinRateSection(BuildContext context) {
    final theme = Theme.of(context);
    final winRate = (profile.totalWins / profile.totalBids * 100);

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Win Rate',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${winRate.toStringAsFixed(1)}%',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Win Rate Progress Bar
        LinearProgressIndicator(
          value: winRate / 100,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            winRate >= 50 
                ? Colors.green 
                : winRate >= 25 
                    ? Colors.orange 
                    : Colors.red,
          ),
        ),
      ],
    );
  }
}
