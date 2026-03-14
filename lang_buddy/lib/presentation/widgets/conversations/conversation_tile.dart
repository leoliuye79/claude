import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/agent.dart';
import '../../../domain/entities/conversation.dart';
import '../common/avatar_widget.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final Agent agent;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.agent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: conversation.isPinned
            ? const Color(0xFFF3F3F3)
            : AppColors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        child: Row(
          children: [
            AvatarWidget(name: agent.name, avatarUrl: agent.avatarUrl),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          agent.nameZh,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontLg,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          DateFormatter.formatConversationTime(
                              conversation.lastMessageAt!),
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessagePreview ?? agent.greeting,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontMd,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.unreadBadge,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
