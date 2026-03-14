import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/messages_table.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [MessagesTable])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<List<MessagesTableData>> getByConversationId(String conversationId) {
    return (select(messagesTable)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<MessagesTableData>> watchByConversationId(String conversationId) {
    return (select(messagesTable)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> insertOne(MessagesTableCompanion entry) {
    return into(messagesTable).insert(entry);
  }

  Future<void> updateOne(MessagesTableCompanion entry) {
    return (update(messagesTable)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> deleteById(String id) {
    return (delete(messagesTable)..where((t) => t.id.equals(id))).go();
  }
}
