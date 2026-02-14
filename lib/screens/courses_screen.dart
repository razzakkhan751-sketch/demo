import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'admin/admin_add_course_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'course_detail_screen.dart';
import 'category_courses_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  final List<Map<String, dynamic>> _codingLanguages = const [
    {"name": "C", "color": Color(0xFF555555), "icon": Icons.code},
    {
      "name": "C++",
      "color": Color(0xFF00599C),
      "icon": Icons.integration_instructions,
    },
    {"name": "Java", "color": Color(0xFF007396), "icon": Icons.coffee},
    {"name": "Python", "color": Color(0xFFFFD43B), "icon": Icons.pest_control},
    {
      "name": "JavaScript",
      "color": Color(0xFFF7DF1E),
      "icon": Icons.javascript,
    },
    {"name": "Kotlin", "color": Color(0xFF7F52FF), "icon": Icons.android},
    {"name": "Dart", "color": Color(0xFF0175C2), "icon": Icons.flutter_dash},
    {"name": "PHP", "color": Color(0xFF777BB4), "icon": Icons.php},
    {"name": "SQL", "color": Color(0xFF4479A1), "icon": Icons.table_chart},
    {"name": "Swift", "color": Color(0xFFFA7343), "icon": Icons.bolt},
  ];

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final userModel = Provider.of<AuthService>(context).userModel;
    final isAdmin = userModel?.role == 'admin';
    final isTeacher = userModel?.role == 'teacher';
    final canManage = isAdmin || isTeacher;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Explore Courses",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(
                Icons.admin_panel_settings,
                color: Colors.black87,
              ),
              tooltip: 'Admin Panel',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAddCourseScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Add Course"),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    "Browse Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategoryChip(
                        context,
                        "Coding",
                        Icons.code,
                        Colors.blue,
                      ),
                      _buildCategoryChip(
                        context,
                        "Data Science",
                        Icons.analytics,
                        Colors.indigo,
                      ),
                      _buildCategoryChip(
                        context,
                        "Cloud Computing",
                        Icons.cloud,
                        Colors.lightBlue,
                      ),
                      _buildCategoryChip(
                        context,
                        "Cyber Security",
                        Icons.security,
                        Colors.red,
                      ),
                      _buildCategoryChip(
                        context,
                        "AI & ML",
                        Icons.smart_toy,
                        Colors.deepPurple,
                      ),
                      _buildCategoryChip(
                        context,
                        "Blockchain",
                        Icons.currency_bitcoin,
                        Colors.orange,
                      ),
                      _buildCategoryChip(
                        context,
                        "DevOps",
                        Icons.adb,
                        Colors.green,
                      ),
                      _buildCategoryChip(
                        context,
                        "Design",
                        Icons.brush,
                        Colors.pink,
                      ),
                      _buildCategoryChip(
                        context,
                        "Business",
                        Icons.work,
                        Colors.teal,
                      ),
                      _buildCategoryChip(
                        context,
                        "Marketing",
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Master a Language",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _codingLanguages.length,
                    itemBuilder: (context, index) =>
                        _buildLanguageCard(context, _codingLanguages[index]),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Courses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: db.streamCollection('courses'),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text("Error: ${snapshot.error}")),
                );
              }
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              final courses = snapshot.data!
                  .map((data) => Course.fromMap(data, data['id']))
                  .toList();
              if (courses.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          Icons.library_books,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No courses available yet",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: _buildCourseCard(
                      context,
                      courses[index],
                      isAdmin,
                      userModel?.uid,
                    ),
                  );
                }, childCount: courses.length),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, Map<String, dynamic> lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryCoursesScreen(categoryName: lang['name']),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (lang['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(lang['icon'], color: lang['color'], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lang['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Course course,
    bool isAdmin,
    String? currentUserId,
  ) {
    final isAuthor = course.authorId == currentUserId;
    final showManagementItems = isAdmin || (isAuthor);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(course: course),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: (course.thumbnail.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: course.thumbnail,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.grey,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              ),
                            )
                          : Container(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                              child: Icon(
                                Icons.school,
                                size: 40,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.5),
                              ),
                            ),
                    ),
                  ),
                  if (showManagementItems)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          _buildActionCircle(
                            Icons.edit,
                            Colors.orange,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminAddCourseScreen(course: course),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionCircle(Icons.delete, Colors.red, () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Course?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancel"),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                  TextButton(
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () async {
                                      await DatabaseService().delete(
                                        'courses',
                                        docId: course.id,
                                      );
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      // Note: Since CoursesScreen uses a FutureBuilder,
                                      // we might need a refresh mechanism or setState here.
                                      // For now, simpler to just refresh the screen.
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (course.authorName.isNotEmpty)
                      Text(
                        "by ${course.authorName}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${course.lessons.length} Lessons",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Start Learning",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color),
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryCoursesScreen(categoryName: title),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
