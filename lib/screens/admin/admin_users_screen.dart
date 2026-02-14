import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import 'package:provider/provider.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.streamCollection('users'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          debugPrint(
            "🔍 [AdminUsersScreen] snapshot.hasData=${snapshot.hasData}, length=${snapshot.data?.length ?? 0}",
          );

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            final raw = snapshot.data ?? [];
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No users found.'),
                    const SizedBox(height: 8),
                    Text(
                      'Debug: ${jsonEncode(raw)}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final usersData = snapshot.data!;
          debugPrint(
            "🔍 [AdminUsersScreen] Parsing ${usersData.length} users...",
          );

          final users = <UserModel>[];
          for (var data in usersData) {
            try {
              users.add(UserModel.fromMap(data, data['id']));
            } catch (e) {
              debugPrint(
                "🔴 [AdminUsersScreen] Skipped corrupted user: ${data['id']} - $e",
              );
            }
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                title: Text(user.name),
                subtitle: Row(
                  children: [
                    Text('${user.email} • '),
                    if (user.role == 'pending')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'Pending Choice',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(user.role),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        user.isBanned
                            ? Icons.block
                            : Icons.check_circle_outline,
                        color: user.isBanned ? Colors.red : Colors.green,
                      ),
                      onPressed: user.email == 'admin@admin.com'
                          ? null
                          : () => _toggleBan(context, authService, user),
                      tooltip: user.isBanned ? 'Unban' : 'Ban',
                    ),
                    if (user.email != 'admin@admin.com') ...[
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.badge,
                          color: user.role == 'admin'
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onSelected: (String role) =>
                            _changeRole(context, authService, user, role),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'student',
                            child: Text('Student'),
                          ),
                          const PopupMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, authService, user),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _toggleBan(
    BuildContext context,
    AuthService authService,
    UserModel user,
  ) async {
    try {
      if (user.isBanned) {
        await authService.unbanUser(user.uid);
      } else {
        await authService.banUser(user.uid);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Action completed.")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _changeRole(
    BuildContext context,
    AuthService authService,
    UserModel user,
    String role,
  ) async {
    try {
      if (role == 'admin') {
        await authService.promoteToAdmin(user.uid);
      } else {
        await authService.demoteFromAdmin(user.uid);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Role updated.")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _confirmDelete(
    BuildContext context,
    AuthService authService,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Delete ${user.name}? This is permanent."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await authService.deleteUser(user.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User deleted.")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
