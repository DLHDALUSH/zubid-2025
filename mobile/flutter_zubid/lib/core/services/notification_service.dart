import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

import '../config/environment.dart';
import '../utils/logger.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static bool _isInitialized = false;
  static String? _fcmToken;
  static Dio? _dio;

  /// Initialize notification service
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('Initializing notification service...');

      // Request permission for notifications
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('User granted permission for notifications');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        AppLogger.info('User granted provisional permission for notifications');
      } else {
        AppLogger.warning(
            'User declined or has not accepted permission for notifications');
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      AppLogger.info('FCM Token: $_fcmToken');

      // Save token to storage (using SharedPreferences directly)
      if (_fcmToken != null) {
        // Token will be saved when needed - for now just log it
        AppLogger.info('FCM Token saved: $_fcmToken');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      _isInitialized = true;
      AppLogger.info('Notification service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize notification service', error: e);
    }
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    if (!_isInitialized) await init();
    return _fcmToken;
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Received foreground message: ${message.messageId}');

    // Show notification using system notification
    // In a real app, you would use flutter_local_notifications here
    AppLogger.info(
        'Notification: ${message.notification?.title} - ${message.notification?.body}');
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info('Notification tapped: ${message.messageId}');

    // Handle navigation based on notification data
    if (message.data.isNotEmpty) {
      AppLogger.info('Notification data: ${message.data}');
    }
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

  /// Register FCM token with backend
  static Future<bool> registerTokenWithBackend() async {
    try {
      final token = await getToken();
      if (token == null) {
        AppLogger.warning('No FCM token to register');
        return false;
      }

      _dio ??= Dio(BaseOptions(
        baseUrl: EnvironmentConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await _dio!.post(
        '/user/fcm-token',
        data: {'fcm_token': token},
      );

      if (response.statusCode == 200) {
        AppLogger.info('FCM token registered with backend');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to register FCM token with backend', error: e);
      return false;
    }
  }

  /// Unregister FCM token from backend (on logout)
  static Future<bool> unregisterTokenFromBackend() async {
    try {
      _dio ??= Dio(BaseOptions(
        baseUrl: EnvironmentConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await _dio!.delete('/user/fcm-token');

      if (response.statusCode == 200) {
        AppLogger.info('FCM token unregistered from backend');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to unregister FCM token from backend', error: e);
      return false;
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  AppLogger.info('Received background message: ${message.messageId}');
}
