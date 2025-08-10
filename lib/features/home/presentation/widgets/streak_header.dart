import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class StreakHeader extends StatelessWidget {
  final int totalStreak;
  final double progress;
  final bool allCompleted;

  const StreakHeader({
    super.key,
    required this.totalStreak,
    required this.progress,
    required this.allCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTitle(context),
          const SizedBox(height: 16),
          _buildStreakBadge(context),
          const SizedBox(height: 16),
          _buildProgressBar(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 12),
        Text(
          'Katomik',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: allCompleted ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Platform.isIOS
                ? CupertinoIcons.flame_fill
                : Icons.local_fire_department,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '$totalStreak días',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth - 40;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 12,
              width: barWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              height: 12,
              width: barWidth * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow, Colors.orange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        );
      },
    );
  }
}