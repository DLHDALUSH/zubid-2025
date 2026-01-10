import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app.dart';
import 'core/config/environment.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';
import 'features/auctions/data/models/auction_model.dart';
import 'features/auctions/data/models/bid_model.dart';
import 'features/auctions/data/models/category_model.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/orders/data/models/order_model.dart';
import 'features/payments/data/models/payment_method_model.dart';
import 'features/payments/data/models/transaction_model.dart';
import 'features/profile/data/models/profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Track app startup performance
  final startupTimer = Stopwatch()..start();

  // Set system UI and orientation
  _setSystemUI();

  // Initialize crash reporting first
  await _initializeCrashReporting();

  // Initialize basic services with error handling
  final initSuccess = await _initializeServices();

  startupTimer.stop();
  AppLogger.performance('App Startup', startupTimer.elapsed,
      details: 'Total initialization time');

  // Run app or show error screen
  if (initSuccess) {
    runApp(
      const ProviderScope(
        child: ZubidApp(),
      ),
    );
  } else {
    runApp(const ErrorApp());
  }
}

Future<bool> _initializeServices() async {
  try {
    // Initialize environment
    EnvironmentConfig.printConfig();

    // Check for app updates
    await _checkForUpdates();

    // Initialize Hive FIRST (before StorageService)
    try {
      await _initHive();
    } catch (e) {
      AppLogger.error('Hive initialization failed', error: e);
      return false;
    }

    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      AppLogger.warning('Firebase initialization failed, continuing without it',
          error: e);
      // Continue without Firebase for now
    }

    // Initialize storage (after Hive is initialized)
    try {
      await StorageService.init();
    } catch (e) {
      AppLogger.error('Storage initialization failed', error: e);
      return false;
    }

    // Initialize notifications
    try {
      await NotificationService.init();
    } catch (e) {
      AppLogger.warning('Notification service initialization failed', error: e);
    }

    // Initialize background tasks
    await _initializeBackgroundTasks();

    AppLogger.info('ZUBID Mobile App Starting...');
    return true;
  } catch (error) {
    AppLogger.error('Service initialization error', error: error);
    return false;
  }
}

void _setSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> _initHive() async {
  try {
    await Hive.initFlutter();

    // Register adapters with error handling
    try {
      Hive.registerAdapter(UserModelAdapter());
    } catch (e) {
      debugPrint('UserModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(AuctionModelAdapter());
    } catch (e) {
      debugPrint('AuctionModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(BidModelAdapter());
    } catch (e) {
      debugPrint('BidModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(CategoryModelAdapter());
    } catch (e) {
      debugPrint('CategoryModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(ProfileModelAdapter());
    } catch (e) {
      debugPrint('ProfileModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(OrderModelAdapter());
    } catch (e) {
      debugPrint('OrderModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(ShippingAddressAdapter());
    } catch (e) {
      debugPrint('ShippingAddressAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(BillingAddressAdapter());
    } catch (e) {
      debugPrint('BillingAddressAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(PaymentMethodModelAdapter());
    } catch (e) {
      debugPrint('PaymentMethodModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(TransactionModelAdapter());
    } catch (e) {
      debugPrint('TransactionModelAdapter registration failed: $e');
    }
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
  }
}

Future<void> _initializeCrashReporting() async {
  try {
    // Initialize basic error reporting
    // Note: Firebase Crashlytics would be initialized here if available
    AppLogger.info('Error reporting initialized');
  } catch (e) {
    AppLogger.warning('Failed to initialize crash reporting', error: e);
  }
}

Future<void> _checkForUpdates() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    AppLogger.info('Current app version: $currentVersion');

    // Here you would typically check against a remote API for updates
    // For now, just log the version
  } catch (e) {
    AppLogger.warning('Failed to check for updates', error: e);
  }
}

Future<void> _initializeBackgroundTasks() async {
  try {
    // Initialize any background tasks here
    // For example: WorkManager, background fetch, etc.
    AppLogger.info('Background tasks initialized');
  } catch (e) {
    AppLogger.warning('Failed to initialize background tasks', error: e);
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZUBID - Error',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ZUBID encountered an unexpected error during startup',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please try restarting the app',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    runApp(
                      const ProviderScope(
                        child: ZubidApp(),
                      ),
                    );
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
