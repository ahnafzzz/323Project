import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/chat_session.dart';
import '../../state/session_provider.dart';

class SessionTile extends StatelessWidget {
  final ChatSession session;
  const SessionTile({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(session.imagePath), width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text("${session.detectedDisease} (${(session.confidence * 100).toStringAsFixed(1)}%)"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.read<SessionProvider>().resumeSession(session);
          Navigator.pushNamed(context, '/chat');
        },
      ),
    );
  }
}
