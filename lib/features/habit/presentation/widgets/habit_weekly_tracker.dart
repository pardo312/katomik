import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katomik/shared/models/habit.dart';
import 'package:katomik/shared/providers/habit_provider.dart';
import 'package:katomik/core/utils/date_utils.dart';
import '../../../../shared/widgets/common/date_header.dart';
import '../../../../shared/widgets/common/habit_row.dart';

class HabitWeeklyTracker extends StatelessWidget {
  final Habit habit;
  final Function(DateTime) isDateCompleted;
  final VoidCallback onCompletionToggled;

  const HabitWeeklyTracker({
    super.key,
    required this.habit,
    required this.isDateCompleted,
    required this.onCompletionToggled,
  });

  @override
  Widget build(BuildContext context) {
    final dates = HomeDateUtils.getLastNDays(5);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DateHeader(dates: dates, showIconSpace: false),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: 1,
              ),
            ),
            child: HabitRow(
              habit: habit,
              dates: dates,
              onToggleCompletion: (habitId, date) {
                Provider.of<HabitProvider>(
                  context,
                  listen: false,
                ).toggleHabitCompletion(habitId, date);
                onCompletionToggled();
              },
              isCompleted: (habitId, date) => isDateCompleted(date),
              showIcon: false,
            ),
          ),
        ],
      ),
    );
  }
}