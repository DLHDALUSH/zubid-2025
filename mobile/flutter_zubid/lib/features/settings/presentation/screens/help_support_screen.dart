import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.support_agent,
                  size: 64,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'How can we help you?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re here to assist you with any questions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Help options
          _buildHelpItem(
            context,
            icon: Icons.quiz_outlined,
            title: 'FAQs',
            subtitle: 'Find answers to common questions',
            onTap: () => _openUrl('https://zubid.app/faq'),
          ),
          _buildHelpItem(
            context,
            icon: Icons.menu_book_outlined,
            title: 'User Guide',
            subtitle: 'Learn how to use ZUBID',
            onTap: () => _openUrl('https://zubid.app/guide'),
          ),
          _buildHelpItem(
            context,
            icon: Icons.email_outlined,
            title: 'Contact Support',
            subtitle: 'Get help from our support team',
            onTap: () => _sendEmail(
              context,
              'support@zubid.app',
              'ZUBID Support Request',
            ),
          ),
          _buildHelpItem(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            subtitle: 'Help us improve by reporting issues',
            onTap: () => _sendEmail(
              context,
              'bugs@zubid.app',
              'Bug Report - ZUBID App',
            ),
          ),
          _buildHelpItem(
            context,
            icon: Icons.lightbulb_outlined,
            title: 'Feature Request',
            subtitle: 'Suggest new features',
            onTap: () => _sendEmail(
              context,
              'features@zubid.app',
              'Feature Request - ZUBID App',
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Contact info
          Text(
            'Contact Us',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildContactItem(
            context,
            icon: Icons.email,
            label: 'support@zubid.app',
            onTap: () =>
                _sendEmail(context, 'support@zubid.app', 'ZUBID Inquiry'),
          ),
          _buildContactItem(
            context,
            icon: Icons.language,
            label: 'www.zubid.app',
            onTap: () => _openUrl('https://zubid.app'),
          ),
          _buildContactItem(
            context,
            icon: Icons.phone,
            label: '+964 750 123 4567',
            onTap: () => _makePhoneCall('+9647501234567'),
          ),

          const SizedBox(height: 32),

          // App version
          Center(
            child: Text(
              'ZUBID Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(
      BuildContext context, String email, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email app available')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
