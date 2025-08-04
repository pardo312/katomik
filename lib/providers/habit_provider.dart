import 'package:flutter/foundation.dart';
import '../data/models/habit.dart';
import '../data/models/habit_completion.dart';
import '../data/services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();

  List<Habit> _habits = [];
  final Map<String, Map<String, HabitCompletion>> _completions =
      {}; // habitId -> dateStr -> completion
  final Map<String, int> _streaks = {}; // habitId -> streak count
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HabitProvider() {
    loadHabits();
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Loading habits from server...');
      _habits = await _habitService.getUserHabits();
      debugPrint('Loaded ${_habits.length} habits from server');

      // Load today's completions for all habits
      final today = DateTime.now();
      await loadCompletionsForDateRange(
        DateTime(today.year, today.month, today.day - 7),
        today,
      );

      // Calculate streaks for all habits
      for (final habit in _habits) {
        if (habit.id != null) {
          _streaks[habit.id!] = _calculateStreak(habit.id!);
        }
      }
    } catch (e) {
      _error = 'Failed to load habits: $e';
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCompletionsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      for (final habit in _habits) {
        if (habit.id == null) continue;

        final completions = await _habitService.getCompletions(
          habitId: habit.id!,
          startDate: startDate,
          endDate: endDate,
        );

        for (final completionData in completions) {
          final completion = HabitCompletion.fromServerJson(completionData);
          final dateStr = completion.date.toIso8601String().split('T')[0];

          if (!_completions.containsKey(habit.id!)) {
            _completions[habit.id!] = {};
          }
          _completions[habit.id!]![dateStr] = completion;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading completions: $e');
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      debugPrint('Creating habit: ${habit.name}');
      final newHabit = await _habitService.createHabit(
        name: habit.name,
        phrases: habit.phrases,
        color: habit.color,
        icon: habit.icon,
        reminderTime: habit.reminderTime,
        reminderDays: habit.reminderDays,
      );

      debugPrint('Created habit with ID: ${newHabit.id}');
      _habits.insert(0, newHabit);
      _streaks[newHabit.id!] = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create habit: $e';
      debugPrint('Error adding habit: $e');
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    if (habit.id == null) return;

    try {
      final updatedHabit = await _habitService.updateHabit(
        id: habit.id!,
        name: habit.name,
        phrases: habit.phrases,
        color: habit.color,
        icon: habit.icon,
        isActive: habit.isActive,
        communityId: habit.communityId,
        reminderTime: habit.reminderTime,
        reminderDays: habit.reminderDays,
      );

      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update habit: $e';
      debugPrint('Error updating habit: $e');
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _habitService.deleteHabit(id);
      _habits.removeWhere((habit) => habit.id == id);
      _completions.remove(id);
      _streaks.remove(id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete habit: $e';
      debugPrint('Error deleting habit: $e');
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];

    if (!_completions.containsKey(habitId)) {
      _completions[habitId] = {};
    }

    final existingCompletion = _completions[habitId]![dateStr];

    try {
      if (existingCompletion == null || !existingCompletion.isCompleted) {
        // Mark as completed
        final completionData = await _habitService.recordCompletion(
          habitId: habitId,
          date: date,
          isCompleted: true,
        );

        _completions[habitId]![dateStr] = HabitCompletion.fromServerJson(
          completionData,
        );
      } else {
        // Mark as not completed
        final completionData = await _habitService.recordCompletion(
          habitId: habitId,
          date: date,
          isCompleted: false,
        );

        _completions[habitId]![dateStr] = HabitCompletion.fromServerJson(
          completionData,
        );
      }

      // Recalculate streak
      _streaks[habitId] = _calculateStreak(habitId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update completion: $e';
      debugPrint('Error toggling completion: $e');
      notifyListeners();
    }
  }

  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _completions[habitId]?[dateStr]?.isCompleted ?? false;
  }

  // Alias for backward compatibility
  bool isHabitCompletedForDate(String habitId, DateTime date) {
    return isHabitCompletedOnDate(habitId, date);
  }

  int getStreakForHabit(String habitId) {
    return _streaks[habitId] ?? 0;
  }

  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    if (!_completions.containsKey(habitId)) {
      return [];
    }

    return _completions[habitId]!.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  int _calculateStreak(String habitId) {
    if (!_completions.containsKey(habitId)) return 0;

    final completions = _completions[habitId]!;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];

    // Check if completed today
    if (!completions.containsKey(todayStr) ||
        !completions[todayStr]!.isCompleted) {
      // If not completed today, check yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().split('T')[0];
      if (!completions.containsKey(yesterdayStr) ||
          !completions[yesterdayStr]!.isCompleted) {
        return 0;
      }
    }

    int streak = 0;
    DateTime checkDate = today;

    while (true) {
      final dateStr = checkDate.toIso8601String().split('T')[0];
      if (completions.containsKey(dateStr) &&
          completions[dateStr]!.isCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  double getTotalCompletionRate() {
    if (_habits.isEmpty || _completions.isEmpty) return 0;

    int totalPossible = 0;
    int totalCompleted = 0;

    for (final habit in _habits) {
      if (habit.id == null || !_completions.containsKey(habit.id!)) continue;

      final habitCompletions = _completions[habit.id!]!;
      totalPossible += habitCompletions.length;
      totalCompleted += habitCompletions.values
          .where((c) => c.isCompleted)
          .length;
    }

    return totalPossible > 0 ? totalCompleted / totalPossible : 0;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Additional methods for backward compatibility
  int getTotalStreak() {
    if (_habits.isEmpty) return 0;

    // Return the highest streak among all habits
    int maxStreak = 0;
    for (final habit in _habits) {
      if (habit.id != null) {
        final streak = getStreakForHabit(habit.id!);
        if (streak > maxStreak) {
          maxStreak = streak;
        }
      }
    }
    return maxStreak;
  }

  Map<String, double> getTodayProgress() {
    final today = DateTime.now();
    int totalHabits = _habits.length;
    int completedHabits = 0;

    for (final habit in _habits) {
      if (habit.id != null && habit.isActive) {
        if (isHabitCompletedOnDate(habit.id!, today)) {
          completedHabits++;
        }
      }
    }

    return {
      'completed': completedHabits.toDouble(),
      'total': totalHabits.toDouble(),
      'percentage': totalHabits > 0 ? completedHabits / totalHabits : 0.0,
    };
  }

  bool areAllHabitsCompletedToday() {
    if (_habits.isEmpty) return true;

    final today = DateTime.now();
    for (final habit in _habits) {
      if (habit.id != null && habit.isActive) {
        if (!isHabitCompletedOnDate(habit.id!, today)) {
          return false;
        }
      }
    }
    return true;
  }

  double getCompletionRateForHabit(String habitId, int days) {
    if (!_completions.containsKey(habitId)) return 0.0;

    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: days - 1));
    int completedDays = 0;

    for (int i = 0; i < days; i++) {
      final checkDate = startDate.add(Duration(days: i));
      if (isHabitCompletedOnDate(habitId, checkDate)) {
        completedDays++;
      }
    }

    return completedDays / days;
  }
}
