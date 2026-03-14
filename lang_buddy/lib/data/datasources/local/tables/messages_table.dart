import 'package:drift/drift.dart';

class MessagesTable extends Table {
  @override
  String get tableName => 'messages';

  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get sender => text()(); // 'user' | 'agent'
  TextColumn get type => text()(); // 'text' | 'voice' | 'correction' | 'systemNotice'
  TextColumn get content => text()();
  TextColumn get audioPath => text().nullable()();
  IntColumn get audioDurationMs => integer().nullable()();
  TextColumn get correctionJson => text().nullable()();
  TextColumn get status => text()(); // 'sending' | 'sent' | 'failed'
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
