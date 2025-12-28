import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment get current {
    if (kReleaseMode) {
      return Environment.production;
    } else if (kProfileMode) {
      return Environment.staging;
    } else {
      return Environment.development;
    }
  }

  static String get name {
    switch (current) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  static String get apiBaseUrl {
    switch (current) {
      case Environment.development:
        // Use Render.com production server for all environments
        return 'https://zubid-2025.onrender.com/api';

      // For local development, uncomment the appropriate line below:
      // return 'http://10.0.2.2:5000/api'; // Android emulator
      // return 'http://localhost:5000/api'; // iOS simulator
      // return 'http://192.168.1.x:5000/api'; // Physical device
      case Environment.staging:
        return 'https://zubid-2025.onrender.com/api';
      case Environment.production:
        return 'https://zubid-2025.onrender.com/api';
    }
  }

  static String get websocketUrl {
    switch (current) {
      case Environment.development:
        // Use Render.com production server for all environments
        return 'wss://zubid-2025.onrender.com';

      // For local development, uncomment the appropriate line below:
      // return 'ws://10.0.2.2:5000'; // Android emulator
      // return 'ws://localhost:5000'; // iOS simulator
      // return 'ws://192.168.1.x:5000'; // Physical device
      case Environment.staging:
        return 'wss://zubid-2025.onrender.com';
      case Environment.production:
        return 'wss://zubid-2025.onrender.com';
    }
  }

  static bool get enableLogging {
    switch (current) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  static bool get enableDebugTools {
    switch (current) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  static bool get enableCrashReporting {
    switch (current) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }

  static bool get enableAnalytics {
    switch (current) {
      case Environment.development:
        return false;
      case Environment.staging:
        return false;
      case Environment.production:
        return true;
    }
  }

  static Duration get apiTimeout {
    switch (current) {
      case Environment.development:
        return const Duration(seconds: 60);
      case Environment.staging:
        return const Duration(seconds: 45);
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }

  static int get maxRetryAttempts {
    switch (current) {
      case Environment.development:
        return 1;
      case Environment.staging:
        return 2;
      case Environment.production:
        return 3;
    }
  }

  static String get logLevel {
    switch (current) {
      case Environment.development:
        return 'DEBUG';
      case Environment.staging:
        return 'INFO';
      case Environment.production:
        return 'ERROR';
    }
  }

  static Map<String, dynamic> get config {
    return {
      'environment': name,
      'apiBaseUrl': apiBaseUrl,
      'websocketUrl': websocketUrl,
      'enableLogging': enableLogging,
      'enableDebugTools': enableDebugTools,
      'enableCrashReporting': enableCrashReporting,
      'enableAnalytics': enableAnalytics,
      'apiTimeout': apiTimeout.inMilliseconds,
      'maxRetryAttempts': maxRetryAttempts,
      'logLevel': logLevel,
    };
  }

  static void printConfig() {
    if (enableLogging) {
      print('=== ZUBID Environment Configuration ===');
      print('Environment: $name');
      print('API Base URL: $apiBaseUrl');
      print('WebSocket URL: $websocketUrl');
      print('Logging Enabled: $enableLogging');
      print('Debug Tools: $enableDebugTools');
      print('Crash Reporting: $enableCrashReporting');
      print('Analytics: $enableAnalytics');
      print('API Timeout: ${apiTimeout.inSeconds}s');
      print('Max Retry Attempts: $maxRetryAttempts');
      print('Log Level: $logLevel');
      print('=====================================');
    }
  }
}
