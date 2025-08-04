import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';
import '../../habit/widgets/habit_icon.dart';

class CommunityCard extends StatelessWidget {
  final String id;
  final String name;
  final String icon;
  final String? iconColor;
  final int memberCount;
  final int averageStreak;
  final String description;
  final String category;
  final String difficulty;
  final List<String> tags;
  final VoidCallback onTap;

  const CommunityCard({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    this.iconColor,
    required this.memberCount,
    required this.averageStreak,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.tags,
    required this.onTap,
  });

  Color getDifficultyColor(BuildContext context) {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String get formattedMemberCount {
    if (memberCount >= 1000000) {
      return '${(memberCount / 1000000).toStringAsFixed(1)}M';
    } else if (memberCount >= 1000) {
      return '${(memberCount / 1000).toStringAsFixed(1)}k';
    }
    return memberCount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.outlineVariant.withValues(alpha:0.5)
                : Theme.of(context).colorScheme.outlineVariant.withValues(alpha:0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha:0.3)
                  : Theme.of(context).colorScheme.shadow.withValues(alpha:0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha:0.2)
                  : Theme.of(context).colorScheme.shadow.withValues(alpha:0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor != null 
                        ? Color(int.parse(iconColor!.replaceAll('#', '0xFF'))).withValues(alpha:0.15)
                        : AppColors.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: HabitIcon(
                      iconName: icon,
                      size: 24,
                      color: iconColor != null 
                          ? Color(int.parse(iconColor!.replaceAll('#', '0xFF')))
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title and Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: getDifficultyColor(context).withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              difficulty.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: getDifficultyColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  CupertinoIcons.arrow_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha:0.6),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Stats
            Row(
              children: [
                // Members
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.person_2_fill,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedMemberCount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      ' members',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 24),
                
                // Average Streak
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.flame_fill,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$averageStreak',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      ' day avg',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Tags
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}