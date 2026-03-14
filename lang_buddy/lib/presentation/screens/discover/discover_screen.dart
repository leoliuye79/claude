import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/agent_provider.dart';
import '../../providers/conversation_provider.dart';

final _dailyTopics = [
  ('Talk about your weekend plans', '聊聊你的周末计划'),
  ('Describe your favorite movie', '描述你最喜欢的电影'),
  ('Order food at a restaurant', '在餐厅点餐'),
  ('Introduce your best friend', '介绍你的好朋友'),
  ("What's your dream vacation?", '你理想的假期是什么？'),
  ('Talk about a recent news event', '谈谈最近的新闻'),
  ('Describe your daily routine', '描述你的日常生活'),
];

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final todayTopic = _dailyTopics[dayOfYear % _dailyTopics.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabDiscover),
        backgroundColor: AppColors.appBarDark,
      ),
      backgroundColor: AppColors.chatBackground,
      body: ListView(
        children: [
          const SizedBox(height: AppDimensions.sm),
          // Daily topic card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF07C160), Color(0xFF06AD56)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.today, color: AppColors.white, size: 36),
              title: const Text('每日话题',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(todayTopic.$1,
                    style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 14)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.white, size: 16),
              onTap: () async {
                // Start chat with Emma using today's topic
                final agents = ref.read(agentsProvider).valueOrNull ?? [];
                if (agents.isEmpty) return;
                final emma = agents.first;
                final conv = await ref
                    .read(conversationActionsProvider)
                    .getOrCreateConversation(emma.id);
                if (context.mounted) {
                  context.push('/chat/${conv.id}', extra: emma);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(todayTopic.$2,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          const SizedBox(height: AppDimensions.sm),
          _buildSection([
            _buildItem(
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFA5151),
              title: '学习连续天数',
              subtitle: '坚持每天练习，养成好习惯',
              trailing: const Text('🔥 0 天',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ),
          ]),
          const SizedBox(height: AppDimensions.sm),
          _buildSection([
            _buildItem(
              icon: Icons.menu_book,
              iconColor: const Color(0xFF1989FA),
              title: '常用表达',
              subtitle: '收藏实用英语短语',
            ),
            _buildItem(
              icon: Icons.quiz,
              iconColor: AppColors.primaryGreen,
              title: '语法小测验',
              subtitle: '测试你的语法水平',
            ),
            _buildItem(
              icon: Icons.lightbulb_outline,
              iconColor: const Color(0xFFFF9500),
              title: '学习技巧',
              subtitle: '高效学习英语的方法',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const Divider(indent: 56),
          ],
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
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
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: AppDimensions.fontSm,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: () {},
    );
  }
}
