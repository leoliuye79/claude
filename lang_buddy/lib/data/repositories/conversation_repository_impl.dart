import 'package:drift/drift.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/local/daos/conversation_dao.dart';
import '../datasources/local/database.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationDao _dao;

  ConversationRepositoryImpl(this._dao);

  @override
  Future<List<Conversation>> getConversations() async {
    final rows = await _dao.getAll();
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<Conversation>> watchConversations() {
    return _dao.watchAll().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Conversation?> getConversation(String id) async {
    final row = await _dao.getById(id);
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<Conversation?> getConversationByAgentId(String agentId) async {
    final row = await _dao.getByAgentId(agentId);
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<void> insertConversation(Conversation conversation) {
    return _dao.insertOne(_toCompanion(conversation));
  }

  @override
  Future<void> updateConversation(Conversation conversation) {
    return _dao.updateOne(_toCompanion(conversation));
  }

  @override
  Future<void> deleteConversation(String id) {
    return _dao.deleteById(id);
  }

  Conversation _toEntity(ConversationsTableData row) {
    return Conversation(
      id: row.id,
      agentId: row.agentId,
      lastMessagePreview: row.lastMessagePreview,
      lastMessageAt: row.lastMessageAt,
      unreadCount: row.unreadCount,
      isPinned: row.isPinned,
      createdAt: row.createdAt,
    );
  }

  ConversationsTableCompanion _toCompanion(Conversation c) {
    return ConversationsTableCompanion(
      id: Value(c.id),
      agentId: Value(c.agentId),
      lastMessagePreview: Value(c.lastMessagePreview),
      lastMessageAt: Value(c.lastMessageAt),
      unreadCount: Value(c.unreadCount),
      isPinned: Value(c.isPinned),
      createdAt: Value(c.createdAt),
    );
  }
}
