import '../../../domain/entities/correction.dart';

class ChatMessage {
  final String role; // "user" or "assistant"
  final String content;

  const ChatMessage({required this.role, required this.content});
}

class AIResponse {
  final String content;
  final int? inputTokens;
  final int? outputTokens;

  const AIResponse({
    required this.content,
    this.inputTokens,
    this.outputTokens,
  });
}

abstract class AIClient {
  Future<AIResponse> sendMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
  });

  Stream<String> streamMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
  });

  Future<Correction?> requestCorrection({
    required String userText,
    required String correctionPrompt,
  });
}
