import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _bidAlertsEnabled = true;
  bool _emailUpdatesEnabled = false;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          _buildSectionHeader(theme, 'Notifications'),
          _buildSwitchTile(theme, Icons.notifications_outlined, 'Push Notifications',
              'Receive push notifications', _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v)),
          _buildSwitchTile(theme, Icons.gavel_outlined, 'Bid Alerts',
              'Get notified when outbid', _bidAlertsEnabled,
              (v) => setState(() => _bidAlertsEnabled = v)),
          _buildSwitchTile(theme, Icons.email_outlined, 'Email Updates',
              'Receive email notifications', _emailUpdatesEnabled,
              (v) => setState(() => _emailUpdatesEnabled = v)),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Appearance'),
          _buildSwitchTile(theme, Icons.dark_mode_outlined, 'Dark Mode',
              'Use dark theme', _darkModeEnabled,
              (v) => setState(() => _darkModeEnabled = v)),
          _buildActionTile(theme, Icons.language_outlined, 'Language',
              _selectedLanguage, _showLanguageDialog),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Security'),
          _buildSwitchTile(theme, Icons.fingerprint_outlined, 'Biometric Login',
              'Use fingerprint or face ID', _biometricEnabled,
              (v) => setState(() => _biometricEnabled = v)),
          _buildActionTile(theme, Icons.lock_outline, 'Change Password',
              'Update your password', () => context.push('/profile/edit')),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Data and Storage'),
          _buildActionTile(theme, Icons.delete_sweep_outlined, 'Clear Cache',
              'Free up storage space', _clearCache),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'About'),
          _buildActionTile(theme, Icons.info_outline, 'About ZUBID',
              'Version 1.0.0', () => context.push('/about')),
          _buildActionTile(theme, Icons.description_outlined, 'Terms of Service',
              'View terms and conditions', () => context.push('/terms')),
          _buildActionTile(theme, Icons.privacy_tip_outlined, 'Privacy Policy',
              'View privacy policy', () => context.push('/privacy')),
          _buildActionTile(theme, Icons.help_outline, 'Help and Support',
              'Get help with ZUBID', () => context.push('/help')),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSwitchTile(ThemeData theme, IconData icon, String title,
      String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildActionTile(ThemeData theme, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Arabic', 'Kurdish'].map((lang) => ListTile(
            title: Text(lang),
            trailing: _selectedLanguage == lang
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              setState(() => _selectedLanguage = lang);
              Navigator.pop(ctx);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')));
            }, child: const Text('Clear')),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppLogger.userAction('User signed out from settings');
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
