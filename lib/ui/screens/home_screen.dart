import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/history_provider.dart';
import '../widgets/session_tile.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    Widget content = _selectedIndex == 0 ? _buildHomeContent() : const HistoryScreen(isEmbedded: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriAssist'),
      ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.history), label: Text('History')),
              ],
            ),
          Expanded(child: content),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.history), label: 'History'),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/capture'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('New Scan'),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'AgriAssist',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('Recent Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Consumer<HistoryProvider>(
            builder: (context, history, child) {
              if (history.isLoading) return const Center(child: CircularProgressIndicator());
              if (history.sessions.isEmpty) {
                return const Center(child: Text('No sessions yet. Start a new scan!'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.sessions.take(5).length,
                itemBuilder: (context, index) => SessionTile(session: history.sessions[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
