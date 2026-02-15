// ──────────────────────────────────────────────────────────
// profile_screen.dart — User Profile & Settings
// ──────────────────────────────────────────────────────────
// Shows: User avatar, name, email, profile actions
// Available to: All roles (student, teacher, admin)
// Admin-only: Link to Admin Dashboard
// ──────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'progress_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'my_content_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ─── Profile Avatar ───
          Center(
            child: Builder(
              builder: (context) {
                ImageProvider? provider;
                if (user?.photoUrl.isNotEmpty == true) {
                  if (user!.photoUrl.startsWith('http')) {
                    provider = NetworkImage(user.photoUrl);
                  } else {
                    provider = FileImage(File(user.photoUrl));
                  }
                }
                return CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: provider,
                  child: provider == null
                      ? Icon(Icons.person, size: 60, color: theme.primaryColor)
                      : null,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ─── User Name & Email ───
          Text(
            user?.name.isNotEmpty == true ? user!.name : "User",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user?.email ?? "user@example.com",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),

          // Role badge
          if (user?.role != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user!.role.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ─── Edit Profile Button ───
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Edit Profile"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(200, 44),
            ),
          ),

          const SizedBox(height: 10),

          // ─── Change Password Button ───
          OutlinedButton.icon(
            onPressed: () => _showChangePasswordDialog(context),
            icon: const Icon(Icons.lock_reset, size: 18),
            label: const Text("Change Password"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(200, 44),
            ),
          ),

          const SizedBox(height: 30),

          // ─── Profile Menu Items ───
          _buildProfileItem(
            context,
            Icons.upload_file,
            "My Contributions",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyContentScreen()),
              );
            },
            isDark: isDark,
            theme: theme,
          ),
          _buildProfileItem(
            context,
            Icons.history,
            "History & Progress",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
            isDark: isDark,
            theme: theme,
          ),
          _buildProfileItem(
            context,
            Icons.notifications_outlined,
            "Notifications",
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("No new notifications"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: isDark ? const Color(0xFF252540) : null,
                ),
              );
            },
            isDark: isDark,
            theme: theme,
          ),

          // Delete Account — not shown for master admin
          if (user?.email != 'admin@admin.com')
            _buildProfileItem(
              context,
              Icons.delete_forever,
              "Delete Account",
              () => _showDeleteAccountDialog(context),
              isDark: isDark,
              theme: theme,
              isDestructive: true,
            ),

          _buildProfileItem(
            context,
            Icons.settings_outlined,
            "Settings",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            isDark: isDark,
            theme: theme,
          ),
          _buildProfileItem(
            context,
            Icons.help_outline,
            "Help & Support",
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Contact: support@sketchlearn.com"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: isDark ? const Color(0xFF252540) : null,
                ),
              );
            },
            isDark: isDark,
            theme: theme,
          ),

          // ─── Admin Section (only for admin role) ───
          if (user?.role == 'admin') ...[
            const Divider(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Administrative",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildProfileItem(
              context,
              Icons.admin_panel_settings,
              "Admin Dashboard",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                  ),
                );
              },
              isDark: isDark,
              theme: theme,
            ),
          ],

          const Divider(height: 40),

          // ─── Logout Button ───
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  /// Builds a single profile menu item card
  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    required bool isDark,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isDark ? const Color(0xFF252540) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : theme.primaryColor,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[500],
        ),
        onTap: onTap,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // DIALOGS
  // ──────────────────────────────────────────────────────────

  /// Shows a confirmation dialog before logging out
  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<AuthService>(context, listen: false).signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  /// Shows a confirmation dialog before deleting the account
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text(
          "This action is permanent and cannot be undone.\n"
          "All your progress will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                await authService.deleteAccount();
                navigator.pushNamedAndRemoveUntil('/', (route) => false);
              } catch (e) {
                // Handle re-authentication requirement
                String msg = "Error deleting account: $e";
                if (e.toString().contains('requires-recent-login') ||
                    e.toString().contains('sensitive')) {
                  msg =
                      "Please log in again to confirm deletion. Logging out...";
                  messenger.showSnackBar(SnackBar(content: Text(msg)));
                  await Future.delayed(const Duration(seconds: 2));
                  await authService.signOut();
                  navigator.pushNamedAndRemoveUntil('/', (route) => false);
                  return;
                }
                messenger.showSnackBar(
                  SnackBar(content: Text(msg), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Delete Forever"),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog to change the user's password
  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Current Password",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirm New Password",
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final current = currentPasswordController.text.trim();
                          final newPass = newPasswordController.text.trim();
                          final confirm = confirmPasswordController.text.trim();

                          // Validation
                          if (current.isEmpty || newPass.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all fields"),
                              ),
                            );
                            return;
                          }
                          if (newPass != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match"),
                              ),
                            );
                            return;
                          }
                          if (newPass.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Password must be at least 6 characters",
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => isLoading = true);
                          try {
                            final authService = Provider.of<AuthService>(
                              context,
                              listen: false,
                            );
                            await authService.changePassword(newPass);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password changed successfully!",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AuthService.getAuthErrorMessage(e),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            setState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
