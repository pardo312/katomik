import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'statistics_screen.dart';
import '../widgets/adaptive_widgets.dart';
import 'dart:io';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Katomik'),
      actions: [
        IconButton(
          icon: Icon(Platform.isIOS ? CupertinoIcons.chart_bar : Icons.bar_chart),
          onPressed: () {
            Navigator.push(
              context,
              Platform.isIOS
                  ? CupertinoPageRoute(builder: (_) => const StatisticsScreen())
                  : MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            );
          },
        ),
      ],
      body: Column(
        children: [
          _buildDateHeader(context),
          Expanded(
            child: Consumer<HabitProvider>(
              builder: (context, habitProvider, child) {
                if (habitProvider.isLoading) {
                  return const Center(child: AdaptiveProgressIndicator());
                }

                if (habitProvider.habits.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: habitProvider.habits.length,
                  itemBuilder: (context, index) {
                    final habit = habitProvider.habits[index];
                    return _buildHabitCard(context, habit, habitProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Platform.isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                  size: 28,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const AddHabitScreen()),
                );
              },
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHabitScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Today',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(now),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Platform.isIOS ? CupertinoIcons.time : Icons.track_changes,
            size: 80,
            color: Platform.isIOS
                ? CupertinoColors.secondaryLabel
                : Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start building better habits today!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit, HabitProvider provider) {
    final today = DateTime.now();
    final isCompleted = provider.isHabitCompletedForDate(habit.id!, today);
    final streak = provider.getStreakForHabit(habit.id!);
    final color = Color(int.parse(habit.color));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            Platform.isIOS
                ? CupertinoPageRoute(
                    builder: (_) => HabitDetailScreen(habit: habit),
                  )
                : MaterialPageRoute(
                    builder: (_) => HabitDetailScreen(habit: habit),
                  ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (streak > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Platform.isIOS
                                ? CupertinoIcons.flame
                                : Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streak day streak',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Checkbox(
                value: isCompleted,
                onChanged: (_) {
                  provider.toggleHabitCompletion(habit.id!, today);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}