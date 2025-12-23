import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../utils/logger.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  static String? _fcmToken;
  
  /// Initialize notification service
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      AppLogger.info('Initializing notification service...');
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();
      
      // Request permissions
      await requestPermissions();
      
      // Get FCM token
      await _getFCMToken();
      
      // Setup message handlers
      _setupMessageHandlers();
      
      _isInitialized = true;
      AppLogger.info('Notification service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize notification service', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    AppLogger.info('Local notifications initialized');
  }
  
  /// Initialize Firebase messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Configure Firebase messaging options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    AppLogger.info('Firebase messaging initialized');
  }
  
  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    try {
      // Request Firebase messaging permissions
      final NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      final bool granted = settings.authorizationStatus == AuthorizationStatus.authorized;
      
      if (granted) {
        AppLogger.info('Notification permissions granted');
        await StorageService.setNotificationsEnabled(true);
      } else {
        AppLogger.warning('Notification permissions denied');
        await StorageService.setNotificationsEnabled(false);
      }
      
      return granted;
    } catch (e) {
      AppLogger.error('Failed to request notification permissions', error: e);
      return false;
    }
  }
  
  /// Get FCM token
  static Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        AppLogger.info('FCM token obtained: ${_fcmToken!.substring(0, 20)}...');
        // TODO: Send token to backend
      }
      return _fcmToken;
    } catch (e) {
      AppLogger.error('Failed to get FCM token', error: e);
      return null;
    }
  }
  
  /// Get current FCM token
  static String? get fcmToken => _fcmToken;
  
  /// Setup message handlers
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      AppLogger.info('FCM token refreshed');
      // TODO: Send updated token to backend
    });
    
    AppLogger.info('Message handlers setup complete');
  }
  
  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('Received foreground message: ${message.messageId}');
    
    // Show local notification for foreground messages
    await showLocalNotification(
      title: message.notification?.title ?? 'ZUBID',
      body: message.notification?.body ?? 'You have a new notification',
      payload: jsonEncode(message.data),
    );
  }
  
  /// Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    AppLogger.info('Received background message: ${message.messageId}');
    // Background message handling logic
  }
  
  /// Handle notification tap
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    AppLogger.info('Notification tapped: ${message.messageId}');
    
    // Navigate based on notification data
    final data = message.data;
    if (data.containsKey('type')) {
      await _navigateBasedOnNotification(data);
    }
  }
  
  /// Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info('Local notification tapped: ${response.id}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _navigateBasedOnNotification(data);
      } catch (e) {
        AppLogger.error('Failed to parse notification payload', error: e);
      }
    }
  }
  
  /// Navigate based on notification data
  static Future<void> _navigateBasedOnNotification(Map<String, dynamic> data) async {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    
    // TODO: Implement navigation logic based on notification type
    switch (type) {
      case 'bid_update':
        // Navigate to auction detail
        AppLogger.info('Navigating to auction detail: $id');
        break;
      case 'auction_ending':
        // Navigate to auction detail
        AppLogger.info('Navigating to ending auction: $id');
        break;
      case 'payment_success':
        // Navigate to payment history
        AppLogger.info('Navigating to payment success');
        break;
      case 'new_message':
        // Navigate to messages
        AppLogger.info('Navigating to messages');
        break;
      default:
        AppLogger.info('Unknown notification type: $type');
    }
  }
  
  /// Show local notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'zubid_channel',
        'ZUBID Notifications',
        channelDescription: 'Notifications for ZUBID auction platform',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformDetails,
        payload: payload,
      );
      
      AppLogger.info('Local notification shown: $title');
    } catch (e) {
      AppLogger.error('Failed to show local notification', error: e);
    }
  }
  
  /// Show bid update notification
  static Future<void> showBidUpdateNotification({
    required String auctionTitle,
    required String currentBid,
    required String auctionId,
  }) async {
    await showLocalNotification(
      title: 'Bid Update',
      body: 'New bid on "$auctionTitle": $currentBid',
      payload: jsonEncode({
        'type': 'bid_update',
        'id': auctionId,
      }),
    );
  }
  
  /// Show auction ending notification
  static Future<void> showAuctionEndingNotification({
    required String auctionTitle,
    required String timeLeft,
    required String auctionId,
  }) async {
    await showLocalNotification(
      title: 'Auction Ending Soon',
      body: '"$auctionTitle" ends in $timeLeft',
      payload: jsonEncode({
        'type': 'auction_ending',
        'id': auctionId,
      }),
    );
  }
  
  /// Show payment success notification
  static Future<void> showPaymentSuccessNotification({
    required String amount,
    required String auctionTitle,
  }) async {
    await showLocalNotification(
      title: 'Payment Successful',
      body: 'Payment of $amount for "$auctionTitle" completed successfully',
      payload: jsonEncode({
        'type': 'payment_success',
      }),
    );
  }
  
  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.info('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Failed to subscribe to topic: $topic', error: e);
    }
  }
  
  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from topic: $topic', error: e);
    }
  }
  
  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      AppLogger.info('All notifications cancelled');
    } catch (e) {
      AppLogger.error('Failed to cancel notifications', error: e);
    }
  }
  
  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      AppLogger.info('Notification cancelled: $id');
    } catch (e) {
      AppLogger.error('Failed to cancel notification: $id', error: e);
    }
  }
}
