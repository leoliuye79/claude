import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/agents_table.dart';

part 'agent_dao.g.dart';

@DriftAccessor(tables: [AgentsTable])
class AgentDao extends DatabaseAccessor<AppDatabase> with _$AgentDaoMixin {
  AgentDao(super.db);

  Future<List<AgentsTableData>> getAll() {
    return (select(agentsTable)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<AgentsTableData?> getById(String id) {
    return (select(agentsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertOne(AgentsTableCompanion entry) {
    return into(agentsTable).insert(entry, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateOne(AgentsTableCompanion entry) {
    return (update(agentsTable)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> deleteById(String id) {
    return (delete(agentsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> count() async {
    final countExp = agentsTable.id.count();
    final query = selectOnly(agentsTable)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }
}
