import 'package:flutter/material.dart';
import '../data/models/chat_session.dart';
import '../data/services/database_service.dart';

class HistoryProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<ChatSession> _sessions = [];
  bool _isLoading = false;

  List<ChatSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();
    _sessions = await _db.getAllSessions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    await _db.deleteSession(id);
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
