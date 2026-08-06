import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/history_provider.dart';
import '../widgets/session_tile.dart';

class HistoryScreen extends StatelessWidget {
  final bool isEmbedded;
  const HistoryScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isEmbedded ? AppBar(title: const Text('History')) : null,
      body: Consumer<HistoryProvider>(
        builder: (context, history, child) {
          if (history.isLoading) return const Center(child: CircularProgressIndicator());
          if (history.sessions.isEmpty) return const Center(child: Text('No history found.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.sessions.length,
            itemBuilder: (context, index) {
              final session = history.sessions[index];
              return Dismissible(
                key: Key(session.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => history.deleteSession(session.id),
                child: SessionTile(session: session),
              );
            },
          );
        },
      ),
    );
  }
}
