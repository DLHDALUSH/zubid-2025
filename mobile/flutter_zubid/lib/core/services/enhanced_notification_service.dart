import 'dart:async';
import 'dart:convert';

import '../utils/logger.dart';
import 'storage_service.dart';

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

enum NotificationCategory {
  auction,
  bid,
  message,
  system,
  reminder,
  promotion,
}

class NotificationTemplate {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final NotificationPriority priority;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final List<NotificationAction> actions;

  const NotificationTemplate({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.priority = NotificationPriority.normal,
    this.data = const {},
    this.imageUrl,
    this.actions = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category.name,
        'priority': priority.name,
        'data': data,
        'imageUrl': imageUrl,
        'actions': actions.map((a) => a.toJson()).toList(),
      };

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
      NotificationTemplate(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        category: NotificationCategory.values
            .firstWhere((e) => e.name == json['category']),
        priority: NotificationPriority.values
            .firstWhere((e) => e.name == json['priority']),
        data: json['data'] ?? {},
        imageUrl: json['imageUrl'],
        actions: (json['actions'] as List<dynamic>?)
                ?.map((a) => NotificationAction.fromJson(a))
                .toList() ??
            [],
      );
}

class NotificationAction {
  final String id;
  final String title;
  final String? icon;
  final bool requiresAuth;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.requiresAuth = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': icon,
        'requiresAuth': requiresAuth,
      };

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      NotificationAction(
        id: json['id'],
        title: json['title'],
        icon: json['icon'],
        requiresAuth: json['requiresAuth'] ?? false,
      );
}

class ScheduledNotification {
  final String id;
  final NotificationTemplate template;
  final DateTime scheduledTime;
  final bool recurring;
  final Duration? recurringInterval;

  const ScheduledNotification({
    required this.id,
    required this.template,
    required this.scheduledTime,
    this.recurring = false,
    this.recurringInterval,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'template': template.toJson(),
        'scheduledTime': scheduledTime.toIso8601String(),
        'recurring': recurring,
        'recurringInterval': recurringInterval?.inMilliseconds,
      };

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) =>
      ScheduledNotification(
        id: json['id'],
        template: NotificationTemplate.fromJson(json['template']),
        scheduledTime: DateTime.parse(json['scheduledTime']),
        recurring: json['recurring'] ?? false,
        recurringInterval: json['recurringInterval'] != null
            ? Duration(milliseconds: json['recurringInterval'])
            : null,
      );
}

class EnhancedNotificationService {
  static EnhancedNotificationService? _instance;
  static EnhancedNotificationService get instance =>
      _instance ??= EnhancedNotificationService._();

  EnhancedNotificationService._();

  static const String _scheduledNotificationsKey = 'scheduled_notifications';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _notificationHistoryKey = 'notification_history';

  final StreamController<NotificationTemplate> _notificationController =
      StreamController<NotificationTemplate>.broadcast();

  final List<ScheduledNotification> _scheduledNotifications = [];
  final List<NotificationTemplate> _notificationHistory = [];

  // Notification settings
  Map<NotificationCategory, bool> _categorySettings = {
    NotificationCategory.auction: true,
    NotificationCategory.bid: true,
    NotificationCategory.message: true,
    NotificationCategory.system: true,
    NotificationCategory.reminder: true,
    NotificationCategory.promotion: false,
  };

  // Public streams
  Stream<NotificationTemplate> get notificationStream =>
      _notificationController.stream;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing enhanced notification service...');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Load settings and scheduled notifications
      await _loadSettings();
      await _loadScheduledNotifications();
      await _loadNotificationHistory();

