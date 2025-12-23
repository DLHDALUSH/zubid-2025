import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/config/theme_config.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/app_router.dart';
import 'core/utils/logger.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auctions/data/models/auction_model.dart';
import 'features/auctions/data/models/bid_model.dart';
import 'features/auctions/data/models/category_model.dart';
import 'features/profile/data/models/profile_model.dart';
import 'features/orders/data/models/order_model.dart';
import 'features/auctions/data/models/create_auction_model.dart';
import 'features/payments/data/models/payment_method_model.dart';
import 'features/payments/data/models/transaction_model.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Print environment configuration
  EnvironmentConfig.printConfig();

  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive
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
  
  // Initialize services
  await StorageService.init();
  await NotificationService.init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  AppLogger.info('ZUBID Mobile App Starting...');
  
  runApp(
    ProviderScope(
      child: ZubidApp(),
    ),
  );
}

class ZubidApp extends ConsumerWidget {
  const ZubidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'ZUBID - Auction Platform',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      
      // Router Configuration
      routerConfig: router,
      
      // Localization
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
      
      // Builder for global configurations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Prevent text scaling
          ),
          child: child!,
        );
      },
    );
  }
}


