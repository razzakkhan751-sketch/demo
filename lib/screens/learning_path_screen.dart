import 'package:flutter/material.dart';
import '../models/learning_path.dart';
import '../models/course.dart';
import 'course_detail_screen.dart';
import '../services/database_service.dart';

class LearningPathScreen extends StatelessWidget {
  final LearningPath learningPath;

  const LearningPathScreen({super.key, required this.learningPath});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                learningPath.title,
                style: const TextStyle(fontSize: 16),
              ),
              background: learningPath.thumbnail.isNotEmpty
                  ? Image.network(learningPath.thumbnail, fit: BoxFit.cover)
                  : Container(
                      color: Colors.deepPurple,
                      child: const Center(
                        child: Icon(Icons.map, size: 50, color: Colors.white),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    learningPath.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Your Roadmap",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final courseId = learningPath.courseIds[index];
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: db.query(
                  'courses',
                  where: 'id = ?',
                  whereArgs: [courseId],
                  limit: 1,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text("Loading course..."),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }

                  final course = Course.fromMap(snapshot.data!.first, courseId);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailScreen(course: course),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 2,
                                height: 30,
                                color: index == 0
                                    ? Colors.transparent
                                    : Colors.grey[300],
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 30,
                                color:
                                    index == learningPath.courseIds.length - 1
                                    ? Colors.transparent
                                    : Colors.grey[300],
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${course.lessons.length} Lessons • ${course.level}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }, childCount: learningPath.courseIds.length),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}
