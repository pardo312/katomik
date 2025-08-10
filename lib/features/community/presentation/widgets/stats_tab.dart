import 'package:flutter/material.dart';
import '../widgets/community_stats_card.dart';

class StatsTab extends StatelessWidget {
  final int memberCount;
  final int totalCompletions;
  final int averageStreak;
  final double successRate;
  final String createdDate;

  const StatsTab({
    super.key,
    required this.memberCount,
    required this.totalCompletions,
    required this.averageStreak,
    required this.successRate,
    required this.createdDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CommunityStatsCard(
              memberCount: memberCount,
              totalCompletions: totalCompletions,
              averageStreak: averageStreak,
              successRate: successRate,
              createdDate: createdDate,
            ),
            const SizedBox(height: 16),
            _buildAdditionalStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStats(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildGrowthItem(
              context,
              'Active Members',
              '${(memberCount * 0.7).round()}',
              'Last 7 days',
            ),
            const SizedBox(height: 8),
            _buildGrowthItem(
              context,
              'Completion Rate',
              '${(successRate * 100).toStringAsFixed(1)}%',
              'Overall',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthItem(
    BuildContext context,
    String title,
    String value,
    String subtitle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}