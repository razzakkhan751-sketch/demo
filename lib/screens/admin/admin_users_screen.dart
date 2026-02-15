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
                    Flexible(
                      child: Text(
                        '${user.email} • ',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildRoleBadge(user),
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
                              : user.role == 'teacher'
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        tooltip: 'Change Role',
                        onSelected: (String role) =>
                            _changeRole(context, authService, user, role),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'student',
                            child: ListTile(
                              leading: Icon(Icons.school, color: Colors.blue),
                              title: Text('Student'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'teacher',
                            child: ListTile(
                              leading: Icon(
                                Icons.cast_for_education,
                                color: Colors.orange,
                              ),
                              title: Text('Teacher'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'admin',
                            child: ListTile(
                              leading: Icon(
                                Icons.admin_panel_settings,
                                color: Colors.red,
                              ),
                              title: Text('Admin'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
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

  Widget _buildRoleBadge(UserModel user) {
    Color color;
    String label;
    switch (user.role) {
      case 'admin':
        color = Colors.red;
        label = 'Admin';
        break;
      case 'teacher':
        color = Colors.orange;
        label = 'Teacher';
        break;
      case 'student':
        color = Colors.blue;
        label = 'Student';
        break;
      default:
        color = Colors.grey;
        label = 'Pending';
        if (user.requestedRole != null) {
          label += ' (${user.requestedRole})';
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
      } else if (role == 'teacher') {
        await authService.promoteToTeacher(user.uid);
      } else {
        await authService.demoteToStudent(user.uid);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Role updated to ${role.toUpperCase()}.")),
        );
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
