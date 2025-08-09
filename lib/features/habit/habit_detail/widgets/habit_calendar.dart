import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../../core/utils/date_utils.dart';

class HabitCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final Color habitColor;
  final Function(DateTime) isDateCompleted;
  final Function(DateTime) onDateTap;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  
  const HabitCalendar({
    super.key,
    required this.focusedMonth,
    required this.habitColor,
    required this.isDateCompleted,
    required this.onDateTap,
    required this.onPreviousMonth,
    required this.onNextMonth,
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildMonthNavigator(context),
                const SizedBox(height: 16),
                _buildCalendarGrid(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthNavigator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Platform.isIOS ? CupertinoIcons.chevron_left : Icons.chevron_left,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onPreviousMonth,
        ),
        Text(
          _getMonthName(focusedMonth).toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(
            Platform.isIOS ? CupertinoIcons.chevron_right : Icons.chevron_right,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onNextMonth,
        ),
      ],
    );
  }
  
  Widget _buildCalendarGrid(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7;
    
    return Column(
      children: [
        _buildWeekDayHeaders(context),
        const SizedBox(height: 8),
        _buildCalendarWeeks(context, firstWeekday, daysInMonth),
      ],
    );
  }
  
  Widget _buildWeekDayHeaders(BuildContext context) {
    const weekDays = ['d', 'l', 'm', 'm', 'j', 'v', 's'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekDays.map((day) => SizedBox(
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
      )).toList(),
    );
  }
  
  Widget _buildCalendarWeeks(BuildContext context, int firstWeekday, int daysInMonth) {
    List<Widget> weeks = [];
    
    for (int weekStart = 0; weekStart < 42; weekStart += 7) {
      weeks.add(_buildCalendarWeek(context, weekStart, firstWeekday, daysInMonth));
      if (weekStart + 7 - firstWeekday >= daysInMonth) break;
    }
    
    return Column(children: weeks);
  }
  
  Widget _buildCalendarWeek(BuildContext context, int weekStartIndex, int firstWeekday, int daysInMonth) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: _buildWeekDays(context, weekStartIndex, firstWeekday, daysInMonth),
      ),
    );
  }
  
  List<Widget> _buildWeekDays(BuildContext context, int weekStartIndex, int firstWeekday, int daysInMonth) {
    List<Widget> widgets = [];
    List<int> weekIndices = [];
    List<DateTime> weekDates = [];
    List<bool> weekCompleted = [];
    
    for (int i = 0; i < 7; i++) {
      int index = weekStartIndex + i;
      weekIndices.add(index);
      
      if (index >= firstWeekday && index < firstWeekday + daysInMonth) {
        final day = index - firstWeekday + 1;
        final date = DateTime(focusedMonth.year, focusedMonth.month, day);
        weekDates.add(date);
        weekCompleted.add(isDateCompleted(date));
      } else {
        weekDates.add(DateTime(0));
        weekCompleted.add(false);
      }
    }
    
    int i = 0;
    while (i < 7) {
      final index = weekIndices[i];
      final date = weekDates[i];
      final isCompleted = weekCompleted[i];
      final isValidDate = date.year != 0;
      
      if (isValidDate && isCompleted) {
        int groupStart = i;
        int groupEnd = i;
        
        while (groupEnd < 6 && weekDates[groupEnd + 1].year != 0 && weekCompleted[groupEnd + 1]) {
          groupEnd++;
        }
        
        if (groupEnd > groupStart) {
          widgets.add(_buildGroupedCalendarDays(context, weekDates.sublist(groupStart, groupEnd + 1), groupEnd - groupStart + 1));
          i = groupEnd + 1;
        } else {
          widgets.add(_buildSingleCalendarDay(context, index, firstWeekday, daysInMonth));
          i++;
        }
      } else {
        widgets.add(_buildSingleCalendarDay(context, index, firstWeekday, daysInMonth));
        i++;
      }
    }
    
    return widgets;
  }
  
  Widget _buildGroupedCalendarDays(BuildContext context, List<DateTime> dates, int count) {
    return Expanded(
      flex: count,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: habitColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: dates.map((date) {
            final isToday = HomeDateUtils.isSameDay(date, DateTime.now());
            return Expanded(
              child: GestureDetector(
                onTap: () => onDateTap(date),
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
  
  Widget _buildSingleCalendarDay(BuildContext context, int index, int firstWeekday, int daysInMonth) {
    if (index < firstWeekday || index >= firstWeekday + daysInMonth) {
      return _buildOutOfMonthDay(context, index, firstWeekday, daysInMonth);
    }
    
    final day = index - firstWeekday + 1;
    final date = DateTime(focusedMonth.year, focusedMonth.month, day);
    final isCompleted = isDateCompleted(date);
    final isToday = HomeDateUtils.isSameDay(date, DateTime.now());
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onDateTap(date),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? habitColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted
                  ? Colors.transparent
                  : isToday
                      ? habitColor
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              width: isToday && !isCompleted ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isCompleted ? Colors.white : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildOutOfMonthDay(BuildContext context, int index, int firstWeekday, int daysInMonth) {
    final prevMonthLastDay = DateTime(focusedMonth.year, focusedMonth.month, 0).day;
    final nextMonthDay = index - firstWeekday - daysInMonth + 1;
    final prevMonthDay = prevMonthLastDay - firstWeekday + index + 1;
    
    return Expanded(
      child: Center(
        child: Text(
          index < firstWeekday ? '$prevMonthDay' : '$nextMonthDay',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
  
  String _getMonthName(DateTime date) {
    const months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
    ];
    return months[date.month - 1];
  }
}