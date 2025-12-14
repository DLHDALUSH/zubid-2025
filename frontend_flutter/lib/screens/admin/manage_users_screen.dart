import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final List<Map<String, dynamic>> _users = [
    {'id': 1, 'username': 'john_doe', 'email': 'john@example.com', 'is_admin': false, 'status': 'active'},
    {'id': 2, 'username': 'jane_smith', 'email': 'jane@example.com', 'is_admin': false, 'status': 'active'},
    {'id': 3, 'username': 'admin', 'email': 'admin@zubid.com', 'is_admin': true, 'status': 'active'},
    {'id': 4, 'username': 'bob_wilson', 'email': 'bob@example.com', 'is_admin': false, 'status': 'suspended'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isAdmin = user['is_admin'] == true;
          final isSuspended = user['status'] == 'suspended';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdmin ? Colors.purple : AppColors.primary,
                child: Text(user['username'][0].toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
              title: Row(
                children: [
                  Text(user['username']),
                  if (isAdmin) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Admin', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'], style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSuspended ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(isSuspended ? 'Suspended' : 'Active', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Row(children: [
                      Icon(isSuspended ? Icons.check_circle : Icons.block),
                      const SizedBox(width: 8),
                      Text(isSuspended ? 'Activate' : 'Suspend'),
                    ]),
                  ),
                  if (!isAdmin)
                    const PopupMenuItem(
                      value: 'make_admin',
                      child: Row(children: [Icon(Icons.admin_panel_settings), SizedBox(width: 8), Text('Make Admin')]),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'toggle_status') {
                    setState(() => user['status'] = isSuspended ? 'active' : 'suspended');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ${isSuspended ? 'activated' : 'suspended'}')));
                  } else if (value == 'make_admin') {
                    setState(() => user['is_admin'] = true);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User promoted to admin')));
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, index);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _users.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

