import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_model_config.dart';
import 'database_provider.dart';

final activeModelConfigProvider =
    AsyncNotifierProvider<ActiveModelConfigNotifier, AIModelConfig?>(
        ActiveModelConfigNotifier.new);

class ActiveModelConfigNotifier extends AsyncNotifier<AIModelConfig?> {
  @override
  Future<AIModelConfig?> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.getActiveModelConfig();
  }

  Future<void> saveConfig(AIModelConfig config) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveModelConfig(config);
    state = AsyncValue.data(config);
  }
}
