import 'package:drift/drift.dart';

class AgentsTable extends Table {
  @override
  String get tableName => 'agents';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameZh => text()();
  TextColumn get avatarUrl => text()();
  TextColumn get role => text()();
  TextColumn get style => text()();
  TextColumn get correctionMode => text()();
  TextColumn get personality => text()();
  TextColumn get greeting => text()();
  TextColumn get targetLevel => text()();
  TextColumn get topicsJson => text()(); // JSON array of strings
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
