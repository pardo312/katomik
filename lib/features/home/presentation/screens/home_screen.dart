import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katomik/shared/providers/habit_provider.dart';
import '../../../../shared/widgets/common/adaptive_widgets.dart';
import '../widgets/streak_header.dart';
import '../widgets/weekly_habit_tracker.dart';
import '../../../../shared/widgets/states/empty_state.dart';
import '../../../../l10n/app_localizations.dart';

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
            progress: habitProvider.getTodayProgress()['percentage'] ?? 0.0,
            allCompleted: habitProvider.areAllHabitsCompletedToday(),
          ),
          const SizedBox(height: 20),
          if (habitProvider.habits.isNotEmpty) ...[
            const WeeklyHabitTracker(),
          ] else ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: EmptyState(
                icon: Icons.add_circle_outline,
                title: AppLocalizations.of(context).noHabitsYet,
                subtitle: AppLocalizations.of(context).startBuildingFirstHabit,
              ),
            ),
          ],
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}