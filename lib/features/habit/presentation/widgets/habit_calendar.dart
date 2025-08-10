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
    final weeks = <Widget>[];
    
    for (int weekStart = 0; weekStart < 42; weekStart += 7) {
      weeks.add(_buildWeekRow(context, weekStart, firstWeekday, daysInMonth));
      if (weekStart + 7 - firstWeekday >= daysInMonth) break;
    }
    
    return Column(children: weeks);
  }
  
  Widget _buildWeekRow(BuildContext context, int weekStartIndex, int firstWeekday, int daysInMonth) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: _generateWeekDays(context, weekStartIndex, firstWeekday, daysInMonth),
      ),
    );
  }
  
  List<Widget> _generateWeekDays(BuildContext context, int weekStartIndex, int firstWeekday, int daysInMonth) {
    final weekData = _prepareWeekData(weekStartIndex, firstWeekday, daysInMonth);
    final widgets = <Widget>[];
    var currentIndex = 0;
    
    while (currentIndex < 7) {
      final processResult = _processDay(context, weekData, currentIndex, firstWeekday, daysInMonth);
      widgets.add(processResult.widget);
      currentIndex = processResult.nextIndex;
    }
    
    return widgets;
  }
  
  _WeekData _prepareWeekData(int weekStartIndex, int firstWeekday, int daysInMonth) {
    final indices = <int>[];
    final dates = <DateTime>[];
    final completions = <bool>[];
    
    for (int i = 0; i < 7; i++) {
      final index = weekStartIndex + i;
      indices.add(index);
      
      if (_isValidDay(index, firstWeekday, daysInMonth)) {
        final date = _createDate(index, firstWeekday);
        dates.add(date);
        completions.add(isDateCompleted(date));
      } else {
        dates.add(DateTime(0));
        completions.add(false);
      }
    }
    
    return _WeekData(indices, dates, completions);
  }
  
  bool _isValidDay(int index, int firstWeekday, int daysInMonth) {
    return index >= firstWeekday && index < firstWeekday + daysInMonth;
  }
  
  DateTime _createDate(int index, int firstWeekday) {
    final day = index - firstWeekday + 1;
    return DateTime(focusedMonth.year, focusedMonth.month, day);
  }
  
  _ProcessResult _processDay(BuildContext context, _WeekData weekData, int startIndex, int firstWeekday, int daysInMonth) {
    final date = weekData.dates[startIndex];
    final isCompleted = weekData.completions[startIndex];
    
    if (!_canGroup(date, isCompleted)) {
      return _ProcessResult(
        widget: _buildDay(context, weekData.indices[startIndex], firstWeekday, daysInMonth),
        nextIndex: startIndex + 1,
      );
    }
    
    final groupEnd = _findGroupEnd(weekData, startIndex);
    
    if (groupEnd > startIndex) {
      return _ProcessResult(
        widget: _buildGroupedDays(context, weekData, startIndex, groupEnd),
        nextIndex: groupEnd + 1,
      );
    }
    
    return _ProcessResult(
      widget: _buildDay(context, weekData.indices[startIndex], firstWeekday, daysInMonth),
      nextIndex: startIndex + 1,
    );
  }
  
  bool _canGroup(DateTime date, bool isCompleted) {
    return date.year != 0 && isCompleted;
  }
  
  int _findGroupEnd(_WeekData weekData, int startIndex) {
    var endIndex = startIndex;
    
    while (endIndex < 6) {
      final nextDate = weekData.dates[endIndex + 1];
      final nextCompleted = weekData.completions[endIndex + 1];
      
      if (!_canGroup(nextDate, nextCompleted)) break;
      endIndex++;
    }
    
    return endIndex;
  }
  
  Widget _buildGroupedDays(BuildContext context, _WeekData weekData, int startIndex, int endIndex) {
    final groupDates = weekData.dates.sublist(startIndex, endIndex + 1);
    final groupSize = endIndex - startIndex + 1;
    
    return Expanded(
      flex: groupSize,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: habitColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: groupDates.map((date) => _buildGroupedDayContent(date)).toList(),
        ),
      ),
    );
  }
  
  Widget _buildGroupedDayContent(DateTime date) {
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
  }
  
  Widget _buildDay(BuildContext context, int index, int firstWeekday, int daysInMonth) {
    if (!_isValidDay(index, firstWeekday, daysInMonth)) {
      return _buildEmptyDay(context, index, firstWeekday, daysInMonth);
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
          decoration: _dayDecoration(context, isCompleted, isToday),
          child: Center(
            child: Text(
              '$day',
              style: _dayTextStyle(context, isCompleted, isToday),
            ),
          ),
        ),
      ),
    );
  }
  
  BoxDecoration _dayDecoration(BuildContext context, bool isCompleted, bool isToday) {
    return BoxDecoration(
      color: isCompleted ? habitColor : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: _dayBorderColor(context, isCompleted, isToday),
        width: isToday && !isCompleted ? 2 : 1,
      ),
    );
  }
  
  Color _dayBorderColor(BuildContext context, bool isCompleted, bool isToday) {
    if (isCompleted) return Colors.transparent;
    if (isToday) return habitColor;
    return Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
  }
  
  TextStyle _dayTextStyle(BuildContext context, bool isCompleted, bool isToday) {
    return TextStyle(
      fontSize: 14,
      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
      color: isCompleted ? Colors.white : Theme.of(context).colorScheme.onSurface,
    );
  }
  
  Widget _buildEmptyDay(BuildContext context, int index, int firstWeekday, int daysInMonth) {
    final dayNumber = _calculateEmptyDayNumber(index, firstWeekday, daysInMonth);
    
    return Expanded(
      child: Center(
        child: Text(
          '$dayNumber',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
  
  int _calculateEmptyDayNumber(int index, int firstWeekday, int daysInMonth) {
    if (index < firstWeekday) {
      final prevMonthLastDay = DateTime(focusedMonth.year, focusedMonth.month, 0).day;
      return prevMonthLastDay - firstWeekday + index + 1;
    }
    return index - firstWeekday - daysInMonth + 1;
  }
  
  String _getMonthName(DateTime date) {
    const months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
    ];
    return months[date.month - 1];
  }
}

class _WeekData {
  final List<int> indices;
  final List<DateTime> dates;
  final List<bool> completions;
  
  _WeekData(this.indices, this.dates, this.completions);
}

class _ProcessResult {
  final Widget widget;
  final int nextIndex;
  
  _ProcessResult({required this.widget, required this.nextIndex});
}