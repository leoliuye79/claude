import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/avatar_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabMe),
        backgroundColor: AppColors.appBarDark,
      ),
      backgroundColor: AppColors.chatBackground,
      body: ListView(
        children: [
          // User profile section
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Row(
              children: [
                const AvatarWidget(
                  name: 'Me',
                  size: AppDimensions.avatarLarge,
                ),
                const SizedBox(width: AppDimensions.lg),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '我的学习',
                        style: TextStyle(
                          fontSize: AppDimensions.fontTitle,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'LangBuddy 用户',
                        style: TextStyle(
                          fontSize: AppDimensions.fontMd,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Settings items
          Container(
            color: AppColors.white,
            child: Column(
              children: [
                _buildSettingsItem(
                  icon: Icons.smart_toy,
                  iconColor: const Color(0xFF6467F0),
                  title: 'AI 模型设置',
                  onTap: () => context.push('/settings/ai-model'),
                ),
                const Divider(indent: 56),
                _buildSettingsItem(
                  icon: Icons.person_add,
                  iconColor: const Color(0xFFFF9500),
                  title: '创建自定义 Agent',
                  onTap: () => context.push('/settings/custom-agent'),
                ),
                const Divider(indent: 56),
                _buildSettingsItem(
                  icon: Icons.language,
                  iconColor: const Color(0xFF1989FA),
                  title: '学习语言',
                  subtitle: '英语',
                  onTap: () {},
                ),
                const Divider(indent: 56),
                _buildSettingsItem(
                  icon: Icons.bar_chart,
                  iconColor: AppColors.primaryGreen,
                  title: '学习统计',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Container(
            color: AppColors.white,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF303030),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.dark_mode,
                        color: AppColors.white, size: 20),
                  ),
                  title: const Text('深色模式',
                      style: TextStyle(
                          fontSize: AppDimensions.fontLg,
                          color: AppColors.textPrimary)),
                  value: isDark,
                  activeTrackColor: AppColors.primaryGreen,
                  onChanged: (v) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setMode(v ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                const Divider(indent: 56),
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  iconColor: const Color(0xFF1989FA),
                  title: '关于 LangBuddy',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'LangBuddy',
                      applicationVersion: '1.0.0',
                      children: [
                        const Text('一款微信风格的 AI 语言学习 App。\n'
                            '通过与 AI 伙伴日常对话练习英语。'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppDimensions.fontLg,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: AppDimensions.fontSm,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
