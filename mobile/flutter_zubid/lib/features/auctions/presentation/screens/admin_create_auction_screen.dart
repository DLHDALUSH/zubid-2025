import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import 'create_auction_screen.dart';

class AdminCreateAuctionScreen extends ConsumerWidget {
  const AdminCreateAuctionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Check if user is authenticated and is admin
    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: custom.CustomErrorWidget(
          message: 'Please login to access this feature',
          onRetry: () => context.go('/login'),
          retryText: 'Login',
        ),
      );
    }
    
    // Check if user is admin
    final isAdmin = authState.user?.role == 'admin' || authState.user?.role == 'super_admin';
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: custom.CustomErrorWidget(
          message: 'Admin access required to create auctions',
          onRetry: () => context.go('/home'),
          retryText: 'Go Home',
        ),
      );
    }
    
    // User is admin, show the create auction screen
    return const CreateAuctionScreen();
  }
}
