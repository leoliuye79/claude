import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database.dart';
import '../../data/datasources/local/daos/message_dao.dart';
import '../../data/datasources/local/daos/conversation_dao.dart';
import '../../data/datasources/local/daos/agent_dao.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../data/repositories/agent_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/repositories/agent_repository.dart';
import '../../domain/repositories/settings_repository.dart';

// Database
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// DAOs
final messageDaoProvider = Provider<MessageDao>((ref) {
  return MessageDao(ref.watch(databaseProvider));
});

final conversationDaoProvider = Provider<ConversationDao>((ref) {
  return ConversationDao(ref.watch(databaseProvider));
});

final agentDaoProvider = Provider<AgentDao>((ref) {
  return AgentDao(ref.watch(databaseProvider));
});

// Repositories
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(ref.watch(messageDaoProvider));
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl(ref.watch(conversationDaoProvider));
});

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  return AgentRepositoryImpl(ref.watch(agentDaoProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});
