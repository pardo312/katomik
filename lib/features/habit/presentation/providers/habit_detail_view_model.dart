import 'package:flutter/material.dart';
import '../../../../shared/models/habit.dart';
import '../../../../shared/models/community_models.dart';
import '../../../../shared/providers/habit_provider.dart';
import '../../../../shared/providers/community_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../l10n/app_localizations.dart';

class HabitDetailViewModel extends ChangeNotifier {
  final HabitProvider _habitProvider;
  final CommunityProvider _communityProvider;
  
  Habit _habit;
  DateTime _focusedMonth = DateTime.now();
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _communityPhrases = [];
  
  HabitDetailViewModel({
    required HabitProvider habitProvider,
    required CommunityProvider communityProvider,
    required Habit habit,
  }) : _habitProvider = habitProvider,
       _communityProvider = communityProvider,
       _habit = habit {
    _initialize();
  }
  
  Habit get habit => _habit;
  DateTime get focusedMonth => _focusedMonth;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canMakePublic => _habit.communityId == null;
  Color get habitColor => ColorUtils.parseColor(_habit.color);
  List<Map<String, dynamic>> get communityPhrases => _communityPhrases;
  
  List<DateTime> get weeklyDates => HomeDateUtils.getLastNDays(5);
  
  Future<void> _initialize() async {
    await _loadCompletions();
    await _loadCommunityPhrases();
  }
  
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
  
  Future<void> _loadCommunityPhrases() async {
    if (_habit.communityId == null) return;
    
    try {
      _communityPhrases = await _fetchCommunityPhrases();
      notifyListeners();
    } catch (e) {
      _communityPhrases = [];
    }
  }
  
  Future<List<Map<String, dynamic>>> _fetchCommunityPhrases() async {
    return [];
  }
  
  Future<void> refreshHabit() async {
    try {
      final updatedHabit = _habitProvider.habits.firstWhere(
        (h) => h.id == _habit.id,
      );
      _habit = updatedHabit;
      await _initialize();
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
  
  String getMonthName(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final months = [
      l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
      l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december,
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
  
  List<String> getWeekDayLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.sundayShort, l10n.mondayShort, l10n.tuesdayShort, l10n.wednesdayShort,
      l10n.thursdayShort, l10n.fridayShort, l10n.saturdayShort
    ];
  }
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