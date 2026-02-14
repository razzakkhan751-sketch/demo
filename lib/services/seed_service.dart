import 'database_service.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class SeedService {
  final _db = DatabaseService();

  Future<void> seedAll() async {
    await seedCourses();
    await seedNotes();
  }

  Future<void> seedCourses() async {
    // Perform thorough Upsert regardless of current state

    final courses = [
      {
        'id': 'python-101',
        'title': 'Python for Professionals',
        'category': 'Programming',
        'description': 'Master Python from basics to advanced automation.',
        'thumbnail': 'https://img.icons8.com/color/144/python.png',
        'level': 'Beginner',
        'instructor': 'Admin',
        'lessons': jsonEncode([
          {
            'id': 'l1',
            'title': 'Introduction',
            'videoUrl': 'https://www.youtube.com/watch?v=rfscVS0vtbw',
          },
          {
            'id': 'l2',
            'title': 'Variables & Types',
            'videoUrl': 'https://www.youtube.com/watch?v=rfscVS0vtbw',
          },
        ]),
      },
      {
        'id': 'dart-basics',
        'title': 'Dart & Flutter basics',
        'category': 'App Development',
        'description': 'Build beautiful apps with Dart and Flutter.',
        'thumbnail': 'https://img.icons8.com/color/144/dart.png',
        'level': 'Beginner',
        'instructor': 'Admin',
        'lessons': jsonEncode([
          {
            'id': 'd1',
            'title': 'Dart Intro',
            'videoUrl': 'https://www.youtube.com/watch?v=rfscVS0vtbw',
          },
        ]),
      },
    ];

    for (var course in courses) {
      await _db.insert('courses', course);
    }
    debugPrint("✅ Courses Seeded Locally");
  }

  Future<void> seedNotes() async {
    final existing = await _db.query('notes');
    if (existing.isNotEmpty) return;

    final notes = [
      {
        'id': 'note-1',
        'title': 'Python Cheat Sheet',
        'category': 'Programming',
        'content': 'Print, Loops, Functions, and Lists.',
        'author_name': 'Admin',
      },
      {
        'id': 'note-2',
        'title': 'Flutter Widget Tree',
        'category': 'App Development',
        'content': 'Everything is a widget.',
        'author_name': 'Admin',
      },
    ];

    for (var note in notes) {
      await _db.insert('notes', note);
    }
    debugPrint("✅ Notes Seeded Locally");
  }
}
