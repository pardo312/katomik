import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';

class CommunityStats extends StatelessWidget {
  final int memberCount;
  final int averageStreak;

  const CommunityStats({
    super.key,
    required this.memberCount,
    required this.averageStreak,
  });

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
    return Row(
      children: [
        _buildStatItem(
          context,
          icon: CupertinoIcons.person_2_fill,
          value: formattedMemberCount,
          label: 'members',
          iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          context,
          icon: CupertinoIcons.flame_fill,
          value: '$averageStreak',
          label: 'day avg',
          iconColor: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          ' $label',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}