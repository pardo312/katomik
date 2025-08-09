import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';
import '../../habit/widgets/habit_icon.dart';

class CommunityHeader extends StatelessWidget {
  final String name;
  final String icon;
  final String? iconColor;
  final VoidCallback onBack;
  final VoidCallback? onAction;
  final Widget? actionIcon;

  const CommunityHeader({
    super.key,
    required this.name,
    required this.icon,
    this.iconColor,
    required this.onBack,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              CupertinoIcons.arrow_left,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: onBack,
          ),
          _buildIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onAction != null && actionIcon != null)
            IconButton(
              icon: actionIcon!,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final color = iconColor != null
        ? Color(int.parse(iconColor!.replaceAll('#', '0xFF')))
        : AppColors.primary;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: HabitIcon(
          iconName: icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }
}