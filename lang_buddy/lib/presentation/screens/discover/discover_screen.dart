import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabDiscover),
        backgroundColor: AppColors.appBarDark,
      ),
      backgroundColor: AppColors.chatBackground,
      body: ListView(
        children: [
          const SizedBox(height: AppDimensions.sm),
          _buildSection([
            _buildItem(
              icon: Icons.today,
              iconColor: const Color(0xFFFF6B35),
              title: '每日话题',
              subtitle: 'Talk about your weekend plans',
            ),
            _buildItem(
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFA5151),
              title: '学习连续天数',
              subtitle: '0 天',
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
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: () {},
    );
  }
}
