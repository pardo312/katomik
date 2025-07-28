import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/shared/widgets/adaptive_widgets.dart';
import '../widgets/streak_header.dart';
import '../widgets/weekly_habit_tracker.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          if (habitProvider.isLoading) {
            return const Center(child: AdaptiveProgressIndicator());
          }

          return _buildContent(context, habitProvider);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HabitProvider habitProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreakHeader(
            totalStreak: habitProvider.getTotalStreak(),
            progress: habitProvider.getTodayProgress(),
            allCompleted: habitProvider.areAllHabitsCompletedToday(),
          ),
          const SizedBox(height: 20),
          if (habitProvider.habits.isNotEmpty) ...[
            const WeeklyHabitTracker(),
          ] else ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const EmptyState(),
            ),
          ],
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}