import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:a323project/main.dart';
import 'package:a323project/state/session_provider.dart';
import 'package:a323project/state/history_provider.dart';

void main() {
  testWidgets('App smoke test - Home Screen is shown directly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SessionProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ],
        child: const AgriAssistAppContent(),
      ),
    );

    // Verify that the Home screen is shown (AgriAssist title and Welcome text)
    expect(find.text('AgriAssist'), findsAtLeast(1));
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('New Scan'), findsOneWidget);
  });
}
