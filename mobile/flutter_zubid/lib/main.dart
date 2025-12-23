import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/config/environment.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/logger.dart';
import 'features/auctions/data/models/auction_model.dart';
import 'features/auctions/data/models/bid_model.dart';
import 'features/auctions/data/models/category_model.dart';
import 'features/auctions/data/models/create_auction_model.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/orders/data/models/order_model.dart';
import 'features/payments/data/models/payment_method_model.dart';
import 'features/payments/data/models/transaction_model.dart';
import 'features/profile/data/models/profile_model.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set system UI and orientation
    _setSystemUI();
    
    // Initialize environment and services
    EnvironmentConfig.printConfig();
    await Firebase.initializeApp();
    await StorageService.init();
    await NotificationService.init();

    // Initialize Hive and register adapters
    await _initHive();

    AppLogger.info('ZUBID Mobile App Starting...');

    runApp(
      const ProviderScope(
        child: ZubidApp(),
      ),
    );
  } catch (error, stackTrace) {
    AppLogger.error('Error during app initialization', error: error, stackTrace: stackTrace);
    // Optionally, show a fallback UI
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
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AuctionModelAdapter());
  Hive.registerAdapter(BidModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(ProfileModelAdapter());
  Hive.registerAdapter(OrderModelAdapter());
  Hive.registerAdapter(ShippingAddressAdapter());
  Hive.registerAdapter(BillingAddressAdapter());
  Hive.registerAdapter(PaymentMethodModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
}
