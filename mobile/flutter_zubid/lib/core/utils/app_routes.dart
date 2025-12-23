class AppRoutes {
  // Splash
  static const String splash = '/splash';

  // Onboarding
  static const String onboarding = '/onboarding';

  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main App
  static const String home = '/home';

  // Auctions
  static const String auctions = '/auctions';
  static const String auctionDetail = 'detail/:id'; // Sub-route
  static const String createAuction = 'create'; // Sub-route

  // Profile
  static const String profile = '/profile';
  static const String editProfile = 'edit'; // Sub-route

  // Bids
  static const String myBids = '/my-bids';

  // Orders
  static const String buyNow = '/buy-now';
  static const String orderConfirmation = '/order-confirmation';

  // User Listings
  static const String myAuctions = '/my-auctions';

  // Payments
  static const String paymentMethods = '/payment-methods';
  static const String addPaymentMethod = '/add-payment-method';
  static const String transactionHistory = '/transaction-history';

  // Notifications
  static const String notifications = '/notifications';

  // Admin
  static const String adminDashboard = '/admin';

  // General
  static const String error = '/error';
}
