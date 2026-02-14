import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/chat_room.dart';
import 'database_service.dart';
import 'dart:async';

class ChatService {
  final DatabaseService _db = DatabaseService();

  // Send Message
  Future<void> sendMessage(String roomId, Message message) async {
    final messageMap = message.toMap();
    messageMap['room_id'] = roomId;

    await _db.insert('chat_messages', messageMap);

    await _db.update('chat_rooms', {
      'last_message': message.type == 'image' ? '[Image]' : message.text,
      'last_timestamp': message.timestamp.toIso8601String(),
    }, docId: roomId);
  }

  // Get Messages Stream
  Stream<List<Message>> getMessages(String roomId) {
    return _db
        .streamCollection(
          'chat_messages',
          where: 'room_id = ?',
          whereArgs: [roomId],
          orderBy: 'timestamp DESC',
        )
        .map((list) {
          return list.map((map) => Message.fromMap(map, map['id'])).toList();
        });
  }

  // Create or Get Private Chat Room
  Future<String> createPrivateChat(String userId, String otherUserId) async {
    // Note: We need a complex query (where array-contains AND another filter)
    // Firestore instance directly is better here as DatabaseService is simple.
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('chat_rooms')
        .where('type', isEqualTo: 'direct')
        .where('participants', arrayContains: userId)
        .get();

    for (var doc in snapshot.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    final roomId = "${userId}_$otherUserId"; // Unique ID for direct chat
    await _db.insert('chat_rooms', {
      'participants': [userId, otherUserId],
      'last_message': '',
      'last_timestamp': DateTime.now().toIso8601String(),
      'type': 'direct',
    }, docId: roomId);

    return roomId;
  }

  // Get User Chats
  Stream<List<ChatRoom>> getUserChats(String userId) {
    return _db
        .streamCollection(
          'chat_rooms',
          where: 'participants ARRAY-CONTAINS ?',
          whereArgs: [userId],
          orderBy: 'last_timestamp DESC',
        )
        .map((list) {
          return list.map((map) => ChatRoom.fromMap(map, map['id'])).toList();
        });
  }
}
