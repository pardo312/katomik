import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'dart:io';

class HabitDetailHeader extends StatelessWidget {
  final Habit habit;
  final Color color;

  const HabitDetailHeader({
    super.key,
    required this.habit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.phrases.isNotEmpty ? habit.phrases.join(' • ') : 'No phrases added',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (habit.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: habit.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
                      child: Image.file(
                        File(habit.images[index]),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: 100,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Platform.isIOS ? CupertinoIcons.photo : Icons.image,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoCard(
                icon: Icons.calendar_today,
                label: 'Started',
                value: DateFormat('MMM d, y').format(habit.createdDate),
                color: color,
              ),
              const SizedBox(width: 12),
              Consumer<HabitProvider>(
                builder: (context, provider, _) {
                  final streak = provider.getStreakForHabit(habit.id!);
                  return _InfoCard(
                    icon: Icons.local_fire_department,
                    label: 'Current Streak',
                    value: '$streak days',
                    color: Colors.orange,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}