import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/course.dart';
import 'admin_users_screen.dart';
import 'admin_add_course_screen.dart';
import 'admin_notes_screen.dart';

class AdminManageContentScreen extends StatefulWidget {
  const AdminManageContentScreen({super.key});

  @override
  State<AdminManageContentScreen> createState() =>
      _AdminManageContentScreenState();
}

class _AdminManageContentScreenState extends State<AdminManageContentScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Initially we don't know the length, but we can compute it from context if needed.
    // However, it's easier to just use DefaultTabController logic unless we need the FAB to change.
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    final isAdmin = user?.role == 'admin';
    final isTeacher = user?.role == 'teacher';
    final canManage = isAdmin || isTeacher;

    if (!canManage) {
      return Scaffold(
        appBar: AppBar(title: const Text("Access Denied")),
        body: const Center(
          child: Text("Only Teachers and Admins can manage content."),
        ),
      );
    }

    final isTeacherOnly = isTeacher;
    final tabCount = isTeacherOnly ? 2 : 3;

    return DefaultTabController(
      length: tabCount,
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(
                isTeacherOnly ? "Teacher Dashboard" : "Manage Users & Content",
              ),
              actions: const [],
              bottom: TabBar(
                tabs: [
                  if (!isTeacherOnly)
                    const Tab(text: "Users", icon: Icon(Icons.people)),
                  const Tab(text: "Courses", icon: Icon(Icons.video_library)),
                  const Tab(text: "Notes", icon: Icon(Icons.note)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                if (!isTeacherOnly) const AdminUsersScreen(),
                const AdminManageCoursesList(),
                const AdminNotesScreen(),
              ],
            ),
            floatingActionButton: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                // If isTeacherOnly, index 0 is Courses, index 1 is Notes.
                // If Admin, index 0 is Users, index 1 is Courses, index 2 is Notes.
                final currentIndex = controller.index;
                final isCoursesTab = isTeacherOnly
                    ? currentIndex == 0
                    : currentIndex == 1;
                final isNotesTab = isTeacherOnly
                    ? currentIndex == 1
                    : currentIndex == 2;

                if (isCoursesTab) {
                  return FloatingActionButton.extended(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAddCourseScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("New Course"),
                    heroTag: 'add_course_fab',
                  );
                } else if (isNotesTab) {
                  // AdminNotesScreen already has its own FAB?
                  // Let's check.
                  return const SizedBox.shrink();
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}

class AdminManageCoursesList extends StatelessWidget {
  const AdminManageCoursesList({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final user = Provider.of<AuthService>(context).userModel;
    final isTeacher = user?.role == 'teacher';

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: isTeacher
          ? db.streamCollection(
              'courses',
              where: 'authorId = ?',
              whereArgs: [user!.uid],
            )
          : db.streamCollection('courses'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text("No courses available to manage."));
        }

        // Group courses by category
        final Map<String, List<Map<String, dynamic>>> groupedCourses = {};
        for (var item in data) {
          final category = item['category'] ?? 'Uncategorized';
          if (!groupedCourses.containsKey(category)) {
            groupedCourses[category] = [];
          }
          groupedCourses[category]!.add(item);
        }

        final sortedCategories = groupedCourses.keys.toList()..sort();

        return ListView.builder(
          itemCount: sortedCategories.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final category = sortedCategories[index];
            final categoryCourses = groupedCourses[category]!;

            return ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.deepPurple,
                ),
              ),
              children: categoryCourses.map((item) {
                final course = Course.fromMap(item, item['id']);
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: course.thumbnail.isNotEmpty
                          ? Image.network(
                              course.thumbnail,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.school),
                            ),
                    ),
                    title: Text(
                      course.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${course.lessons.length} Lessons"),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminAddCourseScreen(course: course),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
