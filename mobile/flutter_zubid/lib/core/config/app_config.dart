import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'ZUBID';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Environment detection
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  static bool get isProfile => kProfileMode;

  // API Configuration
  // Environment variables can be set using --dart-define during build/run
  // Example: flutter run --dart-define=API_URL=http://10.0.2.2:5000
  static String get baseUrl {
    // Check for environment variable first
    const envApiUrl = String.fromEnvironment('API_URL');
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }

    // Auto-detect based on build mode
    if (isProduction) {
      // Production: Use Render.com server
      return 'https://zubid-2025.onrender.com';
    } else {
      // Development: Use local server
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      // iOS simulator can use localhost directly
      // For physical devices, you'll need to use your computer's IP address
      return 'http://10.0.2.2:5000'; // Default for Android emulator
    }
  }

  static String get apiUrl => '$baseUrl/api';

  static String get websocketUrl {
    // Check for environment variable first
    const envWsUrl = String.fromEnvironment('WS_URL');
    if (envWsUrl.isNotEmpty) {
      return envWsUrl;
    }

    // Auto-detect based on build mode
    if (isProduction) {
      // Production: Use secure WebSocket
      return 'wss://zubid-2025.onrender.com';
    } else {
      // Development: Use local WebSocket
      return 'ws://10.0.2.2:5000'; // Default for Android emulator
    }
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Timeout values in milliseconds for Dio
  static int get connectTimeoutMs => connectTimeout.inMilliseconds;
  static int get receiveTimeoutMs => receiveTimeout.inMilliseconds;
  static int get apiTimeout => sendTimeout.inMilliseconds;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const int imageQuality = 85;
  static const int thumbnailSize = 300;

  // Security
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const int maxLoginAttempts = 5;
  static const Duration loginCooldown = Duration(minutes: 15);

  // Features
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;

  // Payment Configuration
  static const List<String> supportedPaymentMethods = [
    'fib',
    'zain_cash',
    'visa',
    'mastercard',
  ];

  // Auction Configuration
  static const Duration minAuctionDuration = Duration(hours: 1);
  static const Duration maxAuctionDuration = Duration(days: 30);
  static const double minBidIncrement = 1.0;
  static const Duration bidExtensionTime = Duration(minutes: 5);

  // Localization
  static const List<String> supportedLocales = ['en', 'ar', 'ku'];
  static const String defaultLocale = 'en';

  // Logging
  static bool get enableLogging => !isProduction;
  static bool get enableCrashReporting => isProduction;

  // Environment-specific settings
  static Map<String, dynamic> get environmentConfig {
    if (isProduction) {
      return {
        'logLevel': 'ERROR',
        'enableDebugTools': false,
        'enablePerformanceMonitoring': true,
        'enableCrashReporting': true,
        'apiTimeout': 30000,
        'retryAttempts': 3,
      };
    } else {
      return {
        'logLevel': 'DEBUG',
        'enableDebugTools': true,
        'enablePerformanceMonitoring': false,
        'enableCrashReporting': false,
        'apiTimeout': 60000,
        'retryAttempts': 1,
      };
    }
  }

  // App Store Configuration
  static const String androidPackageName = 'com.zubid.auction';
  static const String iosAppId = ''; // To be set when iOS app is published
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageName';
  static const String appStoreUrl = 'https://apps.apple.com/app/id$iosAppId';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/zubidauction';
  static const String twitterUrl = 'https://twitter.com/zubidauction';
  static const String instagramUrl = 'https://instagram.com/zubidauction';

  // Support
  static const String supportEmail = 'support@zubidauction.com';
  static const String supportPhone = '+964-xxx-xxx-xxxx';
  static String get privacyPolicyUrl => '$baseUrl/privacy-policy';
  static String get termsOfServiceUrl => '$baseUrl/terms-of-service';

  // Image Helper
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    // Data URIs should be returned as-is (base64-encoded images)
    if (path.startsWith('data:image/')) return path;

    // Absolute URLs should be returned as-is
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    // Remove leading slash if exists for relative paths
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    // baseUrl in this class is root (https://zubid-2025.onrender.com)
    return '$baseUrl/$cleanPath';
  }

  /// Check if the given URL is a data URI (base64-encoded image)
  static bool isDataUri(String? url) {
    return url != null && url.startsWith('data:image/');
  }

  /// Check if the given URL is a valid image URL (http/https or data URI)
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('data:image/');
  }

  // Firebase Configuration (if using Firebase)
  static const String firebaseProjectId = 'zubid-auction';
  static const String firebaseApiKey = ''; // To be set from environment
  static const String firebaseAppId = ''; // To be set from environment

  // Analytics
  static const String mixpanelToken = ''; // To be set from environment
  static const String amplitudeApiKey = ''; // To be set from environment

  // Error Reporting
  static const String sentryDsn = ''; // To be set from environment

  // Feature Flags
  static const Map<String, bool> featureFlags = {
    'enableNewUI': true,
    'enableAdvancedSearch': true,
    'enableVideoAuctions': false,
    'enableCryptocurrency': false,
    'enableAIRecommendations': false,
  };

  // Regional Settings
  static const String defaultCurrency = 'IQD';
  static const String defaultCountry = 'IQ';
  static const String defaultTimezone = 'Asia/Baghdad';

  // Performance
  static const int maxConcurrentRequests = 10;
  static const Duration requestDebounceTime = Duration(milliseconds: 300);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
