import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          if (notificationState.hasUnread)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: () => _markAllAsRead(),
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
        child: _buildContent(theme, notificationState),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, NotificationState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return _buildErrorState(theme, state.error!);
    }

    if (!state.hasNotifications) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.notifications.length,
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
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
              'Failed to load notifications',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(notificationProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final success =
        await ref.read(notificationProvider.notifier).markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'All notifications marked as read'
                : 'Failed to mark as read',
          ),
        ),
      );
    }
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final theme = Theme.of(context);
    final icon = _getIconForType(notification.type);
    final timeAgo = timeago.format(notification.createdAt);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: notification.isRead
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'outbid':
        return Icons.trending_up;
      case 'won':
        return Icons.emoji_events;
      case 'ending':
        return Icons.timer;
      case 'payment':
        return Icons.payment;
      case 'shipping':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    // Mark as read
    if (!notification.isRead) {
      await ref.read(notificationProvider.notifier).markAsRead(notification.id);
    }

    // Navigate to auction if applicable
    if (notification.auctionId != null && mounted) {
      // You can add navigation to auction detail here
      // context.push('/auction/${notification.auctionId}');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    final success = await ref
        .read(notificationProvider.notifier)
        .deleteNotification(notificationId);

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete notification')),
      );
      // Refresh to restore the notification
      ref.read(notificationProvider.notifier).refresh();
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Notifications',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up! Check back later for updates.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
