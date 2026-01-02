import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

// Notification State
class NotificationState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String? error;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.error,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }

  bool get hasUnread => unreadCount > 0;
  bool get hasNotifications => notifications.isNotEmpty;
}

// Notification Notifier with real-time polling
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 15);

  NotificationNotifier(this._repository) : super(const NotificationState()) {
    // Start polling when created
    loadNotifications();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _refreshUnreadCount();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getNotifications();

      result.when(
        success: (notifications) {
          final unread = notifications.where((n) => !n.isRead).length;
          state = state.copyWith(
            isLoading: false,
            notifications: notifications,
            unreadCount: unread,
          );
          AppLogger.info(
              'Loaded ${notifications.length} notifications, $unread unread');
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Failed to load notifications', error: error);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Notification loading exception', error: e);
    }
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final result = await _repository.getUnreadCount();

      result.when(
        success: (count) {
          if (count != state.unreadCount) {
            state = state.copyWith(unreadCount: count);
            // If new notifications, reload the full list
            if (count > state.unreadCount) {
              loadNotifications();
            }
          }
        },
        error: (error) {
          AppLogger.debug('Failed to refresh unread count: $error');
        },
      );
    } catch (e) {
      AppLogger.debug('Error refreshing unread count: $e');
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final result = await _repository.markAsRead(notificationId);

      return result.when(
        success: (_) {
          // Update local state
          final updated = state.notifications.map((n) {
            if (n.id == notificationId) {
              return n.copyWith(isRead: true);
            }
            return n;
          }).toList();

          final unread = updated.where((n) => !n.isRead).length;
          state = state.copyWith(notifications: updated, unreadCount: unread);
          return true;
        },
        error: (error) {
          AppLogger.error('Failed to mark as read', error: error);
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('Mark as read exception', error: e);
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final result = await _repository.markAllAsRead();

      return result.when(
        success: (_) {
          // Update local state
          final updated = state.notifications.map((n) {
            return n.copyWith(isRead: true);
          }).toList();

          state = state.copyWith(notifications: updated, unreadCount: 0);
          AppLogger.info('Marked all notifications as read');
          return true;
        },
        error: (error) {
          AppLogger.error('Failed to mark all as read', error: error);
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('Mark all as read exception', error: e);
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final result = await _repository.deleteNotification(notificationId);

      return result.when(
        success: (_) {
          // Remove from local state
          final updated =
              state.notifications.where((n) => n.id != notificationId).toList();
          final unread = updated.where((n) => !n.isRead).length;
          state = state.copyWith(notifications: updated, unreadCount: unread);
          return true;
        },
        error: (error) {
          AppLogger.error('Failed to delete notification', error: error);
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('Delete notification exception', error: e);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});

// Convenience providers
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).hasUnread;
});
