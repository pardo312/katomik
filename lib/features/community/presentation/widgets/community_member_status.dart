import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';

class CommunityMemberStatus extends StatelessWidget {
  final bool isMember;
  final int memberCount;
  final int userRank;
  final int userStreak;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onGovernance;

  const CommunityMemberStatus({
    super.key,
    required this.isMember,
    required this.memberCount,
    required this.userRank,
    required this.userStreak,
    required this.onJoin,
    required this.onLeave,
    required this.onGovernance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMemberInfo(context),
          const SizedBox(height: 12),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildMemberInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoItem(
          context,
          icon: CupertinoIcons.person_2_fill,
          value: memberCount.toString(),
          label: 'Members',
        ),
        if (isMember) ...[
          _buildInfoItem(
            context,
            icon: CupertinoIcons.chart_bar_alt_fill,
            value: '#$userRank',
            label: 'Your Rank',
          ),
          _buildInfoItem(
            context,
            icon: CupertinoIcons.flame_fill,
            value: userStreak.toString(),
            label: 'Your Streak',
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (!isMember)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onJoin,
              icon: const Icon(CupertinoIcons.add_circled),
              label: const Text('Join Community'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onGovernance,
              icon: const Icon(CupertinoIcons.chart_pie),
              label: const Text('Governance'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onLeave,
            icon: Icon(
              CupertinoIcons.xmark_circle,
              color: AppColors.error,
            ),
            tooltip: 'Leave Community',
          ),
        ],
      ],
    );
  }
}