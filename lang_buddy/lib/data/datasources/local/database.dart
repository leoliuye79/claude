import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/messages_table.dart';
import 'tables/conversations_table.dart';
import 'tables/agents_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [MessagesTable, ConversationsTable, AgentsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'lang_buddy.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
