import '../services/database_service.dart';
import 'package:flutter/foundation.dart';

Future<void> seedCourse(
  Map<String, dynamic> courseData, {
  Duration? timeout,
}) async {
  try {
    final db = DatabaseService();
    final title = courseData['title'];
    final category = courseData['category'];

    // Extract sub-collection data for Tree hierarchy
    final List<dynamic> lessons = List.from(courseData['lessons'] ?? []);
    final List<dynamic> questions = List.from(courseData['questions'] ?? []);

    // Remove them from main document to keep it clean (Tree structure)
    courseData.remove('lessons');
    courseData.remove('questions');

    // Add metadata flags for UI optimization (Avoid unnecessary sub-collection fetches)
    courseData['has_lessons'] = lessons.isNotEmpty;
    courseData['has_questions'] = questions.isNotEmpty;

    final existing = await db.query(
      'courses',
      where: 'title = ? AND category = ?',
      whereArgs: [title, category],
      limit: 1,
      timeout: timeout,
    );

    String courseId;
    if (existing.isNotEmpty) {
      courseId = existing.first['id'];
      debugPrint("Updating existing course: $title ($courseId)");
      await db.update('courses', courseData, docId: courseId, timeout: timeout);
    } else {
      courseId =
          courseData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint("Seeding new course: $title ($courseId)");
      await db.insert('courses', courseData, docId: courseId, timeout: timeout);
    }

    // Seed Lessons as sub-collection using high-speed Batch
    if (lessons.isNotEmpty) {
      debugPrint(
        "📦 [SeedHelper] Batch seeding ${lessons.length} lessons for $courseId",
      );
      await db.batchInsert(
        'courses/$courseId/lessons',
        lessons.cast<Map<String, dynamic>>(),
        docIdGenerator: (index) => 'lesson_$index',
        timeout: timeout,
      );
    }

    // Seed Questions as sub-collection using high-speed Batch
    if (questions.isNotEmpty) {
      debugPrint(
        "📦 [SeedHelper] Batch seeding ${questions.length} questions for $courseId",
      );
      await db.batchInsert(
        'courses/$courseId/questions',
        questions.cast<Map<String, dynamic>>(),
        docIdGenerator: (index) => 'question_$index',
        timeout: timeout,
      );
    }
  } catch (e) {
    debugPrint("Error seeding course ${courseData['title']}: $e");
  }
}
