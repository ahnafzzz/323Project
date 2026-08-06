import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  static String get openRouterKey => dotenv.get('OPENROUTER_API_KEY', fallback: '');
  static String get detectorUrl => dotenv.get('DETECTOR_API_URL', fallback: '');
  static String get chatModel => dotenv.get('CHAT_MODEL', fallback: 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free');
}
