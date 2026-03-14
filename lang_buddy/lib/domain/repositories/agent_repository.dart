import '../entities/agent.dart';

abstract class AgentRepository {
  Future<List<Agent>> getAgents();
  Future<Agent?> getAgent(String id);
  Future<void> insertAgent(Agent agent);
  Future<void> updateAgent(Agent agent);
  Future<void> deleteAgent(String id);
  Future<void> seedDefaultAgents();
}
