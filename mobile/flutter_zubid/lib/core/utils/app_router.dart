import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auctions/presentation/screens/auction_list_screen.dart';
import '../../features/auctions/data/models/auction_model.dart';
import '../../features/auctions/presentation/screens/auction_detail_screen.dart';
import '../../features/auctions/presentation/screens/create_auction_screen.dart';
import '../../features/auctions/presentation/screens/create_auction_screen.dart';
import '../../features/auctions/presentation/screens/my_auctions_screen.dart';
import '../../features/payments/presentation/screens/payment_methods_screen.dart';
import '../../features/payments/presentation/screens/transaction_history_screen.dart';
import '../../features/payments/presentation/screens/add_payment_method_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/orders/presentation/screens/buy_now_screen.dart';
import '../../features/orders/presentation/screens/order_confirmation_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/bids/presentation/screens/my_bids_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../main.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Auction Routes
      GoRoute(
        path: '/auctions',
        name: 'auctions',
        builder: (context, state) => const AuctionListScreen(),
        routes: [
          GoRoute(
            path: '/detail/:id',
            name: 'auction-detail',
            builder: (context, state) {
              final auctionId = state.pathParameters['id']!;
              return AuctionDetailScreen(auctionId: auctionId);
            },
          ),
          GoRoute(
            path: '/create',
            name: 'create-auction',
            builder: (context, state) => const CreateAuctionScreen(),
          ),
        ],
      ),
      
      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: '/edit',
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      
      // Bids Routes
      GoRoute(
        path: '/my-bids',
        name: 'my-bids',
        builder: (context, state) => const MyBidsScreen(),
      ),

      // Buy Now Screen
      GoRoute(
        path: '/buy-now',
        name: 'buy-now',
        builder: (context, state) {
          final auction = state.extra as AuctionModel;
          return BuyNowScreen(auction: auction);
        },
      ),

      // Order Confirmation Screen
      GoRoute(
        path: '/order-confirmation',
        name: 'order-confirmation',
        builder: (context, state) => const OrderConfirmationScreen(),
      ),

      // My Auctions Screen
      GoRoute(
        path: '/my-auctions',
        name: 'my-auctions',
        builder: (context, state) => const MyAuctionsScreen(),
      ),

      // Payment Methods Screen
      GoRoute(
        path: '/payment-methods',
        name: 'payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),

      // Transaction History Screen
      GoRoute(
        path: '/transaction-history',
        name: 'transaction-history',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),

      // Add Payment Method Screen
      GoRoute(
        path: '/add-payment-method',
        name: 'add-payment-method',
        builder: (context, state) => const AddPaymentMethodScreen(),
      ),
      
      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      
      // Error Route
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) => const ErrorScreen(),
      ),
    ],
    
    // Error Handler
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error?.toString() ?? 'Unknown error occurred',
    ),
    
    // Redirect Logic
    redirect: (context, state) {
      // Add authentication and authorization logic here
      return null;
    },
  );
});

// Error Screen Widget
class ErrorScreen extends StatelessWidget {
  final String? error;
  
  const ErrorScreen({Key? key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.go('/home');
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
