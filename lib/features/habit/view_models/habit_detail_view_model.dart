import 'package:flutter/material.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/community_models.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/community_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/color_utils.dart';

class HabitDetailViewModel extends ChangeNotifier {
  final HabitProvider _habitProvider;
  final CommunityProvider _communityProvider;
  
  Habit _habit;
  DateTime _focusedMonth = DateTime.now();
  bool _isLoading = false;
  String? _error;
  
  final List<Map<String, dynamic>> communityPhrases = [
    {'name': 'Brandon Anderson', 'avatar': '🎮', 'streak': 3},
    {'name': 'Jane Martinez', 'avatar': '👩‍🦰', 'streak': 4},
    {'name': 'Sebas Alzate', 'avatar': '👨‍💼', 'streak': 2},
  ];
  
  HabitDetailViewModel({
    required HabitProvider habitProvider,
    required CommunityProvider communityProvider,
    required Habit habit,
  }) : _habitProvider = habitProvider,
       _communityProvider = communityProvider,
       _habit = habit {
    _loadCompletions();
  }
  
  Habit get habit => _habit;
  DateTime get focusedMonth => _focusedMonth;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canMakePublic => _habit.communityId == null;
  Color get habitColor => ColorUtils.parseColor(_habit.color);
  
  List<DateTime> get weeklyDates => HomeDateUtils.getLastNDays(5);
  
  Future<void> _loadCompletions() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _habitProvider.getCompletionsForHabit(_habit.id!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load completions';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> refreshHabit() async {
    try {
      final updatedHabit = _habitProvider.habits.firstWhere(
        (h) => h.id == _habit.id,
      );
      _habit = updatedHabit;
      await _loadCompletions();
    } catch (e) {
      _error = 'Failed to refresh habit';
      notifyListeners();
    }
  }
  
  void navigateToPreviousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }
  
  void navigateToNextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }
  
  bool isDateCompleted(DateTime date) {
    return _habitProvider.isHabitCompletedOnDate(_habit.id!, date);
  }
  
  Future<void> toggleDateCompletion(DateTime date) async {
    if (date.isAfter(DateTime.now())) return;
    
    await _habitProvider.toggleHabitCompletion(_habit.id!, date);
    notifyListeners();
  }
  
  Future<MakePublicResult> makeHabitPublic(CommunitySettings settings) async {
    try {
      final success = await _communityProvider.makeHabitPublic(
        _habit,
        settings,
        _habitProvider,
      );
      
      if (success) {
        await refreshHabit();
        return MakePublicResult(
          success: true,
          communityId: _habit.communityId,
          communityName: _habit.communityName ?? _habit.name,
        );
      }
      
      final errorMessage = _communityProvider.error ?? 'Failed to make habit public';
      
      if (errorMessage.contains('already shared with the community')) {
        await refreshHabit();
      }
      
      return MakePublicResult(
        success: false,
        error: errorMessage,
      );
    } catch (e) {
      return MakePublicResult(
        success: false,
        error: 'An error occurred: $e',
      );
    }
  }
  
  String getMonthName(DateTime date) {
    const months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
    ];
    return months[date.month - 1];
  }
  
  CalendarData getCalendarData() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7;
    
    return CalendarData(
      firstDay: firstDay,
      lastDay: lastDay,
      daysInMonth: daysInMonth,
      firstWeekday: firstWeekday,
    );
  }
  
  List<String> get weekDayLabels => ['d', 'l', 'm', 'm', 'j', 'v', 's'];
}

class MakePublicResult {
  final bool success;
  final String? communityId;
  final String? communityName;
  final String? error;
  
  MakePublicResult({
    required this.success,
    this.communityId,
    this.communityName,
    this.error,
  });
}

class CalendarData {
  final DateTime firstDay;
  final DateTime lastDay;
  final int daysInMonth;
  final int firstWeekday;
  
  CalendarData({
    required this.firstDay,
    required this.lastDay,
    required this.daysInMonth,
    required this.firstWeekday,
  });
}