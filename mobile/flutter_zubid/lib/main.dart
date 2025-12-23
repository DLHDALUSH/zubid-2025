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

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize app services
      await Future.wait([
        AppConfig.initialize(),
        StorageService.init(),
        NotificationService.init(),
      ]);

      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 3000));

      if (mounted) {
        // Navigate to appropriate screen based on auth state
        final isLoggedIn = await StorageService.isLoggedIn();
        if (isLoggedIn) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    } catch (e) {
      AppLogger.error('App initialization failed: $e');
      if (mounted) {
        context.go('/error');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.gavel,
                        size: 60,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // App Name
                    const Text(
                      'ZUBID',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tagline
                    Text(
                      'Auction Platform',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
