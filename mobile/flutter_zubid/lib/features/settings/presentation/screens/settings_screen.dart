import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    // Load local settings
    _notificationsEnabled = StorageService.isNotificationsEnabled();
    _biometricEnabled = StorageService.isBiometricEnabled();

    // Get dark mode from theme provider
    final themeMode = ref.read(themeModeProvider);
    _darkModeEnabled = themeMode == ThemeMode.dark;

    final language = StorageService.getLanguage();
    _selectedLanguage = _getLanguageDisplayName(language);

    // Load profile preferences if available
    final profile = ref.read(currentProfileProvider);
    if (profile?.preferences != null) {
      final prefs = profile!.preferences!;
      _notificationsEnabled = prefs['notifications_enabled'] ?? true;
      _bidAlertsEnabled = prefs['bid_alerts'] ?? true;
      _emailUpdatesEnabled = prefs['email_notifications'] ?? false;
    }

    setState(() => _isLoading = false);
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'ar':
        return 'Arabic';
      case 'ku':
        return 'Kurdish';
      default:
        return 'English';
    }
  }

  String _getLanguageCode(String displayName) {
    switch (displayName) {
      case 'Arabic':
        return 'ar';
      case 'Kurdish':
        return 'ku';
      default:
        return 'en';
    }
  }

  Future<void> _saveLanguageSetting(String displayName) async {
    setState(() => _selectedLanguage = displayName);
    final code = _getLanguageCode(displayName);
    await StorageService.setLanguage(code);
    _showSavedSnackbar();
  }

  Future<void> _saveNotificationSetting(bool value) async {
    setState(() => _notificationsEnabled = value);
    await StorageService.setNotificationsEnabled(value);
    _showSavedSnackbar();
  }

  Future<void> _saveBidAlertsSetting(bool value) async {
    setState(() => _bidAlertsEnabled = value);
    _showSavedSnackbar();
  }

  Future<void> _saveEmailUpdatesSetting(bool value) async {
    setState(() => _emailUpdatesEnabled = value);
    _showSavedSnackbar();
  }

  Future<void> _saveDarkModeSetting(bool value) async {
    setState(() => _darkModeEnabled = value);
    // Update theme through provider (which also saves to storage)
    await ref.read(themeModeProvider.notifier).toggleDarkMode(value);
    _showSavedSnackbar();
  }

  Future<void> _saveBiometricSetting(bool value) async {
    setState(() => _biometricEnabled = value);
    await StorageService.setBiometricEnabled(value);
    _showSavedSnackbar();
  }

  void _showSavedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Setting saved'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // User info header
                _buildUserHeader(theme),

                const SizedBox(height: 8),

                _buildSectionHeader(theme, 'Notifications'),
                _buildSwitchTile(
                  theme,
                  Icons.notifications_outlined,
                  'Push Notifications',
                  'Receive push notifications',
                  _notificationsEnabled,
                  _saveNotificationSetting,
                ),
                _buildSwitchTile(
                  theme,
                  Icons.gavel_outlined,
                  'Bid Alerts',
                  'Get notified when outbid',
                  _bidAlertsEnabled,
                  _saveBidAlertsSetting,
                ),
                _buildSwitchTile(
                  theme,
                  Icons.email_outlined,
                  'Email Updates',
                  'Receive email notifications',
                  _emailUpdatesEnabled,
                  _saveEmailUpdatesSetting,
                ),

                const Divider(height: 32),

                _buildSectionHeader(theme, 'Appearance'),
                _buildSwitchTile(
                  theme,
                  Icons.dark_mode_outlined,
                  'Dark Mode',
                  'Use dark theme',
                  _darkModeEnabled,
                  _saveDarkModeSetting,
                ),
                _buildActionTile(
                  theme,
                  Icons.language_outlined,
                  'Language',
                  _selectedLanguage,
                  _showLanguageDialog,
                ),

                const Divider(height: 32),

                _buildSectionHeader(theme, 'Security'),
                _buildSwitchTile(
                  theme,
                  Icons.fingerprint_outlined,
                  'Biometric Login',
                  'Use fingerprint or face ID',
                  _biometricEnabled,
                  _saveBiometricSetting,
                ),
                _buildActionTile(
                  theme,
                  Icons.lock_outline,
                  'Change Password',
                  'Update your password',
                  () => context.push('/profile/edit'),
                ),

                const Divider(height: 32),

                _buildSectionHeader(theme, 'Data and Storage'),
                _buildActionTile(
                  theme,
                  Icons.delete_sweep_outlined,
                  'Clear Cache',
                  'Free up storage space',
                  _clearCache,
                ),

                const Divider(height: 32),

                _buildSectionHeader(theme, 'About'),
                _buildActionTile(
                  theme,
                  Icons.info_outline,
                  'About ZUBID',
                  'Version 1.0.0',
                  () => _showAboutDialog(),
                ),
                _buildActionTile(
                  theme,
                  Icons.description_outlined,
                  'Terms of Service',
                  'View terms and conditions',
                  () => context.push('/terms-of-service'),
                ),
                _buildActionTile(
                  theme,
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  'View privacy policy',
                  () => context.push('/privacy-policy'),
                ),
                _buildActionTile(
                  theme,
                  Icons.help_outline,
                  'Help and Support',
                  'Get help with ZUBID',
                  () => context.push('/help'),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Sign Out',
                        style: TextStyle(color: Colors.red)),
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

  Widget _buildUserHeader(ThemeData theme) {
    final profile = ref.watch(currentProfileProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              profile?.username.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.username ?? 'User',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profile?.email ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'ZUBID',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.gavel,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'ZUBID is a modern auction platform that connects buyers and sellers in a secure and transparent marketplace.',
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2024 ZUBID. All rights reserved.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title,
          style: theme.textTheme.titleSmall?.copyWith(
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
          children: ['English', 'Arabic', 'Kurdish']
              .map((lang) => ListTile(
                    title: Text(lang),
                    trailing: _selectedLanguage == lang
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveLanguageSetting(lang);
                    },
                  ))
              .toList(),
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
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Cache cleared successfully')));
              },
              child: const Text('Clear')),
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
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
