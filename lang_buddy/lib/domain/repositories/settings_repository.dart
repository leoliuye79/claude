import '../entities/ai_model_config.dart';

abstract class SettingsRepository {
  Future<AIModelConfig?> getActiveModelConfig();
  Future<void> saveModelConfig(AIModelConfig config);
  Future<String?> getApiKey(String provider);
  Future<void> saveApiKey(String provider, String apiKey);
}
