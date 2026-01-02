import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/config/environment.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
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

  // Set system UI and orientation
  _setSystemUI();

  // Initialize basic services with error handling
  await _initializeServices();

  runApp(
    const ProviderScope(
      child: ZubidApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  try {
    // Initialize environment
    EnvironmentConfig.printConfig();

    // Initialize Hive FIRST (before StorageService)
    try {
      await _initHive();
    } catch (e) {
      debugPrint('Hive initialization failed: $e');
    }

    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      // Continue without Firebase for now
    }

    // Initialize storage (after Hive is initialized)
    try {
      await StorageService.init();
    } catch (e) {
      debugPrint('Storage initialization failed: $e');
    }

    // Initialize notifications
    try {
      await NotificationService.init();
    } catch (e) {
      debugPrint('Notification service initialization failed: $e');
    }

    debugPrint('ZUBID Mobile App Starting...');
  } catch (error) {
    debugPrint('Service initialization error: $error');
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
