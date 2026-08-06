import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_session.dart';
import '../data/models/message.dart';
import '../data/services/detector_service.dart';
import '../data/services/chat_service.dart';
import '../data/services/database_service.dart';
import '../data/services/pdf_service.dart';
import '../core/constants/prompts.dart';

class SessionProvider with ChangeNotifier {
  final DetectorService _detector = DetectorService();
  final ChatService _chat = ChatService();
  final DatabaseService _db = DatabaseService();
  final PdfService _pdf = PdfService();

  ChatSession? _currentSession;
  bool _isAnalyzing = false;
  bool _isSending = false;
  String? _error;

  ChatSession? get currentSession => _currentSession;
  bool get isAnalyzing => _isAnalyzing;
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> startNewSession(File imageFile) async {
    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _detector.predict(imageFile);
      if (response.success) {
        final sessionId = const Uuid().v4();
        final session = ChatSession(
          id: sessionId,
          imagePath: imageFile.path,
          detectedDisease: response.topLabel!,
          confidence: response.topConfidence!,
          createdAt: DateTime.now(),
          title: "${response.topLabel} - ${DateTime.now().toString().substring(0, 10)}",
          messages: [
            Message(
              id: const Uuid().v4(),
              sessionId: sessionId,
              role: MessageRole.system,
              content: AppPrompts.systemPrompt(response.topLabel!, response.topConfidence!),
              timestamp: DateTime.now(),
            )
          ],
        );

        await _db.insertSession(session);
        for (var msg in session.messages) {
          await _db.insertMessage(msg);
        }

        _currentSession = session;
      } else {
        _error = response.error;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void resumeSession(ChatSession session) {
    _currentSession = session;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (_currentSession == null || text.trim().isEmpty) return;

    final userMessage = Message(
      id: const Uuid().v4(),
      sessionId: _currentSession!.id,
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, userMessage],
    );
    notifyListeners();
    await _db.insertMessage(userMessage);

    _isSending = true;
    notifyListeners();

    try {
      final reply = await _chat.getCompletion(_currentSession!.messages);
      final assistantMessage = Message(
        id: const Uuid().v4(),
        sessionId: _currentSession!.id,
        role: MessageRole.assistant,
        content: reply,
        timestamp: DateTime.now(),
      );

      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, assistantMessage],
      );
      await _db.insertMessage(assistantMessage);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<File?> generateReport() async {
    if (_currentSession == null) return null;

    final reportRequest = Message(
      id: const Uuid().v4(),
      sessionId: _currentSession!.id,
      role: MessageRole.user,
      content: AppPrompts.reportPrompt,
      timestamp: DateTime.now(),
    );

    try {
      final reportText = await _chat.getCompletion([..._currentSession!.messages, reportRequest]);
      final pdfFile = await _pdf.generateReport(_currentSession!, reportText);
      
      _currentSession = _currentSession!.copyWith(reportPdfPath: pdfFile.path);
      await _db.insertSession(_currentSession!);
      
      return pdfFile;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
