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
      print('Hive initialization failed: $e');
    }

    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print('Firebase initialization failed: $e');
      // Continue without Firebase for now
    }

    // Initialize storage (after Hive is initialized)
    try {
      await StorageService.init();
    } catch (e) {
      print('Storage initialization failed: $e');
    }

    // Initialize notifications
    try {
      await NotificationService.init();
    } catch (e) {
      print('Notification service initialization failed: $e');
    }

    print('ZUBID Mobile App Starting...');
  } catch (error) {
    print('Service initialization error: $error');
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
      print('UserModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(AuctionModelAdapter());
    } catch (e) {
      print('AuctionModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(BidModelAdapter());
    } catch (e) {
      print('BidModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(CategoryModelAdapter());
    } catch (e) {
      print('CategoryModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(ProfileModelAdapter());
    } catch (e) {
      print('ProfileModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(OrderModelAdapter());
    } catch (e) {
      print('OrderModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(ShippingAddressAdapter());
    } catch (e) {
      print('ShippingAddressAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(BillingAddressAdapter());
    } catch (e) {
      print('BillingAddressAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(PaymentMethodModelAdapter());
    } catch (e) {
      print('PaymentMethodModelAdapter registration failed: $e');
    }

    try {
      Hive.registerAdapter(TransactionModelAdapter());
    } catch (e) {
      print('TransactionModelAdapter registration failed: $e');
    }
  } catch (e) {
    print('Hive initialization failed: $e');
  }
}
