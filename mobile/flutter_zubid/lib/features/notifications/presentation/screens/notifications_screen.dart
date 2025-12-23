import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // Mark all as read
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh notifications logic
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Placeholder notifications - would be replaced with actual data
            _buildNotificationItem(
              icon: Icons.gavel,
              title: 'Auction Ending Soon',
              subtitle: 'iPhone 13 Pro auction ends in 2 hours',
              time: '2h ago',
              isRead: false,
            ),
            _buildNotificationItem(
              icon: Icons.emoji_events,
              title: 'Congratulations!',
              subtitle: 'You won the MacBook Pro auction',
              time: '1d ago',
              isRead: true,
            ),
            _buildNotificationItem(
              icon: Icons.trending_up,
              title: 'Outbid Alert',
              subtitle: 'Someone outbid you on Samsung Galaxy S23',
              time: '2d ago',
              isRead: true,
            ),
            _buildNotificationItem(
              icon: Icons.payment,
              title: 'Payment Successful',
              subtitle: 'Your payment for iPad Air has been processed',
              time: '3d ago',
              isRead: true,
            ),
            _buildNotificationItem(
              icon: Icons.local_shipping,
              title: 'Item Shipped',
              subtitle: 'Your MacBook Pro has been shipped',
              time: '5d ago',
              isRead: true,
            ),
            
            // Empty state when no notifications
            if (false) // This would be based on actual notification count
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isRead 
                ? theme.colorScheme.surfaceVariant
                : theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isRead 
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! Check back later for updates.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
