import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'state/session_provider.dart';
import 'state/history_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/capture_screen.dart';
import 'ui/screens/analyzing_screen.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.init();
  
  runApp(const AgriAssistApp());
}

class AgriAssistApp extends StatelessWidget {
  const AgriAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const AgriAssistAppContent(),
    );
  }
}

class AgriAssistAppContent extends StatelessWidget {
  const AgriAssistAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriAssist',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/capture': (context) => const CaptureScreen(),
        '/analyzing': (context) => const AnalyzingScreen(),
        '/chat': (context) => const ChatScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
