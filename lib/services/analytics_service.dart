import 'database_service.dart';

class AnalyticsService {
  final DatabaseService _db = DatabaseService();

  Future<Map<String, int>> getCounts() async {
    try {
      final users = await _db.query('users');
      final courses = await _db.query('courses');
      final liveClasses = await _db.query('live_classes');

      return {
        'users': users.length,
        'courses': courses.length,
        'live_classes': liveClasses.length,
      };
    } catch (e) {
      return {'users': 0, 'courses': 0, 'live_classes': 0};
    }
  }

  Future<Map<String, int>> getUserRoleDistribution() async {
    try {
      final response = await _db.query('profiles');

      int students = 0;
      int admins = 0;
      int teachers = 0;

      for (var row in response) {
        final role = row['role'] as String? ?? 'student';
        if (role == 'admin') {
          admins++;
        } else if (role == 'teacher') {
          teachers++;
        } else {
          students++;
        }
      }

      return {'Student': students, 'Admin': admins, 'Teacher': teachers};
    } catch (e) {
      return {'Student': 0, 'Admin': 0, 'Teacher': 0};
    }
  }

  Future<Map<String, int>> getCourseCategoryDistribution() async {
    try {
      final response = await _db.query('courses');
      final Map<String, int> distribution = {};

      for (var row in response) {
        final category = row['category'] as String? ?? 'Uncategorized';
        distribution[category] = (distribution[category] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      return {};
    }
  }
}
