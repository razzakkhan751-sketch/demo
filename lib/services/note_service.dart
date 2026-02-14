import '../models/note.dart';
import 'database_service.dart';
import 'dart:async';

class NoteService {
  final DatabaseService _db = DatabaseService();

  // Get all notes stream
  Stream<List<Note>> getNotesStream() {
    return _db.streamCollection('notes').map((list) {
      return list.map((map) => Note.fromMap(map, map['id'])).toList();
    });
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    await _db.insert('notes', note.toMap());
  }

  // Update a note
  Future<void> updateNote(Note note) async {
    await _db.update('notes', note.toMap(), docId: note.id);
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await _db.delete('notes', docId: id);
  }
}
