import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../../models/habit.dart';
import '../../../../widgets/habit_icon.dart';
import '../../add_habit_screen.dart';
import '../utils/date_utils.dart';

class HabitRow extends StatelessWidget {
  final Habit habit;
  final List<DateTime> dates;
  final Function(int habitId, DateTime date) onToggleCompletion;
  final Function(int habitId, DateTime date) isCompleted;

  const HabitRow({
    super.key,
    required this.habit,
    required this.dates,
    required this.onToggleCompletion,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(habit.color));
    final today = DateTime.now();

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          _buildHabitIcon(context, color),
          ..._buildCompletionCheckmarks(context, color, today),
        ],
      ),
    );
  }

  Widget _buildHabitIcon(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () => _navigateToEditHabit(context),
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
            child: HabitIcon(
              iconName: habit.icon,
              size: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCompletionCheckmarks(BuildContext context, Color color, DateTime today) {
    return dates.map((date) {
      final completed = habit.id != null && isCompleted(habit.id!, date);
      final isToday = HomeDateUtils.isSameDay(date, today);

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
    }).toList();
  }

  Widget _buildCheckmark(BuildContext context, Color color, bool completed, bool isToday) {
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
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
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

  void _navigateToEditHabit(BuildContext context) {
    Navigator.push(
      context,
      Platform.isIOS
          ? CupertinoPageRoute(
              builder: (_) => AddHabitScreen(habitToEdit: habit),
            )
          : MaterialPageRoute(
              builder: (_) => AddHabitScreen(habitToEdit: habit),
            ),
    );
  }
}