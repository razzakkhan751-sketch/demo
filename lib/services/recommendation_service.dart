import '../models/course.dart';
import '../models/learning_path.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';

class RecommendationService {
  final _db = DatabaseService();

  // Get learning paths
  Future<List<LearningPath>> getLearningPaths() async {
    try {
      final data = await _db.query('learning_paths');
      return data.map((map) => LearningPath.fromMap(map, map['id'])).toList();
    } catch (e) {
      debugPrint("Error fetching learning paths: $e");
      return [];
    }
  }

  // Get recommended courses based on user's enrolled courses' categories
  Future<List<Course>> getRecommendedCourses(String userId) async {
    try {
      // 1. Get user's enrolled course IDs from user_progress
      final progressData = await _db.query(
        'user_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      final enrolledCourseIds = progressData
          .map((d) => d['course_id'].toString())
          .toList();

      if (enrolledCourseIds.isEmpty) {
        return _getPopularCourses();
      }

      // 2. Fetch enrolled courses to analyze categories
      // We can't do 'where id in [...]' easily with current DatabaseService
      // but we can fetch them or fetch all if count is small.
      final allCoursesData = await _db.query('courses');
      final allCourses = allCoursesData
          .map((d) => Course.fromMap(d, d['id']))
          .toList();

      final enrolledCourses = allCourses
          .where((c) => enrolledCourseIds.contains(c.id))
          .toList();

      if (enrolledCourses.isEmpty) return _getPopularCourses();

      // Count category frequency
      final categoryFrequency = <String, int>{};
      for (var course in enrolledCourses) {
        categoryFrequency[course.category] =
            (categoryFrequency[course.category] ?? 0) + 1;
      }

      // Sort categories by frequency
      final sortedCategories = categoryFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topCategory = sortedCategories.first.key;

      // 3. Recommend courses in that category that User hasn't enrolled in
      final recommendations = allCourses.where((c) {
        return c.category == topCategory && !enrolledCourseIds.contains(c.id);
      }).toList();

      if (recommendations.isEmpty) {
        if (sortedCategories.length > 1) {
          final secondCategory = sortedCategories[1].key;
          final secondRecs = allCourses.where((c) {
            return c.category == secondCategory &&
                !enrolledCourseIds.contains(c.id);
          }).toList();
          if (secondRecs.isNotEmpty) return secondRecs;
        }
        return _getPopularCourses(excludeIds: enrolledCourseIds);
      }

      return recommendations;
    } catch (e) {
      debugPrint("Error getting recommendations: $e");
      return [];
    }
  }

  Future<List<Course>> _getPopularCourses({List<String>? excludeIds}) async {
    try {
      final data = await _db.query('courses', limit: 5);
      var courses = data.map((d) => Course.fromMap(d, d['id'])).toList();

      if (excludeIds != null) {
        courses = courses.where((c) => !excludeIds.contains(c.id)).toList();
      }
      return courses;
    } catch (e) {
      return [];
    }
  }
}
