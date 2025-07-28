import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/shared/widgets/adaptive_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<Habit, Map<String, double>> _habitStats = {};
  
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final habits = provider.habits;
    
    Map<Habit, Map<String, double>> stats = {};
    
    for (final habit in habits) {
      if (habit.id != null) {
        final habitStats = await provider.getCompletionRateForHabit(habit.id!, 30);
        stats[habit] = habitStats;
      }
    }
    
    setState(() {
      _habitStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Statistics'),
      body: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          if (provider.habits.isEmpty) {
            return const Center(
              child: Text('No habits to show statistics for'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOverviewCard(provider),
              const SizedBox(height: 20),
              _buildCompletionChart(),
              const SizedBox(height: 20),
              _buildHabitBreakdown(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(HabitProvider provider) {
    final totalHabits = provider.habits.length;
    int totalStreak = 0;
    double averageCompletion = 0;
    
    for (final habit in provider.habits) {
      if (habit.id != null) {
        totalStreak += provider.getStreakForHabit(habit.id!);
        final stats = _habitStats[habit];
        if (stats != null) {
          averageCompletion += stats['completionRate'] ?? 0;
        }
      }
    }
    
    if (totalHabits > 0) {
      averageCompletion /= totalHabits;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'Active Habits',
                  value: totalHabits.toString(),
                  icon: Icons.track_changes,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  label: 'Total Streak',
                  value: '$totalStreak days',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                _buildStatItem(
                  label: 'Avg Completion',
                  value: '${averageCompletion.toStringAsFixed(0)}%',
                  icon: Icons.percent,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCompletionChart() {
    if (_habitStats.isEmpty) {
      return const SizedBox.shrink();
    }

    List<BarChartGroupData> barGroups = [];
    List<String> habitNames = [];
    
    int index = 0;
    _habitStats.forEach((habit, stats) {
      final completionRate = stats['completionRate'] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: completionRate,
              color: Color(int.parse(habit.color)),
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
      habitNames.add(habit.name);
      index++;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Rates (Last 30 Days)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < habitNames.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                habitNames[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                  ),
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Breakdown',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ..._habitStats.entries.map((entry) {
              final habit = entry.key;
              final stats = entry.value;
              final completionRate = stats['completionRate'] ?? 0;
              final completedDays = stats['completedDays']?.toInt() ?? 0;
              final color = Color(int.parse(habit.color));
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          habit.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${completionRate.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: completionRate / 100,
                      backgroundColor: color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedDays days completed in the last 30 days',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}