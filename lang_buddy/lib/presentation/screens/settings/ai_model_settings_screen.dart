import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/ai_model_config.dart';
import '../../providers/settings_provider.dart';

class AIModelSettingsScreen extends ConsumerStatefulWidget {
  const AIModelSettingsScreen({super.key});

  @override
  ConsumerState<AIModelSettingsScreen> createState() =>
      _AIModelSettingsScreenState();
}

class _AIModelSettingsScreenState extends ConsumerState<AIModelSettingsScreen> {
  AIProvider _selectedProvider = AIProvider.claude;
  final _apiKeyController = TextEditingController();
  final _modelIdController = TextEditingController();
  final _baseUrlController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await ref.read(activeModelConfigProvider.future);
    if (config != null && mounted) {
      setState(() {
        _selectedProvider = config.provider;
        _apiKeyController.text = config.apiKey;
        _modelIdController.text = config.modelId;
        _baseUrlController.text = config.baseUrl ?? '';
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelIdController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    final config = AIModelConfig(
      provider: _selectedProvider,
      modelId: _modelIdController.text.isEmpty
          ? _defaultModelId(_selectedProvider)
          : _modelIdController.text,
      displayName: _selectedProvider.label,
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text.isEmpty ? null : _baseUrlController.text,
    );

    await ref.read(activeModelConfigProvider.notifier).saveConfig(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
    }
  }

  String _defaultModelId(AIProvider provider) => switch (provider) {
        AIProvider.claude => 'claude-sonnet-4-20250514',
        AIProvider.openai => 'gpt-4o',
        AIProvider.custom => 'gpt-4o',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 模型设置'),
        backgroundColor: AppColors.appBarDark,
        actions: [
          TextButton(
            onPressed: _saveConfig,
            child: const Text('保存',
                style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
      backgroundColor: AppColors.chatBackground,
      body: ListView(
        children: [
          const SizedBox(height: AppDimensions.sm),
          // Provider selection
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择 AI 模型提供商',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                ...AIProvider.values.map((provider) {
                  final selected = provider == _selectedProvider;
                  return ListTile(
                    title: Text(provider.label),
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedProvider = provider;
                        _modelIdController.text = _defaultModelId(provider);
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // API Key
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'API Key',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    hintText: '输入你的 API Key',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureApiKey
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Model ID
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '模型 ID',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                TextField(
                  controller: _modelIdController,
                  decoration: InputDecoration(
                    hintText: _defaultModelId(_selectedProvider),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Custom base URL (only for custom provider)
          if (_selectedProvider == AIProvider.custom) ...[
            const SizedBox(height: AppDimensions.sm),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Base URL',
                    style: TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://api.example.com/v1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
