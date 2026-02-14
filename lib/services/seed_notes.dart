import 'database_service.dart';
import 'package:flutter/foundation.dart';

Future<void> ensureNotesExist() async {
  try {
    final db = DatabaseService();

    // Perform thorough Upsert regardless of current state

    final notesData = [
      {
        "id": "note_1",
        "title": "Python Basics Cheat Sheet",
        "content": "Variables, Lists, Dictionaries, and Basic Loops in Python.",
        "category": "Python",
        "author_name": "Admin",
        "author_id": "system",
      },
      {
        "id": "note_2",
        "title": "Dart Asynchronous Programming",
        "content": "Future, async, await, and Streams in Dart.",
        "category": "Dart",
        "author_name": "Admin",
        "author_id": "system",
      },
      {
        "id": "note_3",
        "title": "React Hooks Overview",
        "content": "useState, useEffect, useContext, and custom hooks.",
        "category": "Web Development",
        "author_name": "Admin",
        "author_id": "system",
      },
    ];

    for (var note in notesData) {
      await db.insert('notes', note);
    }
    debugPrint("Notes seeded successfully into Local DB.");
  } catch (e) {
    debugPrint("Error seeding notes: $e");
  }
}
