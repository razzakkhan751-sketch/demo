import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import '../models/learning_path.dart';
import 'learning_path_screen.dart';
import '../services/recommendation_service.dart';
import '../services/database_service.dart';
import 'course_detail_screen.dart';
import 'courses_screen.dart';
import 'category_courses_screen.dart';
import 'ai_tutor_screen.dart';
import 'profile_screen.dart';
import 'notes_screen.dart';
import 'progress_screen.dart';
import '../widgets/app_drawer.dart';
import 'admin/admin_manage_content_screen.dart';
import 'search/global_search_delegate.dart';
import 'chat/chat_list_screen.dart';
import 'live_classes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardTab(
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const CoursesScreen(),
          const NotesScreen(),
          const AITutorScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: "Courses",
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            selectedIcon: Icon(Icons.note_alt),
            label: "Notes",
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: "AI Tutor",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const DashboardTab({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    final theme = Theme.of(context);
    final progressService = ProgressService();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.4),
                  offset: const Offset(0, 10),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: onMenuTap,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatListScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: user?.photoUrl.isNotEmpty == true
                                ? NetworkImage(user!.photoUrl)
                                : null,
                            backgroundColor: Colors.white24,
                            child: user?.photoUrl.isEmpty ?? true
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, ${user?.name.isNotEmpty == true ? user!.name : 'Friend'}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Let's start learning!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => showSearch(
                    context: context,
                    delegate: GlobalSearchDelegate(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: theme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          "Search for everything...",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCategories(context),
          const SizedBox(height: 16),
          _buildLearningPathsHeader(),
          const SizedBox(height: 16),
          _buildLearningPathsList(context),
          const SizedBox(height: 24),
          if (user != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Continue Learning",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildContinueLearningList(context, user.uid, progressService),
            const SizedBox(height: 24),
          ],
          if (user != null) ...[
            _buildRecommendedHeader(),
            const SizedBox(height: 16),
            _buildRecommendedList(context, user.uid),
            const SizedBox(height: 24),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Featured Courses",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeaturedCoursesList(context),
          const SizedBox(height: 24),
          _buildActivityCards(context, user),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Use the Courses tab to see all!"),
                  ),
                ),
                child: const Text("See All"),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCategoryItem(context, "Coding", Icons.code, Colors.blue),
              _buildCategoryItem(
                context,
                "Data Science",
                Icons.analytics,
                Colors.indigo,
              ),
              _buildCategoryItem(
                context,
                "Cloud Computing",
                Icons.cloud,
                Colors.lightBlue,
              ),
              _buildCategoryItem(
                context,
                "Cyber Security",
                Icons.security,
                Colors.red,
              ),
              _buildCategoryItem(
                context,
                "AI & ML",
                Icons.smart_toy,
                Colors.deepPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningPathsHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(Icons.map, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text(
            "Learning Paths",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.amber),
          SizedBox(width: 8),
          Text(
            "Recommended for You",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCards(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildNewActionCard(
            context,
            "Live Classes",
            "Join upcoming sessions",
            Icons.video_camera_front,
            [Colors.redAccent, Colors.pinkAccent],
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LiveClassesScreen()),
            ),
            fullWidth: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNewActionCard(
                  context,
                  "My Progress",
                  "Track learning",
                  Icons.bar_chart_rounded,
                  [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNewActionCard(
                  context,
                  "Notes",
                  "Review key points",
                  Icons.edit_note_rounded,
                  [const Color(0xFFFF512F), const Color(0xFFDD2476)],
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotesScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user?.role == 'admin')
            _buildNewActionCard(
              context,
              "Manage Content",
              "Edit courses/user",
              Icons.settings_applications,
              [Colors.orange.shade800, Colors.orange.shade400],
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminManageContentScreen(),
                ),
              ),
              fullWidth: true,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueLearningList(
    BuildContext context,
    String uid,
    ProgressService service,
  ) {
    final db = DatabaseService();
    // Optimization: Stream courses first (or use a Future if real-time isn't needed) to avoid re-subscribing
    // to the full courses collection every time the user's progress updates.
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: db.streamCollection('courses'),
      builder: (context, coursesSnapshot) {
        if (!coursesSnapshot.hasData) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final allCourses = coursesSnapshot.data!;

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: service.getAllProgressStream(uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Show "No progress cached" or empty container only if truly empty
              // But we want to encourage them to start.
              if (!snapshot.hasData) return const SizedBox.shrink();

              if (snapshot.data!.isEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.school, color: Colors.blue),
                      SizedBox(width: 16),
                      Text("Start a course to track progress here!"),
                    ],
                  ),
                );
              }
            }

            final progressList = snapshot.data!;
            final List<Widget> items = [];

            for (var progress in progressList) {
              final courseId = progress['course_id'];
              final courseData = allCourses.firstWhere(
                (c) => c['id'] == courseId,
                orElse: () => {},
              );

              if (courseData.isEmpty) continue;

              final course = Course.fromMap(courseData, courseId);
              final percent =
                  (progress['percent_complete'] ??
                          progress['percentComplete'] as num?)
                      ?.toDouble() ??
                  0.0;
              final lastIndex =
                  (progress['last_lesson_index'] ??
                      progress['lastLessonIndex'] as int?) ??
                  0;

              items.add(
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailScreen(
                        course: course,
                        initialLessonIndex: lastIndex,
                      ),
                    ),
                  ),
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: course.thumbnail,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.school),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: percent,
                                backgroundColor: Colors.grey[200],
                                color: Colors.blueAccent,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${(percent * 100).toInt()}% Complete",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "Resume",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
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

            return SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: items,
              ),
            );
          },
        );
      },
    );
  }

  Stream<List<Course>> _getFeaturedCoursesStream(DatabaseService db) {
    return db.streamCollection('courses', limit: 10).map((list) {
      return list.map((data) => Course.fromMap(data, data['id'])).toList();
    });
  }

  Widget _buildFeaturedCoursesList(BuildContext context) {
    final db = DatabaseService();
    return StreamBuilder<List<Course>>(
      stream: _getFeaturedCoursesStream(db),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 50,
            child: Center(child: Text("No courses yet")),
          );
        }

        final courses = snapshot.data!;

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: courses.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final course = courses[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailScreen(course: course),
                    ),
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: (course.thumbnail.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: course.thumbnail,
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 110,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        height: 110,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                )
                              : Container(
                                  height: 110,
                                  color: Colors.blue[100],
                                  child: const Icon(Icons.school, size: 40),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${course.lessons.length} Lessons",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLearningPathsList(BuildContext context) {
    return FutureBuilder<List<LearningPath>>(
      future: RecommendationService().getLearningPaths(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final paths = snapshot.data!;
        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: paths.length,
            itemBuilder: (context, index) {
              final path = paths[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LearningPathScreen(learningPath: path),
                  ),
                ),
                child: Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade700,
                        Colors.deepPurple.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${path.courseIds.length} Courses • ${path.difficulty}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecommendedList(BuildContext context, String uid) {
    return FutureBuilder<List<Course>>(
      future: RecommendationService().getRecommendedCourses(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = snapshot.data!;
        if (courses.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailScreen(course: course),
                  ),
                ),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: course.thumbnail,
                          height: 100,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNewActionCard(
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
        height: 110,
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
