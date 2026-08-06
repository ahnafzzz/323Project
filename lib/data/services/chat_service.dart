import 'package:dio/dio.dart';
import '../../core/config/env.dart';
import '../models/message.dart';

class ChatService {
  final Dio _dio = Dio();

  /// Hook for custom LLM setup.
  /// Can be used to configure specific model parameters, adapters, or local inference settings.
  void setupLLM() {
    // TODO: Implement custom LLM setup logic here
    // This hook is called before starting the chat turn.
  }

  Future<String> getCompletion(List<Message> history) async {
    try {
      // Call the setup hook
      setupLLM();

      final messages = history.map((m) => {
        "role": m.role.name,
        "content": m.content,
      }).toList();

      final response = await _dio.post(
        "https://openrouter.ai/api/v1/chat/completions",
        options: Options(
          headers: {
            "Authorization": "Bearer ${Env.openRouterKey}",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "model": Env.chatModel,
          "messages": messages,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        throw Exception("Failed to get completion: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
