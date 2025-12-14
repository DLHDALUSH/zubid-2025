import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Support
          _buildSection(context, 'Contact Support', isDark, [
            _buildTile(Icons.email, 'Email Us', 'support@zubid.com', () {}),
            _buildTile(Icons.phone, 'Call Us', '+1 234 567 890', () {}),
            _buildTile(Icons.chat, 'Live Chat', 'Available 24/7', () {}),
          ]),
          const SizedBox(height: 16),

          // FAQs
          _buildSection(context, 'FAQs', isDark, [
            _buildExpandableTile('How do I place a bid?',
                'To place a bid, go to any auction page and enter your bid amount in the field at the bottom. Make sure your bid is higher than the current bid.'),
            _buildExpandableTile('How does Buy Now work?',
                'Buy Now allows you to purchase an item immediately at a fixed price without waiting for the auction to end.'),
            _buildExpandableTile('What payment methods are accepted?',
                'We accept credit cards, debit cards, and digital wallets including Apple Pay and Google Pay.'),
            _buildExpandableTile('How do I track my bids?',
                'Go to the "My Bids" tab in the app to see all your active and past bids.'),
            _buildExpandableTile('What if I win an auction?',
                'You will receive a notification when you win. Payment is due within 24 hours, and the seller will ship the item to you.'),
            _buildExpandableTile('How do I contact a seller?',
                'On any auction page, click the "Message" button next to the seller\'s name to start a conversation.'),
          ]),
          const SizedBox(height: 16),

          // Quick Actions
          _buildSection(context, 'Quick Actions', isDark, [
            _buildTile(Icons.bug_report, 'Report a Bug', 'Help us improve', () => _showReportDialog(context, 'Bug Report')),
            _buildTile(Icons.feedback, 'Send Feedback', 'We value your opinion', () => _showReportDialog(context, 'Feedback')),
            _buildTile(Icons.policy, 'Terms of Service', 'Read our terms', () {}),
            _buildTile(Icons.privacy_tip, 'Privacy Policy', 'Your data is safe', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, bool isDark, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildExpandableTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [Text(answer, style: const TextStyle(color: Colors.grey))],
    );
  }

  void _showReportDialog(BuildContext context, String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(hintText: 'Enter your $type here...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$type submitted. Thank you!'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

