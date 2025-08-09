import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'community_icon.dart';
import 'community_badges.dart';
import 'community_stats.dart';
import 'community_tags.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _buildCardDecoration(context),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildDescription(context),
            const SizedBox(height: 12),
            CommunityStats(
              memberCount: memberCount,
              averageStreak: averageStreak,
            ),
            CommunityTags(tags: tags),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDark
          ? Theme.of(context).colorScheme.surfaceContainer
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.5 : 0.4,
        ),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.shadow.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CommunityIcon(
          icon: icon,
          iconColor: iconColor,
        ),
        const SizedBox(width: 12),
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
              CommunityBadges(
                category: category,
                difficulty: difficulty,
              ),
            ],
          ),
        ),
        Icon(
          CupertinoIcons.arrow_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}