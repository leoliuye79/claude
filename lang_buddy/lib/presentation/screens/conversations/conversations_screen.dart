import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/agent_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../widgets/conversations/conversation_tile.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final agentsAsync = ref.watch(agentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabChats),
        backgroundColor: AppColors.appBarDark,
      ),
      backgroundColor: AppColors.chatBackground,
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    '还没有对话\n去通讯录找一个 Agent 开始聊天吧！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return agentsAsync.when(
            data: (agents) {
              final agentMap = {for (final a in agents) a.id: a};
              // Sort: pinned first, then by last message time
              final sorted = List.of(conversations)..sort((a, b) {
                if (a.isPinned && !b.isPinned) return -1;
                if (!a.isPinned && b.isPinned) return 1;
                final aTime = a.lastMessageAt ?? a.createdAt;
                final bTime = b.lastMessageAt ?? b.createdAt;
                return bTime.compareTo(aTime);
              });

              return ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const Divider(indent: 76),
                itemBuilder: (context, index) {
                  final conv = sorted[index];
                  final agent = agentMap[conv.agentId];
                  if (agent == null) return const SizedBox.shrink();

                  return Dismissible(
                    key: Key(conv.id),
                    background: Container(
                      color: AppColors.primaryGreen,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: Icon(
                        conv.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                        color: AppColors.white,
                      ),
                    ),
                    secondaryBackground: Container(
                      color: AppColors.unreadBadge,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: AppColors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // Toggle pin
                        final actions = ref.read(conversationActionsProvider);
                        await actions.togglePin(conv);
                        return false;
                      } else {
                        // Delete confirmation
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('删除对话'),
                            content: const Text('确定要删除这个对话吗？消息记录将被清除。'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('删除',
                                    style: TextStyle(color: AppColors.unreadBadge)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        ref
                            .read(conversationActionsProvider)
                            .deleteConversation(conv.id);
                      }
                    },
                    child: ConversationTile(
                      conversation: conv,
                      agent: agent,
                      onTap: () => context.push(
                        '/chat/${conv.id}',
                        extra: agent,
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
