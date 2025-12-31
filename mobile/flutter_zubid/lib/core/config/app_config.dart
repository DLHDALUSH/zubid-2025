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
  static String get baseUrl {
    // Use DuckDNS production server
    return 'https://zubidauction.duckdns.org/api';

    // For local development, uncomment the appropriate line below:
    // return 'http://10.0.2.2:5000/api'; // Android emulator
    // return 'http://localhost:5000/api'; // iOS simulator
    // return 'http://192.168.1.x:5000/api'; // Physical device (replace with your IP)
  }

  static String get apiUrl => baseUrl;

  static String get websocketUrl {
    // Use DuckDNS production server
    return 'wss://zubidauction.duckdns.org';

    // For local development, uncomment the appropriate line below:
    // return 'ws://10.0.2.2:5000'; // Android emulator
    // return 'ws://localhost:5000'; // iOS simulator
    // return 'ws://192.168.1.x:5000'; // Physical device (replace with your IP)
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
