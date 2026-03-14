import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/conversations_table.dart';

part 'conversation_dao.g.dart';

@DriftAccessor(tables: [ConversationsTable])
class ConversationDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationDaoMixin {
  ConversationDao(super.db);

  Future<List<ConversationsTableData>> getAll() {
    return (select(conversationsTable)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.lastMessageAt),
          ]))
        .get();
  }

  Stream<List<ConversationsTableData>> watchAll() {
    return (select(conversationsTable)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.lastMessageAt),
          ]))
        .watch();
  }

  Future<ConversationsTableData?> getById(String id) {
    return (select(conversationsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<ConversationsTableData?> getByAgentId(String agentId) {
    return (select(conversationsTable)
          ..where((t) => t.agentId.equals(agentId)))
        .getSingleOrNull();
  }

  Future<void> insertOne(ConversationsTableCompanion entry) {
    return into(conversationsTable).insert(entry);
  }

  Future<void> updateOne(ConversationsTableCompanion entry) {
    return (update(conversationsTable)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> deleteById(String id) {
    return (delete(conversationsTable)..where((t) => t.id.equals(id))).go();
  }
}