      AppLogger.info('Enhanced notification service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize enhanced notification service',
          error: e);
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
  }

  /// Show immediate notification
  Future<void> showNotification(NotificationTemplate template) async {
    try {
      // Check if category is enabled
      if (!(_categorySettings[template.category] ?? false)) {
        AppLogger.info(
            'Notification category ${template.category.name} is disabled');
        return;
      }

      // Create notification details
      final notificationDetails = await _createNotificationDetails(template);

      // Show notification (placeholder - in real implementation would use flutter_local_notifications)
      AppLogger.info('Showing notification: ${template.title}');
      AppLogger.info('Notification details: $notificationDetails');

      // Add to history
      _addToHistory(template);

      // Emit to stream
      _notificationController.add(template);

      AppLogger.userAction('Notification shown', parameters: {
        'id': template.id,
        'category': template.category.name,
        'priority': template.priority.name,
      });
    } catch (e) {
      AppLogger.error('Failed to show notification', error: e);
    }
  }

  /// Schedule notification for later
  Future<void> scheduleNotification(
      ScheduledNotification scheduledNotification) async {
    try {
      final template = scheduledNotification.template;

      // Check if category is enabled
      if (!(_categorySettings[template.category] ?? false)) {
        AppLogger.info(
            'Scheduled notification category ${template.category.name} is disabled');
        return;
      }

      // Create notification details
      final notificationDetails = await _createNotificationDetails(template);

      // Schedule notification (placeholder - in real implementation would use flutter_local_notifications)
      AppLogger.info(
          'Scheduling notification: ${template.title} for ${scheduledNotification.scheduledTime}');
      AppLogger.info('Notification details: $notificationDetails');

      // Add to scheduled list
      _scheduledNotifications.add(scheduledNotification);
      await _saveScheduledNotifications();

      AppLogger.userAction('Notification scheduled', parameters: {
        'id': template.id,
        'scheduledTime': scheduledNotification.scheduledTime.toIso8601String(),
        'category': template.category.name,
      });
    } catch (e) {
      AppLogger.error('Failed to schedule notification', error: e);
    }
  }

  /// Cancel scheduled notification
  Future<void> cancelScheduledNotification(String notificationId) async {
    try {
      // Cancel notification (placeholder - in real implementation would use flutter_local_notifications)
      AppLogger.info('Cancelling scheduled notification: $notificationId');

      _scheduledNotifications.removeWhere((n) => n.id == notificationId);
      await _saveScheduledNotifications();

      AppLogger.userAction('Scheduled notification cancelled', parameters: {
        'id': notificationId,
      });
    } catch (e) {
      AppLogger.error('Failed to cancel scheduled notification', error: e);
    }
  }

  /// Update notification category settings
  Future<void> updateCategorySettings(
      NotificationCategory category, bool enabled) async {
    try {
      _categorySettings[category] = enabled;
      await _saveSettings();

      AppLogger.userAction('Notification category setting updated',
          parameters: {
            'category': category.name,
            'enabled': enabled,
          });
    } catch (e) {
      AppLogger.error('Failed to update category settings', error: e);
    }
  }

  /// Get notification settings
  Map<NotificationCategory, bool> getNotificationSettings() {
    return Map.from(_categorySettings);
  }

  /// Get scheduled notifications
  List<ScheduledNotification> getScheduledNotifications() {
    return List.from(_scheduledNotifications);
  }

  /// Get notification history
  List<NotificationTemplate> getNotificationHistory() {
    return List.from(_notificationHistory);
  }

  /// Clear notification history
  Future<void> clearNotificationHistory() async {
    try {
      _notificationHistory.clear();
      await _saveNotificationHistory();
      AppLogger.info('Notification history cleared');
    } catch (e) {
      AppLogger.error('Failed to clear notification history', error: e);
    }
  }

  /// Create predefined notification templates
  static NotificationTemplate createAuctionEndingTemplate(
      String auctionTitle, String timeRemaining) {
    return NotificationTemplate(
      id: 'auction_ending_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Auction Ending Soon!',
      body: '$auctionTitle ends in $timeRemaining',
      category: NotificationCategory.auction,
      priority: NotificationPriority.high,
      actions: [
        const NotificationAction(
          id: 'view_auction',
          title: 'View Auction',
          icon: 'ic_visibility',
        ),
        const NotificationAction(
          id: 'place_bid',
          title: 'Place Bid',
          icon: 'ic_gavel',
          requiresAuth: true,
        ),
      ],
    );
  }

  static NotificationTemplate createBidOutbidTemplate(
      String auctionTitle, String newBidAmount) {
    return NotificationTemplate(
      id: 'bid_outbid_${DateTime.now().millisecondsSinceEpoch}',
      title: 'You\'ve Been Outbid!',
      body: 'Someone bid $newBidAmount on $auctionTitle',
      category: NotificationCategory.bid,
      priority: NotificationPriority.high,
      actions: [
        const NotificationAction(
          id: 'view_auction',
          title: 'View Auction',
          icon: 'ic_visibility',
        ),
        const NotificationAction(
          id: 'bid_higher',
          title: 'Bid Higher',
          icon: 'ic_trending_up',
          requiresAuth: true,
        ),
      ],
    );
  }

  static NotificationTemplate createMessageTemplate(
      String senderName, String messagePreview) {
    return NotificationTemplate(
      id: 'message_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Message from $senderName',
      body: messagePreview,
      category: NotificationCategory.message,
      priority: NotificationPriority.normal,
      actions: [
        const NotificationAction(
          id: 'view_message',
          title: 'View Message',
          icon: 'ic_message',
        ),
        const NotificationAction(
          id: 'reply',
          title: 'Reply',
          icon: 'ic_reply',
          requiresAuth: true,
        ),
      ],
    );
  }

  // Private helper methods

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      // This is a placeholder for notification initialization
      // In a real implementation, you would initialize the flutter_local_notifications plugin
      AppLogger.info('Local notifications initialized (placeholder)');
    } catch (e) {
      AppLogger.error('Failed to initialize local notifications', error: e);
    }
  }

  /// Create notification details based on template (placeholder)
  Future<Map<String, dynamic>> _createNotificationDetails(
      NotificationTemplate template) async {
    // This is a placeholder that returns notification configuration
    // In a real implementation, this would create platform-specific notification details
    return {
      'title': template.title,
      'body': template.body,
      'category': template.category.name,
      'priority': template.priority.name,
      'data': template.data,
      'actions': template.actions.map((a) => a.toJson()).toList(),
    };
  }

  /// Add notification to history
  void _addToHistory(NotificationTemplate template) {
    _notificationHistory.insert(0, template);

    // Keep only last 100 notifications
    if (_notificationHistory.length > 100) {
      _notificationHistory.removeRange(100, _notificationHistory.length);
    }

    _saveNotificationHistory();
  }

  /// Save notification settings
  Future<void> _saveSettings() async {
    try {
      final settingsData = _categorySettings.map(
        (key, value) => MapEntry(key.name, value),
      );

      await StorageService.setString(
          _notificationSettingsKey, json.encode(settingsData));
    } catch (e) {
      AppLogger.error('Failed to save notification settings', error: e);
    }
  }

  /// Load notification settings
  Future<void> _loadSettings() async {
    try {
      final settingsJson = StorageService.getString(_notificationSettingsKey);
      if (settingsJson != null) {
        final settingsData = json.decode(settingsJson) as Map<String, dynamic>;

        for (final entry in settingsData.entries) {
          final category = NotificationCategory.values.firstWhere(
            (c) => c.name == entry.key,
            orElse: () => NotificationCategory.system,
          );
          _categorySettings[category] = entry.value as bool;
        }
      }
    } catch (e) {
      AppLogger.error('Failed to load notification settings', error: e);
    }
  }

  /// Save scheduled notifications
  Future<void> _saveScheduledNotifications() async {
    try {
      final scheduledData =
          _scheduledNotifications.map((n) => n.toJson()).toList();
      await StorageService.setString(
          _scheduledNotificationsKey, json.encode(scheduledData));
    } catch (e) {
      AppLogger.error('Failed to save scheduled notifications', error: e);
    }
  }

  /// Load scheduled notifications
  Future<void> _loadScheduledNotifications() async {
    try {
      final scheduledJson =
          StorageService.getString(_scheduledNotificationsKey);
      if (scheduledJson != null) {
        final scheduledData = json.decode(scheduledJson) as List<dynamic>;

        _scheduledNotifications.clear();
        _scheduledNotifications.addAll(
            scheduledData.map((json) => ScheduledNotification.fromJson(json)));
      }
    } catch (e) {
      AppLogger.error('Failed to load scheduled notifications', error: e);
    }
  }

  /// Save notification history
  Future<void> _saveNotificationHistory() async {
    try {
      final historyData = _notificationHistory.map((n) => n.toJson()).toList();
      await StorageService.setString(
          _notificationHistoryKey, json.encode(historyData));
    } catch (e) {
      AppLogger.error('Failed to save notification history', error: e);
    }
  }

  /// Load notification history
  Future<void> _loadNotificationHistory() async {
    try {
      final historyJson = StorageService.getString(_notificationHistoryKey);
      if (historyJson != null) {
        final historyData = json.decode(historyJson) as List<dynamic>;

        _notificationHistory.clear();
        _notificationHistory.addAll(
            historyData.map((json) => NotificationTemplate.fromJson(json)));
      }
    } catch (e) {
      AppLogger.error('Failed to load notification history', error: e);
    }
  }
}
