enum AIProvider {
  claude,
  openai,
  custom;

  String get label => switch (this) {
        claude => 'Claude (Anthropic)',
        openai => 'OpenAI',
        custom => '自定义',
      };
}

class AIModelConfig {
  final AIProvider provider;
  final String modelId;
  final String displayName;
  final String apiKey;
  final String? baseUrl;
  final double temperature;
  final int maxTokens;

  const AIModelConfig({
    required this.provider,
    required this.modelId,
    required this.displayName,
    required this.apiKey,
    this.baseUrl,
    this.temperature = 0.7,
    this.maxTokens = 1024,
  });

  AIModelConfig copyWith({
    AIProvider? provider,
    String? modelId,
    String? displayName,
    String? apiKey,
    String? baseUrl,
    double? temperature,
    int? maxTokens,
  }) {
    return AIModelConfig(
      provider: provider ?? this.provider,
      modelId: modelId ?? this.modelId,
      displayName: displayName ?? this.displayName,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}
