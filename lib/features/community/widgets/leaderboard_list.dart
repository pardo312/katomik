import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/community_service.dart';

class LeaderboardList extends StatelessWidget {
  final String communityId;
  final int? currentUserRank;
  final LeaderboardEntry? currentUserEntry;
  final List<LeaderboardEntry> leaderboard;

  const LeaderboardList({
    super.key,
    required this.communityId,
    this.currentUserRank,
    this.currentUserEntry,
    required this.leaderboard,
  });

  @override
  Widget build(BuildContext context) {
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No leaderboard data yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount:
          leaderboard.length +
          (currentUserRank != null && currentUserRank! > 5 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < leaderboard.length) {
          final entry = leaderboard[index];
          return _buildLeaderboardEntry(entry, false);
        } else if (currentUserRank != null && currentUserRank! > 5) {
          // Show current user position if not in top 5
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: Colors.grey.shade300),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: Colors.grey.shade300),
                    ),
                  ],
                ),
              ),
              // Show actual current user data
              if (currentUserEntry != null)
                _buildLeaderboardEntry(currentUserEntry!, true)
              else
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$currentUserRank',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'You',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, bool isCurrentUser) {
    final bool isTopThree = entry.rank <= 3;
    final member = entry.member;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: _getMedalColor(entry.rank).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree
                  ? _getMedalColor(entry.rank).withValues(alpha: 0.2)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTopThree
                  ? Text(
                      _getMedalEmoji(entry.rank),
                      style: const TextStyle(fontSize: 20),
                    )
                  : Text(
                      '${entry.rank}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser
                            ? AppColors.primary
                            : Colors.grey.shade700,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar/Initial
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.user.name.isNotEmpty
                    ? member.user.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCurrentUser ? AppColors.primary : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.completionRate.toStringAsFixed(1)}% completion',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.flame_fill,
                    size: 20,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${member.currentStreak}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Text(
                'days',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
