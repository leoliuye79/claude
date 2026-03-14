import 'package:drift/drift.dart';

class ConversationsTable extends Table {
  @override
  String get tableName => 'conversations';

  TextColumn get id => text()();
  TextColumn get agentId => text()();
  TextColumn get lastMessagePreview => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
