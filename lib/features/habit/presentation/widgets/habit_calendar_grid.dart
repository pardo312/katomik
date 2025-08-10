import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katomik/l10n/app_localizations.dart';
import 'package:katomik/shared/models/habit.dart';
import 'package:katomik/shared/providers/habit_provider.dart';
import 'package:katomik/core/utils/date_utils.dart';

class HabitCalendarGrid extends StatelessWidget {
  final Habit habit;
  final DateTime focusedMonth;
  final Color color;
  final Function(DateTime) isDateCompleted;
  final VoidCallback onCompletionToggled;

  const HabitCalendarGrid({
    super.key,
    required this.habit,
    required this.focusedMonth,
    required this.color,
    required this.isDateCompleted,
    required this.onCompletionToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _getMonthName(focusedMonth, context).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCalendarGrid(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppLocalizations.of(context).sundayShort,
            AppLocalizations.of(context).mondayShort,
            AppLocalizations.of(context).tuesdayShort,
            AppLocalizations.of(context).wednesdayShort,
            AppLocalizations.of(context).thursdayShort,
            AppLocalizations.of(context).fridayShort,
            AppLocalizations.of(context).saturdayShort,
          ]
              .map(
                (day) => SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        _buildCalendarWeeks(context, firstWeekday, daysInMonth),
      ],
    );
  }

  Widget _buildCalendarWeeks(BuildContext context, int firstWeekday, int daysInMonth) {
    List<Widget> weeks = [];

    for (int weekStart = 0; weekStart < 42; weekStart += 7) {
      weeks.add(
        _buildCalendarWeek(context, weekStart, firstWeekday, daysInMonth),
      );
      if (weekStart + 7 - firstWeekday >= daysInMonth) break;
    }

    return Column(children: weeks);
  }

  Widget _buildCalendarWeek(
    BuildContext context,
    int weekStartIndex,
    int firstWeekday,
    int daysInMonth,
  ) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: _buildWeekDays(
          context,
          weekStartIndex,
          firstWeekday,
          daysInMonth,
        ),
      ),
    );
  }

  List<Widget> _buildWeekDays(
    BuildContext context,
    int weekStartIndex,
    int firstWeekday,
    int daysInMonth,
  ) {
    List<Widget> widgets = [];
    List<int> weekIndices = [];
    List<DateTime> weekDates = [];
    List<bool> weekCompleted = [];

    // Collect week data
    for (int i = 0; i < 7; i++) {
      int index = weekStartIndex + i;
      weekIndices.add(index);

      if (index >= firstWeekday && index < firstWeekday + daysInMonth) {
        final day = index - firstWeekday + 1;
        final date = DateTime(focusedMonth.year, focusedMonth.month, day);
        weekDates.add(date);
        weekCompleted.add(isDateCompleted(date));
      } else {
        weekDates.add(DateTime(0)); // Placeholder for out-of-month days
        weekCompleted.add(false);
      }
    }

    // Build widgets with grouping
    int i = 0;
    while (i < 7) {
      final index = weekIndices[i];
      final date = weekDates[i];
      final isCompleted = weekCompleted[i];
      final isValidDate = date.year != 0;

      if (isValidDate && isCompleted) {
        // Find consecutive completed days
        int groupStart = i;
        int groupEnd = i;

        while (groupEnd < 6 &&
            weekDates[groupEnd + 1].year != 0 &&
            weekCompleted[groupEnd + 1]) {
          groupEnd++;
        }

        if (groupEnd > groupStart) {
          // Multiple consecutive days
          widgets.add(
            _buildGroupedCalendarDays(
              context,
              weekDates.sublist(groupStart, groupEnd + 1),
              groupEnd - groupStart + 1,
            ),
          );
          i = groupEnd + 1;
        } else {
          // Single completed day
          widgets.add(
            _buildSingleCalendarDay(context, index, firstWeekday, daysInMonth),
          );
          i++;
        }
      } else {
        // Uncompleted or out-of-month day
        widgets.add(
          _buildSingleCalendarDay(context, index, firstWeekday, daysInMonth),
        );
        i++;
      }
    }

    return widgets;
  }

  Widget _buildGroupedCalendarDays(
    BuildContext context,
    List<DateTime> dates,
    int count,
  ) {
    return Expanded(
      flex: count,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: dates.map((date) {
            final isToday = HomeDateUtils.isSameDay(date, DateTime.now());
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!date.isAfter(DateTime.now())) {
                    Provider.of<HabitProvider>(
                      context,
                      listen: false,
                    ).toggleHabitCompletion(habit.id!, date);
                    onCompletionToggled();
                  }
                },
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSingleCalendarDay(
    BuildContext context,
    int index,
    int firstWeekday,
    int daysInMonth,
  ) {
    if (index < firstWeekday || index >= firstWeekday + daysInMonth) {
      final prevMonthLastDay = DateTime(
        focusedMonth.year,
        focusedMonth.month,
        0,
      ).day;
      final nextMonthDay = index - firstWeekday - daysInMonth + 1;
      final prevMonthDay = prevMonthLastDay - firstWeekday + index + 1;

      return Expanded(
        child: Center(
          child: Text(
            index < firstWeekday ? '$prevMonthDay' : '$nextMonthDay',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      );
    }

    final day = index - firstWeekday + 1;
    final date = DateTime(focusedMonth.year, focusedMonth.month, day);
    final isCompleted = isDateCompleted(date);
    final isToday = HomeDateUtils.isSameDay(date, DateTime.now());

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!date.isAfter(DateTime.now())) {
            Provider.of<HabitProvider>(
              context,
              listen: false,
            ).toggleHabitCompletion(habit.id!, date);
            onCompletionToggled();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted
                  ? Colors.transparent
                  : isToday
                  ? color
                  : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
              width: isToday && !isCompleted ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isCompleted
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    return months[date.month - 1];
  }
}