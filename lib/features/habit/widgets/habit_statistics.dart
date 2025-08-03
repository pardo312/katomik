import 'package:flutter/material.dart';

class HabitStatistics extends StatelessWidget {
  final Map<String, double>? stats;

  const HabitStatistics({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

    final completionRate = stats!['completionRate'] ?? 0;
    final completedDays = stats!['completedDays']?.toInt() ?? 0;
    final totalDays = stats!['totalDays']?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 30 Days',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: completionRate / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${completionRate.toStringAsFixed(1)}% completion rate',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '$completedDays out of $totalDays days completed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}