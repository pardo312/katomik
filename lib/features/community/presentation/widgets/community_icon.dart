import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/common/habit_icon.dart';

class CommunityIcon extends StatelessWidget {
  final String icon;
  final String? iconColor;
  final double size;

  const CommunityIcon({
    super.key,
    required this.icon,
    this.iconColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor != null 
        ? Color(int.parse(iconColor!.replaceAll('#', '0xFF')))
        : AppColors.primary;
    
    return Container(
      width: size * 2,
      height: size * 2,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: HabitIcon(
          iconName: icon,
          size: size,
          color: color,
        ),
      ),
    );
  }
}