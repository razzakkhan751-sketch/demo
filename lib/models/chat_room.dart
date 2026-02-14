class ChatRoom {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastTimestamp;
  final String type; // 'group' or 'direct'

  ChatRoom({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.type,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['last_message'] ?? map['lastMessage'] ?? '',
      lastTimestamp: map['last_timestamp'] != null
          ? DateTime.parse(map['last_timestamp'])
          : (map['lastTimestamp'] != null
                ? DateTime.parse(map['lastTimestamp'])
                : DateTime.now()),
      type: map['type'] ?? 'direct',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'last_message': lastMessage,
      'last_timestamp': lastTimestamp.toIso8601String(),
      'type': type,
    };
  }
}
