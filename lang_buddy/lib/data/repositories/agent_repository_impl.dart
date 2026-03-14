import 'dart:convert';
import 'package:drift/drift.dart';
import '../../config/agents/default_agents.dart';
import '../../domain/entities/agent.dart';
import '../../domain/repositories/agent_repository.dart';
import '../datasources/local/daos/agent_dao.dart';
import '../datasources/local/database.dart';

class AgentRepositoryImpl implements AgentRepository {
  final AgentDao _dao;

  AgentRepositoryImpl(this._dao);

  @override
  Future<List<Agent>> getAgents() async {
    final rows = await _dao.getAll();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Agent?> getAgent(String id) async {
    final row = await _dao.getById(id);
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<void> insertAgent(Agent agent) {
    return _dao.insertOne(_toCompanion(agent));
  }

  @override
  Future<void> updateAgent(Agent agent) {
    return _dao.updateOne(_toCompanion(agent));
  }

  @override
  Future<void> deleteAgent(String id) {
    return _dao.deleteById(id);
  }

  @override
  Future<void> seedDefaultAgents() async {
    final count = await _dao.count();
    if (count > 0) return;

    for (final agent in DefaultAgents.all) {
      await insertAgent(agent);
    }
  }

  Agent _toEntity(AgentsTableData row) {
    return Agent(
      id: row.id,
      name: row.name,
      nameZh: row.nameZh,
      avatarUrl: row.avatarUrl,
      role: AgentRole.values.firstWhere(
        (r) => r.name == row.role,
        orElse: () => AgentRole.friend,
      ),
      style: TeachingStyle.values.firstWhere(
        (s) => s.name == row.style,
        orElse: () => TeachingStyle.casual,
      ),
      correctionMode: CorrectionMode.values.firstWhere(
        (c) => c.name == row.correctionMode,
        orElse: () => CorrectionMode.endOfTurn,
      ),
      personality: row.personality,
      greeting: row.greeting,
      targetLevel: row.targetLevel,
      topics: (jsonDecode(row.topicsJson) as List).cast<String>(),
      isCustom: row.isCustom,
      isActive: row.isActive,
      createdAt: row.createdAt,
    );
  }

  AgentsTableCompanion _toCompanion(Agent agent) {
    return AgentsTableCompanion(
      id: Value(agent.id),
      name: Value(agent.name),
      nameZh: Value(agent.nameZh),
      avatarUrl: Value(agent.avatarUrl),
      role: Value(agent.role.name),
      style: Value(agent.style.name),
      correctionMode: Value(agent.correctionMode.name),
      personality: Value(agent.personality),
      greeting: Value(agent.greeting),
      targetLevel: Value(agent.targetLevel),
      topicsJson: Value(jsonEncode(agent.topics)),
      isCustom: Value(agent.isCustom),
      isActive: Value(agent.isActive),
      createdAt: Value(agent.createdAt),
    );
  }
}
