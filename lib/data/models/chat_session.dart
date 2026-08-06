import 'message.dart';

class ChatSession {
  final String id;
  final String imagePath;
  final String detectedDisease;
  final double confidence;
  final DateTime createdAt;
  final String title;
  final List<Message> messages;
  final String? reportPdfPath;

  ChatSession({
    required this.id,
    required this.imagePath,
    required this.detectedDisease,
    required this.confidence,
    required this.createdAt,
    required this.title,
    this.messages = const [],
    this.reportPdfPath,
  });

  ChatSession copyWith({
    List<Message>? messages,
    String? reportPdfPath,
  }) {
    return ChatSession(
      id: id,
      imagePath: imagePath,
      detectedDisease: detectedDisease,
      confidence: confidence,
      createdAt: createdAt,
      title: title,
      messages: messages ?? this.messages,
      reportPdfPath: reportPdfPath ?? this.reportPdfPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'detectedDisease': detectedDisease,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
      'reportPdfPath': reportPdfPath,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map, {List<Message> messages = const []}) {
    return ChatSession(
      id: map['id'],
      imagePath: map['imagePath'],
      detectedDisease: map['detectedDisease'],
      confidence: map['confidence'],
      createdAt: DateTime.parse(map['createdAt']),
      title: map['title'],
      reportPdfPath: map['reportPdfPath'],
      messages: messages,
    );
  }
}
