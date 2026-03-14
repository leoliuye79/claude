import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/agent.dart';
import '../common/avatar_widget.dart';

class ContactTile extends StatelessWidget {
  final Agent agent;
  final VoidCallback onTap;

  const ContactTile({
    super.key,
    required this.agent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppColors.white,
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
                  Text(
                    agent.nameZh,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${agent.role.label} · ${agent.targetLevel}',
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSm,
                      color: AppColors.textSecondary,
                    ),
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
