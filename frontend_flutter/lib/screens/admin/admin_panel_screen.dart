import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'manage_auctions_screen.dart';
import 'manage_users_screen.dart';
import 'manage_categories_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.primaryGradientDark : AppColors.primaryGradient,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Total Auctions', '156', Icons.gavel, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Active Users', '1,234', Icons.people, Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Total Bids', '5,678', Icons.attach_money, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Revenue', '\$45.2K', Icons.trending_up, Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),

          // Management Options
          Text('Management', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildAdminTile(context, Icons.gavel, 'Manage Auctions', 'Add, edit, or delete auctions',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAuctionsScreen()))),
          _buildAdminTile(context, Icons.people, 'Manage Users', 'View and manage user accounts',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen()))),
          _buildAdminTile(context, Icons.category, 'Manage Categories', 'Add or edit auction categories',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()))),
          _buildAdminTile(context, Icons.notifications, 'Send Notification', 'Broadcast to all users', () => _showNotificationDialog(context)),
          _buildAdminTile(context, Icons.settings, 'App Settings', 'Configure app parameters', () {}),
          _buildAdminTile(context, Icons.analytics, 'View Analytics', 'Detailed reports and stats', () {}),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: bodyController, maxLines: 3, decoration: const InputDecoration(labelText: 'Message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification sent to all users!'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

