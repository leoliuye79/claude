import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/ai_model_config.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FlutterSecureStorage _storage;

  SettingsRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _modelConfigKey = 'active_model_config';
  static const _apiKeyPrefix = 'api_key_';

  @override
  Future<AIModelConfig?> getActiveModelConfig() async {
    final json = await _storage.read(key: _modelConfigKey);
    if (json == null) return null;

    try {
      final data = jsonDecode(json);
      final apiKey =
          await getApiKey(data['provider'] as String) ?? '';
      return AIModelConfig(
        provider: AIProvider.values.firstWhere(
          (p) => p.name == data['provider'],
          orElse: () => AIProvider.claude,
        ),
        modelId: data['modelId'] as String,
        displayName: data['displayName'] as String,
        apiKey: apiKey,
        baseUrl: data['baseUrl'] as String?,
        temperature: (data['temperature'] as num?)?.toDouble() ?? 0.7,
        maxTokens: (data['maxTokens'] as num?)?.toInt() ?? 1024,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveModelConfig(AIModelConfig config) async {
    final data = {
      'provider': config.provider.name,
      'modelId': config.modelId,
      'displayName': config.displayName,
      'baseUrl': config.baseUrl,
      'temperature': config.temperature,
      'maxTokens': config.maxTokens,
    };
    await _storage.write(key: _modelConfigKey, value: jsonEncode(data));
    await saveApiKey(config.provider.name, config.apiKey);
  }

  @override
  Future<String?> getApiKey(String provider) {
    return _storage.read(key: '$_apiKeyPrefix$provider');
  }

  @override
  Future<void> saveApiKey(String provider, String apiKey) {
    return _storage.write(key: '$_apiKeyPrefix$provider', value: apiKey);
  }
}
