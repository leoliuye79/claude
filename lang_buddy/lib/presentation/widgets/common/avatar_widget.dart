import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;

  const AvatarWidget({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = AppDimensions.avatarMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColorForName(name),
        borderRadius: BorderRadius.circular(AppDimensions.radiusAvatar),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getColorForName(String name) {
    final colors = [
      const Color(0xFF07C160),
      const Color(0xFF1989FA),
      const Color(0xFFFA5151),
      const Color(0xFFFF8F1F),
      const Color(0xFF6467F0),
      const Color(0xFF00B578),
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }
}
