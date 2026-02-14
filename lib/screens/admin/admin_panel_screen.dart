import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_users_screen.dart';
import 'admin_add_course_screen.dart';
import 'admin_debug_screen.dart';
import '../../services/auth_service.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show if user is admin
    final authService = Provider.of<AuthService>(context);
    final user = authService.userModel;

    // Optional: Double check if user is admin, though navigation should handle this.
    // We can also allow 'admin' role or specific email
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel"), centerTitle: true),
      body: !isAdmin
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Access Denied",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("You do not have administrative privileges."),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAdminCard(
                  context,
                  title: "Manage Users",
                  subtitle: "View, ban, or edit user accounts.",
                  icon: Icons.people_alt,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminUsersScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildAdminCard(
                  context,
                  title: "Add New Course",
                  subtitle: "Create a new course with lessons and quizzes.",
                  icon: Icons.add_box,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAddCourseScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildAdminCard(
                  context,
                  title: "🔧 Diagnostics",
                  subtitle: "Debug user list issues and Firestore connection.",
                  icon: Icons.bug_report,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDebugScreen(),
                      ),
                    );
                  },
                ),
                // Future admin features can go here
                const SizedBox(height: 16),
                _buildAdminCard(
                  context,
                  title: "System Status",
                  subtitle: "Logged in as: ${user?.email ?? 'Unknown'}",
                  icon: Icons.info_outline,
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("System is running normally."),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
