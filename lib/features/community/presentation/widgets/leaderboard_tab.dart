import 'package:flutter/material.dart';
import '../../../../shared/models/community_models.dart';
import '../widgets/leaderboard_list.dart';

class LeaderboardTab extends StatelessWidget {
  final String communityId;
  final bool isMember;
  final int? userRank;
  final LeaderboardEntry? currentUserEntry;
  final List<LeaderboardEntry> leaderboard;
  final String selectedTimeframe;
  final Function(String) onTimeframeChanged;

  const LeaderboardTab({
    super.key,
    required this.communityId,
    required this.isMember,
    this.userRank,
    this.currentUserEntry,
    required this.leaderboard,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimeframeSelector(context),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: LeaderboardList(
              communityId: communityId,
              currentUserRank: isMember ? userRank : null,
              currentUserEntry: isMember ? currentUserEntry : null,
              leaderboard: leaderboard,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTimeframeButton(context, 'Week', 'WEEKLY'),
          const SizedBox(width: 8),
          _buildTimeframeButton(context, 'Month', 'MONTHLY'),
          const SizedBox(width: 8),
          _buildTimeframeButton(context, 'All Time', 'ALL_TIME'),
        ],
      ),
    );
  }

  Widget _buildTimeframeButton(BuildContext context, String label, String value) {
    final isSelected = selectedTimeframe == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTimeframeChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}