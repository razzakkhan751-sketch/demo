// ──────────────────────────────────────────────────────────
// teacher_dashboard_screen.dart — Teacher Panel Main Screen
// ──────────────────────────────────────────────────────────
// Shows: Quick actions, course management, live classes, notes
// Navigation: Uses AppDrawer for side menu
// ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_drawer.dart';
import '../admin/admin_manage_content_screen.dart';
import '../live_classes_screen.dart';
import '../courses_screen.dart';
import '../notes_screen.dart';
import '../profile_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Section ───
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1E2E), const Color(0xFF2D2D44)]
                      : [
                          theme.primaryColor,
                          theme.primaryColor.withValues(alpha: 0.85),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    offset: const Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top bar: Menu + Profile avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const Scaffold(body: ProfileScreen()),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white24,
                          child: Text(
                            (user?.name.isNotEmpty == true)
                                ? user!.name[0].toUpperCase()
                                : "T",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Welcome text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Teacher Dashboard",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Welcome, ${user?.name ?? 'Teacher'}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Quick Actions Section ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Quick Actions",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // My Courses card
                  _buildTeacherCard(
                    context,
                    "My Courses",
                    "Manage your active courses",
                    Icons.library_books_rounded,
                    [const Color(0xFF6C63FF), const Color(0xFF8E2DE2)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminManageContentScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Schedule Live Classes
                  _buildTeacherCard(
                    context,
                    "Live Classes",
                    "Schedule a new session",
                    Icons.video_camera_front_rounded,
                    [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LiveClassesScreen(),
                      ),
                    ),
                    fullWidth: true,
                  ),
                  const SizedBox(height: 16),

                  // Browse All Courses
                  _buildTeacherCard(
                    context,
                    "Browse All Courses",
                    "Watch all library videos",
                    Icons.explore_rounded,
                    [const Color(0xFF1de9b6), const Color(0xFF1dc4e9)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoursesScreen()),
                    ),
                    fullWidth: true,
                  ),
                  const SizedBox(height: 16),

                  // Study Notes
                  _buildTeacherCard(
                    context,
                    "Browse Study Notes",
                    "Read all library notes",
                    Icons.note_alt_rounded,
                    [const Color(0xFFFF512F), const Color(0xFFDD2476)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotesScreen()),
                    ),
                    fullWidth: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ─── Info Card ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.blue[100]!,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: isDark ? Colors.blue[300] : Colors.blue,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "More features coming soon!",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.blue[300] : Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You'll soon be able to upload videos directly and manage your own student community.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.grey[400] : Colors.blueGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Builds a gradient action card for teacher quick actions
  Widget _buildTeacherCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap, {
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
