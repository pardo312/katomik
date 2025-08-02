import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/data/models/habit_completion.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/shared/widgets/adaptive_widgets.dart';
import 'package:katomik/features/habit/screens/add_habit_screen.dart';
import 'dart:io';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit _habit;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<HabitCompletion> _completions = [];
  Map<String, double>? _stats;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _selectedDay = DateTime.now();
    _loadCompletions();
    _loadStats();
  }

  Future<void> _loadCompletions() async {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final completions = await provider.getCompletionsForHabit(_habit.id!);
    setState(() {
      _completions = completions;
    });
  }

  Future<void> _loadStats() async {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final stats = await provider.getCompletionRateForHabit(_habit.id!, 30);
    setState(() {
      _stats = stats;
    });
  }

  void _deleteHabit() {
    AdaptiveDialog.show(
      context: context,
      title: 'Delete Habit',
      content: Text('Are you sure you want to delete "${_habit.name}"?'),
      actions: [
        AdaptiveDialogAction(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        AdaptiveDialogAction(
          text: 'Delete',
          isDestructive: true,
          onPressed: () {
            Provider.of<HabitProvider>(context, listen: false)
                .deleteHabit(_habit.id!);
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to home
          },
        ),
      ],
    );
  }

  bool _isDateCompleted(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _completions.any((c) => 
      c.date.toIso8601String().split('T')[0] == dateStr && c.isCompleted
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(_habit.color));
    
    return AdaptiveScaffold(
      title: Text(_habit.name),
      backgroundColor: Platform.isIOS ? null : Theme.of(context).colorScheme.surface,
      actions: [
        IconButton(
          icon: Icon(Platform.isIOS ? CupertinoIcons.pencil : Icons.edit),
          onPressed: () async {
            final provider = Provider.of<HabitProvider>(context, listen: false);
            await Navigator.push(
              context,
              Platform.isIOS
                  ? CupertinoPageRoute(
                      builder: (_) => AddHabitScreen(habitToEdit: _habit),
                    )
                  : MaterialPageRoute(
                      builder: (_) => AddHabitScreen(habitToEdit: _habit),
                    ),
            );
            if (!mounted) return;
            // Refresh habit data
            final updatedHabit = provider.habits.firstWhere((h) => h.id == _habit.id);
            setState(() {
              _habit = updatedHabit;
            });
          },
        ),
        IconButton(
          icon: Icon(Platform.isIOS ? CupertinoIcons.delete : Icons.delete),
          onPressed: _deleteHabit,
        ),
      ],
      body: ListView(
        children: [
          _buildHeader(color),
          _buildCalendar(color),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _habit.phrases.isNotEmpty ? _habit.phrases.join(' • ') : 'No phrases added',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (_habit.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _habit.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
                      child: Image.file(
                        File(_habit.images[index]),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: 100,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Platform.isIOS ? CupertinoIcons.photo : Icons.image,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoCard(
                icon: Icons.calendar_today,
                label: 'Started',
                value: DateFormat('MMM d, y').format(_habit.createdDate),
                color: color,
              ),
              const SizedBox(width: 12),
              Consumer<HabitProvider>(
                builder: (context, provider, _) {
                  final streak = provider.getStreakForHabit(_habit.id!);
                  return _buildInfoCard(
                    icon: Icons.local_fire_department,
                    label: 'Current Streak',
                    value: '$streak days',
                    color: Colors.orange,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(Color color) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: TableCalendar(
              firstDay: _habit.createdDate,
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                return _isDateCompleted(day) ? ['completed'] : [];
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markerDecoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: color.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: color.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  
                  // Toggle completion for selected day
                  if (!selectedDay.isAfter(DateTime.now())) {
                    provider.toggleHabitCompletion(_habit.id!, selectedDay);
                    _loadCompletions();
                  }
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatistics() {
    if (_stats == null) {
      return const SizedBox.shrink();
    }

    final completionRate = _stats!['completionRate'] ?? 0;
    final completedDays = _stats!['completedDays']?.toInt() ?? 0;
    final totalDays = _stats!['totalDays']?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 30 Days',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: completionRate / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${completionRate.toStringAsFixed(1)}% completion rate',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '$completedDays out of $totalDays days completed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}