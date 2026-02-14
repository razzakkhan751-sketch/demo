import 'package:flutter/foundation.dart';
import 'seed_c_course.dart';
import 'seed_cpp_course.dart';
import 'seed_java_course.dart';
import 'seed_python_course.dart';
import 'seed_javascript_course.dart';
import 'seed_kotlin_course.dart';
import 'seed_dart_course.dart';
import 'seed_php_course.dart';
import 'seed_sql_course.dart';
import 'seed_swift_course.dart';
import 'seed_notes.dart';

class SeedingCoordinator {
  static final SeedingCoordinator _instance = SeedingCoordinator._internal();
  factory SeedingCoordinator() => _instance;
  SeedingCoordinator._internal();

  bool _isSeeding = false;
  bool _fullySuccessful = false;

  Future<void> init({bool force = false}) async {
    if (_fullySuccessful && !force) return;
    if (_isSeeding) return;

    _isSeeding = true;
    debugPrint(
      "🚀 [SeedingCoordinator] Starting content synchronization (Force: $force)...",
    );

    try {
      // 1. Run infrastructure and notes
      debugPrint("🌱 [SeedingCoordinator] Phase 1: Notes Seeding...");
      await ensureNotesExist();

      // 2. Run all language-specific courses sequentially (Tree structure)
      debugPrint("🌱 [SeedingCoordinator] Phase 2: Course Content Seeding...");
      const timeout = Duration(seconds: 60);

      final courses = [
        ('C', () => ensureCCourseExists(timeout: timeout)),
        ('C++', () => ensureCppCourseExists(timeout: timeout)),
        ('Java', () => ensureJavaCourseExists(timeout: timeout)),
        ('Python', () => ensurePythonCourseExists(timeout: timeout)),
        ('Javascript', () => ensureJavascriptCourseExists(timeout: timeout)),
        ('Kotlin', () => ensureKotlinCourseExists(timeout: timeout)),
        ('Dart', () => ensureDartCourseExists(timeout: timeout)),
        ('PHP', () => ensurePHPCourseExists(timeout: timeout)),
        ('SQL', () => ensureSQLCourseExists(timeout: timeout)),
        ('Swift', () => ensureSwiftCourseExists(timeout: timeout)),
      ];

      final futures = courses.map((course) async {
        debugPrint("📘 [SeedingCoordinator] Processing ${course.$1} Tree...");
        await course.$2();
        debugPrint("✅ [SeedingCoordinator] ${course.$1} complete.");
      });

      await Future.wait(futures);

      _fullySuccessful = true;
      debugPrint("🏁 [SeedingCoordinator] All content synced to Firestore.");
    } catch (e) {
      debugPrint("🔴 [SeedingCoordinator] Sync Error: $e");
      // Don't set fullySuccessful so it can retry on next login or manual trigger
    } finally {
      _isSeeding = false;
    }
  }
}
