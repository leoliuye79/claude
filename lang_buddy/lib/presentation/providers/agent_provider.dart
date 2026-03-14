import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/agent.dart';
import 'database_provider.dart';

final agentsProvider =
    AsyncNotifierProvider<AgentsNotifier, List<Agent>>(AgentsNotifier.new);

class AgentsNotifier extends AsyncNotifier<List<Agent>> {
  @override
  Future<List<Agent>> build() async {
    final repo = ref.watch(agentRepositoryProvider);
    await repo.seedDefaultAgents();
    return repo.getAgents();
  }

  Future<Agent?> getAgent(String id) async {
    final repo = ref.read(agentRepositoryProvider);
    return repo.getAgent(id);
  }

  Future<void> refresh() async {
    final repo = ref.read(agentRepositoryProvider);
    state = AsyncValue.data(await repo.getAgents());
  }
}
