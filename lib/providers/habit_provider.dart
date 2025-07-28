import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../services/database_service.dart';

class HabitProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Habit> _habits = [];
  final Map<int, Map<String, HabitCompletion>> _completions = {};
  final Map<int, int> _streaks = {};
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  HabitProvider() {
    loadHabits();
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _databaseService.getAllHabits();
      
      // Load today's completions for all habits
      final today = DateTime.now();
      await loadCompletionsForDate(today);
      
      // Load past week's completions
      for (int i = 1; i <= 4; i++) {
        await loadCompletionsForDate(today.subtract(Duration(days: i)));
      }
      
      // Load streaks for all habits
      for (final habit in _habits) {
        if (habit.id != null) {
          _streaks[habit.id!] = await _databaseService.getStreakForHabit(habit.id!);
        }
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCompletionsForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final completions = await _databaseService.getCompletionsForDate(date);
    
    for (final completion in completions) {
      if (!_completions.containsKey(completion.habitId)) {
        _completions[completion.habitId] = {};
      }
      _completions[completion.habitId]![dateStr] = completion;
    }
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final id = await _databaseService.insertHabit(habit);
      final newHabit = habit.copyWith(id: id);
      _habits.insert(0, newHabit);
      _streaks[id] = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _databaseService.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await _databaseService.deactivateHabit(id);
      _habits.removeWhere((habit) => habit.id == id);
      _completions.remove(id);
      _streaks.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }

  Future<void> toggleHabitCompletion(int habitId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final existingCompletion = await _databaseService.getCompletionForHabitAndDate(habitId, date);
      
      final completion = HabitCompletion(
        id: existingCompletion?.id,
        habitId: habitId,
        date: date,
        isCompleted: existingCompletion?.isCompleted == true ? false : true,
      );
      
      await _databaseService.insertOrUpdateCompletion(completion);
      
      if (!_completions.containsKey(habitId)) {
        _completions[habitId] = {};
      }
      _completions[habitId]![dateStr] = completion;
      
      // Update streak
      _streaks[habitId] = await _databaseService.getStreakForHabit(habitId);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling habit completion: $e');
    }
  }

  bool isHabitCompletedForDate(int habitId, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _completions[habitId]?[dateStr]?.isCompleted ?? false;
  }

  int getStreakForHabit(int habitId) {
    return _streaks[habitId] ?? 0;
  }

  int getTotalStreak() {
    if (_habits.isEmpty) return 0;
    
    int totalStreak = 0;
    for (final habit in _habits) {
      if (habit.id != null) {
        final streak = _streaks[habit.id!] ?? 0;
        if (totalStreak == 0 || streak < totalStreak) {
          totalStreak = streak;
        }
      }
    }
    return totalStreak;
  }

  double getTodayProgress() {
    if (_habits.isEmpty) return 0.0;
    
    final today = DateTime.now();
    int completedCount = 0;
    
    for (final habit in _habits) {
      if (habit.id != null && isHabitCompletedForDate(habit.id!, today)) {
        completedCount++;
      }
    }
    
    return completedCount / _habits.length;
  }

  bool areAllHabitsCompletedToday() {
    if (_habits.isEmpty) return false;
    
    final today = DateTime.now();
    for (final habit in _habits) {
      if (habit.id != null && !isHabitCompletedForDate(habit.id!, today)) {
        return false;
      }
    }
    
    return true;
  }

  Map<DateTime, double> getWeekProgress() {
    final Map<DateTime, double> weekProgress = {};
    final today = DateTime.now();
    
    for (int i = 4; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      int completedCount = 0;
      
      for (final habit in _habits) {
        if (habit.id != null && isHabitCompletedForDate(habit.id!, date)) {
          completedCount++;
        }
      }
      
      weekProgress[date] = _habits.isEmpty ? 0.0 : completedCount / _habits.length;
    }
    
    return weekProgress;
  }

  Future<Map<String, double>> getCompletionRateForHabit(int habitId, int days) async {
    try {
      return await _databaseService.getCompletionRateForHabit(habitId, days);
    } catch (e) {
      debugPrint('Error getting completion rate: $e');
      return {
        'completedDays': 0.0,
        'totalDays': days.toDouble(),
        'completionRate': 0.0,
      };
    }
  }

  Future<List<HabitCompletion>> getCompletionsForHabit(int habitId) async {
    try {
      return await _databaseService.getCompletionsForHabit(habitId);
    } catch (e) {
      debugPrint('Error getting completions: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }
}