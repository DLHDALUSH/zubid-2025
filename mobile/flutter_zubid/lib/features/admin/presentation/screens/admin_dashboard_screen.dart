import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load admin stats when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    ref.read(adminProvider.notifier).refreshStats();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.gavel), text: 'Auctions'),
            Tab(icon: Icon(Icons.analytics), text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(theme),
          _buildUsersTab(theme),
          _buildAuctionsTab(theme),
          _buildReportsTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    final adminState = ref.watch(adminProvider);

    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            Text(
              'Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (adminState.isLoading && !adminState.hasStats)
              const Center(child: CircularProgressIndicator())
            else if (adminState.hasError)
              Center(
                child: Column(
                  children: [
                    Text('Error: ${adminState.error}'),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Users',
                      value: adminState.stats?.totalUsers.toString() ?? '0',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Active Auctions',
                      value: adminState.stats?.activeAuctions.toString() ?? '0',
                      icon: Icons.gavel,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Auctions',
                      value: adminState.stats?.totalAuctions.toString() ?? '0',
                      icon: Icons.gavel_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Bids',
                      value: adminState.stats?.totalBids.toString() ?? '0',
                      icon: Icons.trending_up,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  title: 'Manage Users',
                  icon: Icons.people_outline,
                  onTap: () {
                    _tabController.animateTo(1);
                  },
                ),
                _buildActionCard(
                  title: 'Manage Auctions',
                  icon: Icons.gavel_outlined,
                  onTap: () {
                    _tabController.animateTo(2);
                  },
                ),
                _buildActionCard(
                  title: 'Create Auction',
                  icon: Icons.add_circle_outline,
                  onTap: () {
                    context.push('/auctions/create');
                  },
                ),
                _buildActionCard(
                  title: 'View Reports',
                  icon: Icons.analytics_outlined,
                  onTap: () {
                    _tabController.animateTo(3);
                  },
                ),
                _buildActionCard(
                  title: 'System Settings',
                  icon: Icons.settings_outlined,
                  onTap: () {
                    _showSettingsDialog();
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Activity
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _buildActivityItem(
                    icon: Icons.person_add,
                    title: 'New user registered',
                    subtitle: 'john.doe@email.com',
                    time: '2 minutes ago',
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    icon: Icons.gavel,
                    title: 'New auction created',
                    subtitle: 'iPhone 13 Pro - 256GB',
                    time: '15 minutes ago',
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    icon: Icons.payment,
                    title: 'Payment processed',
                    subtitle: '\$899.99 for MacBook Pro',
                    time: '1 hour ago',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Notifications ${value ? 'enabled' : 'disabled'}')),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Security settings opened')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup Data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup started')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(ThemeData theme) {
    final users = [
      {
        'name': 'John Doe',
        'email': 'john@email.com',
        'status': 'Active',
        'role': 'User'
      },
      {
        'name': 'Jane Smith',
        'email': 'jane@email.com',
        'status': 'Active',
        'role': 'Seller'
      },
      {
        'name': 'Bob Wilson',
        'email': 'bob@email.com',
        'status': 'Suspended',
        'role': 'User'
      },
      {
        'name': 'Alice Brown',
        'email': 'alice@email.com',
        'status': 'Active',
        'role': 'Admin'
      },
      {
        'name': 'Charlie Davis',
        'email': 'charlie@email.com',
        'status': 'Pending',
        'role': 'User'
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Add user feature coming soon')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user['name']![0]),
                  ),
                  title: Text(user['name']!),
                  subtitle: Text('${user['email']} • ${user['role']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: user['status'] == 'Active'
                              ? Colors.green.withValues(alpha: 0.1)
                              : user['status'] == 'Suspended'
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user['status']!,
                          style: TextStyle(
                            color: user['status'] == 'Active'
                                ? Colors.green
                                : user['status'] == 'Suspended'
                                    ? Colors.red
                                    : Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$value: ${user['name']}')),
                          );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'Edit', child: Text('Edit')),
                          const PopupMenuItem(
                              value: 'Suspend', child: Text('Suspend')),
                          const PopupMenuItem(
                              value: 'Delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuctionsTab(ThemeData theme) {
    final auctions = [
      {
        'title': 'iPhone 13 Pro',
        'seller': 'John Doe',
        'bid': '\$899',
        'status': 'Active'
      },
      {
        'title': 'MacBook Pro M2',
        'seller': 'Jane Smith',
        'bid': '\$1,299',
        'status': 'Active'
      },
      {
        'title': 'Samsung TV 65"',
        'seller': 'Bob Wilson',
        'bid': '\$650',
        'status': 'Ended'
      },
      {
        'title': 'PS5 Console',
        'seller': 'Alice Brown',
        'bid': '\$450',
        'status': 'Active'
      },
      {
        'title': 'Canon DSLR',
        'seller': 'Charlie Davis',
        'bid': '\$800',
        'status': 'Pending'
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search auctions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: 'All',
                items: ['All', 'Active', 'Ended', 'Pending']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: auctions.length,
            itemBuilder: (context, index) {
              final auction = auctions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag),
                  ),
                  title: Text(auction['title']!),
                  subtitle: Text(
                      'Seller: ${auction['seller']} • Current: ${auction['bid']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: auction['status'] == 'Active'
                              ? Colors.green.withValues(alpha: 0.1)
                              : auction['status'] == 'Ended'
                                  ? Colors.grey.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          auction['status']!,
                          style: TextStyle(
                            color: auction['status'] == 'Active'
                                ? Colors.green
                                : auction['status'] == 'Ended'
                                    ? Colors.grey
                                    : Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('$value: ${auction['title']}')),
                          );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'View', child: Text('View')),
                          const PopupMenuItem(
                              value: 'Edit', child: Text('Edit')),
                          const PopupMenuItem(
                              value: 'Feature', child: Text('Feature')),
                          const PopupMenuItem(
                              value: 'End', child: Text('End Auction')),
                          const PopupMenuItem(
                              value: 'Delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Revenue Chart Placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue (Last 7 Days)',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarChart('Mon', 0.6, Colors.blue),
                        _buildBarChart('Tue', 0.8, Colors.blue),
                        _buildBarChart('Wed', 0.5, Colors.blue),
                        _buildBarChart('Thu', 0.9, Colors.blue),
                        _buildBarChart('Fri', 0.7, Colors.blue),
                        _buildBarChart('Sat', 1.0, Colors.blue),
                        _buildBarChart('Sun', 0.4, Colors.blue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildReportCard(
                  title: 'Total Sales',
                  value: '\$24,500',
                  change: '+12%',
                  isPositive: true,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReportCard(
                  title: 'New Users',
                  value: '156',
                  change: '+8%',
                  isPositive: true,
                  icon: Icons.person_add,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildReportCard(
                  title: 'Avg. Bid',
                  value: '\$245',
                  change: '-3%',
                  isPositive: false,
                  icon: Icons.gavel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReportCard(
                  title: 'Completion',
                  value: '94%',
                  change: '+2%',
                  isPositive: true,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Export buttons
          Text('Export Reports', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting PDF report...')),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting CSV report...')),
                  );
                },
                icon: const Icon(Icons.table_chart),
                label: const Text('Export CSV'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 120 * value,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 2),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}
