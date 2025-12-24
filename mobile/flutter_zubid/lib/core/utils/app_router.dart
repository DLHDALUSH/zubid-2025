import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/auctions/data/models/auction_model.dart';
import '../../features/auctions/presentation/screens/auction_detail_screen.dart';
import '../../features/auctions/presentation/screens/auction_list_screen.dart';
import '../../features/auctions/presentation/screens/create_auction_screen.dart';
import '../../features/auctions/presentation/screens/my_auctions_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/bids/presentation/screens/my_bids_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/orders/presentation/screens/buy_now_screen.dart';
import '../../features/orders/presentation/screens/order_confirmation_screen.dart';
import '../../features/payments/presentation/screens/add_payment_method_screen.dart';
import '../../features/payments/presentation/screens/payment_methods_screen.dart';
import '../../features/payments/presentation/screens/transaction_history_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/legal/presentation/screens/terms_of_service_screen.dart';
import '../../features/legal/presentation/screens/privacy_policy_screen.dart';
import '../widgets/error_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.auctions,
        builder: (context, state) => const AuctionListScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.auctionDetail,
            builder: (context, state) {
              final auctionId = state.pathParameters['id']!;
              return AuctionDetailScreen(auctionId: auctionId);
            },
          ),
          GoRoute(
            path: AppRoutes.createAuction,
            builder: (context, state) => const CreateAuctionScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.editProfile,
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.myBids,
        builder: (context, state) => const MyBidsScreen(),
      ),
      GoRoute(
        path: AppRoutes.buyNow,
        builder: (context, state) {
          final auction = state.extra as AuctionModel;
          return BuyNowScreen(auction: auction);
        },
      ),
      GoRoute(
        path: AppRoutes.orderConfirmation,
        builder: (context, state) => const OrderConfirmationScreen(),
      ),
      GoRoute(
        path: AppRoutes.myAuctions,
        builder: (context, state) => const MyAuctionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.paymentMethods,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactionHistory,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.addPaymentMethod,
        builder: (context, state) => const AddPaymentMethodScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsOfService,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error?.toString(),
    ),
    redirect: (context, state) {
      // TODO: Add authentication and authorization logic here
      return null;
    },
  );
});
