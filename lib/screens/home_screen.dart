import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/habit_icon.dart';
import 'dart:io';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            if (habitProvider.isLoading) {
              return const Center(child: AdaptiveProgressIndicator());
            }

            return Column(
              children: [
                _buildStreakHeader(context, habitProvider),
                const SizedBox(height: 20),
                _buildWeekView(context, habitProvider),
                const SizedBox(height: 20),
                if (habitProvider.habits.isEmpty)
                  Expanded(child: _buildEmptyState(context)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildStreakHeader(BuildContext context, HabitProvider provider) {
    final totalStreak = provider.getTotalStreak();
    final progress = provider.getTodayProgress();
    final allCompleted = provider.areAllHabitsCompletedToday();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Text(
                'Hoy Total',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: allCompleted ? Colors.orange : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Platform.isIOS
                      ? CupertinoIcons.flame_fill
                      : Icons.local_fire_department,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '$totalStreak días',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                height: 12,
                width: MediaQuery.of(context).size.width * 0.8 * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow, Colors.orange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                left: (MediaQuery.of(context).size.width * 0.8 * progress) - 12,
                top: -6,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, HabitProvider provider) {
    final today = DateTime.now();
    final dates = List.generate(5, (i) => today.subtract(Duration(days: i)));
    final dateFormat = DateFormat.E();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Semana',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Header with dates
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 60), // Space for habit icons
                ...dates.map((date) {
                  final isToday =
                      DateFormat.yMd().format(date) ==
                      DateFormat.yMd().format(today);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dateFormat.format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          // Habit rows
          Container(
            constraints: BoxConstraints(
              maxHeight: provider.habits.length > 3
                  ? 200
                  : provider.habits.length * 60.0,
            ),
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
              child: ListView.builder(
                shrinkWrap: true,
                physics: provider.habits.length > 3
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: provider.habits.length,
                itemBuilder: (context, index) {
                  final habit = provider.habits[index];
                  final color = Color(int.parse(habit.color));

                  // Create colorful backgrounds like the reference
                  final backgroundColors = [
                    const Color(0xFF8B4513).withValues(alpha: 0.3), // Brown
                    const Color(
                      0xFF4682B4,
                    ).withValues(alpha: 0.3), // Steel Blue
                    const Color(0xFF8B4513).withValues(alpha: 0.3), // Brown
                  ];

                  return Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: index < 3
                          ? backgroundColors[index % 3]
                          : Theme.of(context).colorScheme.surfaceContainer
                                .withValues(alpha: 0.3),
                    ),
                    child: Row(
                      children: [
                        // Habit icon
                        Container(
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
                        // Completion checkmarks
                        ...dates.map((date) {
                          final isCompleted =
                              habit.id != null &&
                              provider.isHabitCompletedForDate(habit.id!, date);
                          final isToday =
                              DateFormat.yMd().format(date) ==
                              DateFormat.yMd().format(today);

                          return Expanded(
                            child: GestureDetector(
                              onTap: isToday
                                  ? () {
                                      if (habit.id != null) {
                                        provider.toggleHabitCompletion(
                                          habit.id!,
                                          date,
                                        );
                                      }
                                    }
                                  : null,
                              child: Center(
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? color.withValues(
                                            alpha: isToday ? 1.0 : 0.6,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCompleted
                                          ? Colors.transparent
                                          : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(
                                                  alpha: isToday ? 1.0 : 0.5,
                                                ),
                                      width: 2,
                                    ),
                                  ),
                                  child: isCompleted
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white.withValues(
                                            alpha: isToday ? 1.0 : 0.8,
                                          ),
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Platform.isIOS ? CupertinoIcons.sparkles : Icons.auto_awesome,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No habits yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start building better habits today!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
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
      );
    }

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddHabitScreen()),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
