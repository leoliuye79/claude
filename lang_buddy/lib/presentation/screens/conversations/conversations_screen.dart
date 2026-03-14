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
                  Icon(Icons.chat_bubble_outline,
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
              return ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (_, __) => const Divider(indent: 76),
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final agent = agentMap[conv.agentId];
                  if (agent == null) return const SizedBox.shrink();

                  return ConversationTile(
                    conversation: conv,
                    agent: agent,
                    onTap: () => context.push(
                      '/chat/${conv.id}',
                      extra: agent,
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
