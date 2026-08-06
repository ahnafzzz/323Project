enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final String sessionId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      sessionId: map['sessionId'],
      role: MessageRole.values.byName(map['role']),
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
