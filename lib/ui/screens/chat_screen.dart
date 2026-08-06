import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_provider.dart';
import '../../data/models/message.dart';
import '../widgets/message_bubble.dart';
import '../screens/report_preview_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation'),
        actions: [
          IconButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final provider = context.read<SessionProvider>();
              final file = await provider.generateReport();
              if (file != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportPreviewScreen(pdfFile: file),
                  ),
                );
              } else if (context.mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Failed to generate report')),
                );
              }
            },
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Report',
          ),
        ],
      ),
      body: Consumer<SessionProvider>(
        builder: (context, provider, child) {
          final session = provider.currentSession;
          if (session == null) return const Center(child: Text('Error: No active session'));

          final messages = session.messages.where((m) => m.role != MessageRole.system).toList();

          return Column(
            children: [
              _buildSessionHeader(session),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => MessageBubble(message: messages[index]),
                ),
              ),
              if (provider.isSending)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              _buildInputArea(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionHeader(dynamic session) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(session.imagePath), width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.detectedDisease, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Confidence: ${(session.confidence * 100).toStringAsFixed(1)}%"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(SessionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask about this disease...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _handleSend(provider),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: provider.isSending ? null : () => _handleSend(provider),
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _handleSend(SessionProvider provider) {
    if (_controller.text.trim().isEmpty) return;
    provider.sendMessage(_controller.text);
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }
}
