import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/habit_provider.dart';
import '../utils/date_utils.dart';
import 'date_header.dart';
import 'habit_row.dart';

class WeeklyHabitTracker extends StatelessWidget {
  const WeeklyHabitTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final dates = HomeDateUtils.getLastNDays(5);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context),
              DateHeader(dates: dates),
              _buildHabitsList(context, habitProvider, dates),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        'Semana',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHabitsList(BuildContext context, HabitProvider provider, List<DateTime> dates) {
    return Container(
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
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: Column(
          children: _buildHabitRows(context, provider, dates),
        ),
      ),
    );
  }

  List<Widget> _buildHabitRows(BuildContext context, HabitProvider provider, List<DateTime> dates) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < provider.habits.length; i++) {
      widgets.add(
        HabitRow(
          habit: provider.habits[i],
          dates: dates,
          onToggleCompletion: provider.toggleHabitCompletion,
          isCompleted: provider.isHabitCompletedForDate,
        ),
      );
      
      if (i < provider.habits.length - 1) {
        widgets.add(_buildDivider(context));
      }
    }
    
    return widgets;
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.5),
    );
  }
}