import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/agent.dart';
import '../../providers/conversation_provider.dart';
import '../../widgets/common/avatar_widget.dart';

class AgentDetailScreen extends ConsumerWidget {
  final Agent agent;

  const AgentDetailScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarDark,
        title: const Text('详细资料'),
      ),
      backgroundColor: AppColors.chatBackground,
      body: Column(
        children: [
          // Profile card
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Row(
              children: [
                AvatarWidget(
                  name: agent.name,
                  size: AppDimensions.avatarLarge,
                ),
                const SizedBox(width: AppDimensions.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.nameZh,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontTitle,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agent.name,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontMd,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${agent.role.label} · ${agent.targetLevel}',
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSm,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Personality
          Container(
            width: double.infinity,
            color: AppColors.white,
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '个性简介',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  agent.personality,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Topics
          Container(
            width: double.infinity,
            color: AppColors.white,
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '擅长话题',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: agent.topics.map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chatBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        topic,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Start chat button
          Padding(
            padding: EdgeInsets.only(
              left: AppDimensions.xl,
              right: AppDimensions.xl,
              bottom: MediaQuery.of(context).padding.bottom + AppDimensions.lg,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final conversationActions =
                      ref.read(conversationActionsProvider);
                  final conversation = await conversationActions
                      .getOrCreateConversation(agent.id);
                  if (context.mounted) {
                    context.push('/chat/${conversation.id}', extra: agent);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '开始聊天',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
