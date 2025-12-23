import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu.dart';
import '../widgets/profile_completion_card.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: profileState.isLoading && !profileState.hasProfile,
        child: RefreshIndicator(
          onRefresh: () => ref.read(profileProvider.notifier).refreshProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                ProfileHeader(
                  profile: profileState.profile,
                  isLoading: profileState.isLoading,
                  onEditPressed: () => context.push('/profile/edit'),
                ),
                
                const SizedBox(height: 20),
                
                // Profile Completion Card
                if (profileState.hasProfile && !profileState.isProfileComplete)
                  ProfileCompletionCard(
                    profile: profileState.profile!,
                    onCompletePressed: () => context.push('/profile/edit'),
                  ),
                
                if (profileState.hasProfile && !profileState.isProfileComplete)
                  const SizedBox(height: 20),
                
                // Profile Stats
                if (profileState.hasProfile)
                  ProfileStats(profile: profileState.profile!),
                
                if (profileState.hasProfile)
                  const SizedBox(height: 20),
                
                // Profile Menu
                ProfileMenu(
                  onMyBidsPressed: () => context.push('/my-bids'),
                  onMyAuctionsPressed: () => context.push('/my-auctions'),
                  onWatchlistPressed: () => context.push('/watchlist'),
                  onTransactionsPressed: () => context.push('/transactions'),
                  onNotificationsPressed: () => context.push('/notifications'),
                  onHelpPressed: () => context.push('/help'),
                  onAboutPressed: () => context.push('/about'),
                  onLogoutPressed: _handleLogout,
                ),
                
                const SizedBox(height: 20),
                
                // Error Display
                if (profileState.hasError)
                  _buildErrorCard(profileState.error!),
                
                // Empty State
                if (!profileState.hasProfile && !profileState.isLoading)
                  _buildEmptyState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Error Loading Profile',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(profileProvider.notifier).refreshProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onErrorContainer,
                foregroundColor: theme.colorScheme.errorContainer,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Profile Not Found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load your profile information.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
              child: const Text('Reload Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        AppLogger.userAction('User logout initiated');
        
        await ref.read(authProvider.notifier).logout();
        
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        AppLogger.error('Logout failed', error: e);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
