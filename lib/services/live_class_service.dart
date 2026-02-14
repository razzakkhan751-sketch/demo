import '../models/live_class.dart';
import 'database_service.dart';
import 'dart:async';

class LiveClassService {
  final DatabaseService _db = DatabaseService();

  // Stream of upcoming classes, ordered by date
  Stream<List<LiveClass>> getUpcomingClasses() {
    return _db
        .streamCollection('live_classes', orderBy: 'scheduled_at ASC')
        .map((list) {
          return list.map((map) => LiveClass.fromMap(map, map['id'])).toList();
        });
  }

  // Add a new class
  Future<void> scheduleClass(LiveClass liveClass) async {
    await _db.insert('live_classes', liveClass.toMap());
  }

  // Delete a class
  Future<void> deleteClass(String id) async {
    await _db.delete('live_classes', docId: id);
  }
}
