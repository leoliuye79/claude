import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<List<Conversation>> getConversations();
  Stream<List<Conversation>> watchConversations();
  Future<Conversation?> getConversation(String id);
  Future<Conversation?> getConversationByAgentId(String agentId);
  Future<void> insertConversation(Conversation conversation);
  Future<void> updateConversation(Conversation conversation);
  Future<void> deleteConversation(String id);
}
