import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:katomik/shared/models/habit.dart';
import 'habit_icon.dart';
import 'package:katomik/features/habit/presentation/screens/habit_detail_screen.dart';
import 'package:katomik/core/utils/date_utils.dart';
import 'package:katomik/core/utils/color_utils.dart';
import 'package:katomik/shared/providers/navigation_provider.dart';

class HabitRow extends StatelessWidget {
  final Habit habit;
  final List<DateTime> dates;
  final Function(String habitId, DateTime date) onToggleCompletion;
  final Function(String habitId, DateTime date) isCompleted;
  final bool showIcon;

  const HabitRow({
    super.key,
    required this.habit,
    required this.dates,
    required this.onToggleCompletion,
    required this.isCompleted,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.parseColor(habit.color);
    final today = DateTime.now();

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainer.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          if (showIcon) _buildHabitIcon(context, color),
          ..._buildCompletionCheckmarks(context, color, today),
        ],
      ),
    );
  }

  Widget _buildHabitIcon(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () => _navigateToHabitDetail(context),
      child: Container(
        width: 60,
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HabitIcon(iconName: habit.icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCompletionCheckmarks(
    BuildContext context,
    Color color,
    DateTime today,
  ) {
    final widgets = <Widget>[];
    int i = 0;

    while (i < dates.length) {
      final startIndex = i;
      final date = dates[i];
      final completed = habit.id != null && isCompleted(habit.id!, date);

      if (completed) {
        // Find end of consecutive completed group
        int endIndex = i;
        while (endIndex < dates.length - 1 &&
            habit.id != null &&
            isCompleted(habit.id!, dates[endIndex + 1])) {
          endIndex++;
        }

        // Build grouped checkmarks
        if (endIndex > startIndex) {
          // Multiple consecutive days
          widgets.add(
            _buildGroupedCheckmarks(
              context,
              color,
              dates.sublist(startIndex, endIndex + 1),
              today,
            ),
          );
          i = endIndex + 1;
        } else {
          // Single completed day
          widgets.add(
            _buildSingleCheckmark(
              context,
              color,
              date,
              completed,
              HomeDateUtils.isSameDay(date, today),
            ),
          );
          i++;
        }
      } else {
        // Uncompleted day
        widgets.add(
          _buildSingleCheckmark(
            context,
            color,
            date,
            completed,
            HomeDateUtils.isSameDay(date, today),
          ),
        );
        i++;
      }
    }

    return widgets;
  }

  Widget _buildSingleCheckmark(
    BuildContext context,
    Color color,
    DateTime date,
    bool completed,
    bool isToday,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: isToday && habit.id != null
            ? () => onToggleCompletion(habit.id!, date)
            : null,
        child: Center(
          child: _buildCheckmark(context, color, completed, isToday),
        ),
      ),
    );
  }

  Widget _buildGroupedCheckmarks(
    BuildContext context,
    Color color,
    List<DateTime> groupDates,
    DateTime today,
  ) {
    return Expanded(
      flex: groupDates.length,
      child: Container(
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: groupDates.map((date) {
            final isToday = HomeDateUtils.isSameDay(date, today);
            return Expanded(
              child: GestureDetector(
                onTap: isToday && habit.id != null
                    ? () => onToggleCompletion(habit.id!, date)
                    : null,
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.white.withValues(alpha: isToday ? 1.0 : 0.8),
                    size: 18,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCheckmark(
    BuildContext context,
    Color color,
    bool completed,
    bool isToday,
  ) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: completed
            ? color.withValues(alpha: isToday ? 1.0 : 0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: completed
              ? Colors.transparent
              : Theme.of(context).colorScheme.surfaceContainerHighest
                    .withValues(alpha: isToday ? 1.0 : 0.5),
          width: 2,
        ),
      ),
      child: completed
          ? Icon(
              Icons.check,
              color: Colors.white.withValues(alpha: isToday ? 1.0 : 0.8),
              size: 18,
            )
          : null,
    );
  }

  void _navigateToHabitDetail(BuildContext context) {
    // Hide FAB when navigating to detail
    context.read<NavigationProvider>().hideHomeFab();

    Navigator.push(
      context,
      Platform.isIOS
          ? CupertinoPageRoute(builder: (_) => HabitDetailScreen(habit: habit))
          : MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
    ).then((_) {
      // Show FAB again when returning
      if (context.mounted) {
        context.read<NavigationProvider>().showHomeFabIfNeeded();
      }
    });
  }
}
