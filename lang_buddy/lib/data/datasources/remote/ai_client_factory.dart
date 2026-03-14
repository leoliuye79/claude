import '../../../domain/entities/ai_model_config.dart';
import 'ai_client.dart';
import 'claude_client.dart';
import 'openai_client.dart';

class AIClientFactory {
  AIClientFactory._();

  static AIClient create(AIModelConfig config) {
    return switch (config.provider) {
      AIProvider.claude => ClaudeClient(
          apiKey: config.apiKey,
          model: config.modelId,
        ),
      AIProvider.openai => OpenAIClient(
          apiKey: config.apiKey,
          model: config.modelId,
        ),
      AIProvider.custom => OpenAIClient(
          apiKey: config.apiKey,
          model: config.modelId,
          baseUrl: config.baseUrl ?? 'https://api.openai.com/v1',
        ),
    };
  }
}
