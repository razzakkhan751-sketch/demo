// ──────────────────────────────────────────────────────────
// cache_service.dart — Local Storage Cache for Offline Access
// ──────────────────────────────────────────────────────────
// Caches Firestore data in SharedPreferences as JSON
// Supports: Courses, Lessons, Questions, Notes
// TTL: 6 hours (configurable via _cacheDuration)
// Pattern: Singleton — use CacheService() anywhere
// ──────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CacheService provides local storage caching for all content types.
/// Content is cached as JSON in SharedPreferences so it loads instantly
/// on repeat visits without hitting Firebase every time.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _coursesKey = 'cached_courses';
  static const String _notesKey = 'cached_notes';
  static const String _lessonsPrefix = 'cached_lessons_';
  static const String _questionsPrefix = 'cached_questions_';
  static const String _cacheTimestampPrefix = 'cache_ts_';
  static const Duration _cacheDuration = Duration(hours: 6);

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if cache is still valid
  Future<bool> isCacheValid(String key) async {
    final p = await prefs;
    final tsKey = '$_cacheTimestampPrefix$key';
    final timestamp = p.getInt(tsKey);
    if (timestamp == null) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cachedAt) < _cacheDuration;
  }

  Future<void> _setTimestamp(String key) async {
    final p = await prefs;
    await p.setInt(
      '$_cacheTimestampPrefix$key',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ─── COURSES ───

  Future<void> cacheCourses(List<Map<String, dynamic>> courses) async {
    try {
      final p = await prefs;
      await p.setString(_coursesKey, jsonEncode(courses));
      await _setTimestamp(_coursesKey);
      debugPrint('💾 [CacheService] Cached ${courses.length} courses');
    } catch (e) {
      debugPrint('⚠️ [CacheService] Error caching courses: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedCourses() async {
    try {
      final p = await prefs;
      final data = p.getString(_coursesKey);
      if (data == null) return null;
      final list = jsonDecode(data) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('⚠️ [CacheService] Error reading cached courses: $e');
      return null;
    }
  }

  // ─── LESSONS ───

  Future<void> cacheLessons(
    String courseId,
    List<Map<String, dynamic>> lessons,
  ) async {
    try {
      final p = await prefs;
      final key = '$_lessonsPrefix$courseId';
      await p.setString(key, jsonEncode(lessons));
      await _setTimestamp(key);
      debugPrint(
        '💾 [CacheService] Cached ${lessons.length} lessons for $courseId',
      );
    } catch (e) {
      debugPrint('⚠️ [CacheService] Error caching lessons: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedLessons(String courseId) async {
    try {
      final p = await prefs;
      final key = '$_lessonsPrefix$courseId';
      final data = p.getString(key);
      if (data == null) return null;
      final list = jsonDecode(data) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('⚠️ [CacheService] Error reading cached lessons: $e');
      return null;
    }
  }

  // ─── QUESTIONS ───

  Future<void> cacheQuestions(
    String courseId,
    List<Map<String, dynamic>> questions,
  ) async {
    try {
      final p = await prefs;
      final key = '$_questionsPrefix$courseId';
      await p.setString(key, jsonEncode(questions));
      await _setTimestamp(key);
      debugPrint(
        '💾 [CacheService] Cached ${questions.length} questions for $courseId',
      );
    } catch (e) {
      debugPrint('⚠️ [CacheService] Error caching questions: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedQuestions(
    String courseId,
  ) async {
    try {
      final p = await prefs;
      final key = '$_questionsPrefix$courseId';
      final data = p.getString(key);
      if (data == null) return null;
      final list = jsonDecode(data) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('⚠️ [CacheService] Error reading cached questions: $e');
      return null;
    }
  }

  // ─── NOTES ───

  Future<void> cacheNotes(List<Map<String, dynamic>> notes) async {
    try {
      final p = await prefs;
      await p.setString(_notesKey, jsonEncode(notes));
      await _setTimestamp(_notesKey);
      debugPrint('💾 [CacheService] Cached ${notes.length} notes');
    } catch (e) {
      debugPrint('⚠️ [CacheService] Error caching notes: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedNotes() async {
    try {
      final p = await prefs;
      final data = p.getString(_notesKey);
      if (data == null) return null;
      final list = jsonDecode(data) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('⚠️ [CacheService] Error reading cached notes: $e');
      return null;
    }
  }

  // ─── CLEAR ───

  Future<void> clearAllCaches() async {
    final p = await prefs;
    final keys = p.getKeys().where(
      (k) => k.startsWith('cached_') || k.startsWith(_cacheTimestampPrefix),
    );
    for (final key in keys) {
      await p.remove(key);
    }
    debugPrint('🗑️ [CacheService] All caches cleared');
  }
}
