import 'package:drift/drift.dart';
import 'tables/messages_table.dart';
import 'tables/conversations_table.dart';
import 'tables/agents_table.dart';
import 'connection/connection.dart' as conn;

part 'database.g.dart';

@DriftDatabase(tables: [MessagesTable, ConversationsTable, AgentsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(conn.openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}
