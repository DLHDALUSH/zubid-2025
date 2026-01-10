import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
