import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/conversation.dart';
import 'database_provider.dart';

final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final repo = ref.watch(conversationRepositoryProvider);
  return repo.watchConversations();
});

final conversationActionsProvider =
    Provider<ConversationActions>((ref) => ConversationActions(ref));

class ConversationActions {
  final Ref _ref;

  ConversationActions(this._ref);

  Future<Conversation> getOrCreateConversation(String agentId) async {
    final repo = _ref.read(conversationRepositoryProvider);
    final existing = await repo.getConversationByAgentId(agentId);
    if (existing != null) return existing;

    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      agentId: agentId,
      createdAt: DateTime.now(),
    );
    await repo.insertConversation(conversation);
    return conversation;
  }

  Future<void> updateLastMessage(
      String conversationId, String preview) async {
    final repo = _ref.read(conversationRepositoryProvider);
    final conversation = await repo.getConversation(conversationId);
    if (conversation == null) return;

    await repo.updateConversation(conversation.copyWith(
      lastMessagePreview: preview,
      lastMessageAt: DateTime.now(),
    ));
  }

  Future<void> deleteConversation(String id) async {
    final repo = _ref.read(conversationRepositoryProvider);
    await repo.deleteConversation(id);
  }
}
