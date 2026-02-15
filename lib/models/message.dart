// ──────────────────────────────────────────────────────────
// Message Model — Chat messages
// ──────────────────────────────────────────────────────────

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'student', 'teacher', 'admin'
  final String text;
  final DateTime timestamp;
  final String type; // 'text', 'image'
  final List<String> readBy; // UIDs of users who have read this

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderRole = 'student',
    required this.text,
    required this.timestamp,
    this.type = 'text',
    this.readBy = const [],
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      senderId: (map['sender_id'] ?? map['senderId'] ?? '').toString(),
      senderName: (map['sender_name'] ?? map['senderName'] ?? 'Unknown')
          .toString(),
      senderRole: (map['sender_role'] ?? map['senderRole'] ?? 'student')
          .toString(),
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : (map['created_at'] != null
                ? DateTime.parse(map['created_at'])
                : DateTime.now()),
      type: map['type'] ?? 'text',
      readBy: List<String>.from(map['read_by'] ?? map['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'read_by': readBy,
    };
  }
}
