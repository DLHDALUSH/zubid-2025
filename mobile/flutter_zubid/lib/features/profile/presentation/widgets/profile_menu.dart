import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  final VoidCallback? onMyBidsPressed;
  final VoidCallback? onMyAuctionsPressed;
  final VoidCallback? onWatchlistPressed;
  final VoidCallback? onTransactionsPressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onAdminDashboardPressed;
  final VoidCallback? onHelpPressed;
  final VoidCallback? onAboutPressed;
  final VoidCallback? onLogoutPressed;
  final bool isAdmin;

  const ProfileMenu({
    super.key,
    this.onMyBidsPressed,
    this.onMyAuctionsPressed,
    this.onWatchlistPressed,
    this.onTransactionsPressed,
    this.onNotificationsPressed,
    this.onAdminDashboardPressed,
    this.onHelpPressed,
    this.onAboutPressed,
    this.onLogoutPressed,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Admin Section (only for admin users)
        if (isAdmin) ...[
          _buildMenuSection(
            context,
            title: 'Admin',
            items: [
              _MenuItemData(
                icon: Icons.admin_panel_settings,
                title: 'Admin Dashboard',
                subtitle: 'Manage users, auctions, and settings',
                onTap: onAdminDashboardPressed,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Activity Section
        _buildMenuSection(
          context,
          title: 'Activity',
          items: [
            _MenuItemData(
              icon: Icons.gavel,
              title: 'My Bids',
              subtitle: 'View your bidding history',
              onTap: onMyBidsPressed,
            ),
            _MenuItemData(
              icon: Icons.inventory_2_outlined,
              title: 'My Auctions',
              subtitle: 'Manage your auction listings',
              onTap: onMyAuctionsPressed,
            ),
            _MenuItemData(
              icon: Icons.favorite_outline,
              title: 'Watchlist',
              subtitle: 'Items you\'re watching',
              onTap: onWatchlistPressed,
            ),
            _MenuItemData(
              icon: Icons.receipt_long,
              title: 'Transactions',
              subtitle: 'Payment and purchase history',
              onTap: onTransactionsPressed,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Settings Section
        _buildMenuSection(
          context,
          title: 'Settings',
          items: [
            _MenuItemData(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: onNotificationsPressed,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Support Section
        _buildMenuSection(
          context,
          title: 'Support',
          items: [
            _MenuItemData(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: onHelpPressed,
            ),
            _MenuItemData(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: onAboutPressed,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Logout Section
        _buildMenuSection(
          context,
          title: 'Account',
          items: [
            _MenuItemData(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: onLogoutPressed,
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItemData> items,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItemData item) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        item.icon,
        color: item.isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(
        item.title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: item.isDestructive
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });
}
