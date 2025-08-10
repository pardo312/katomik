import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers/community_provider.dart';
import '../../../../shared/providers/habit_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../data/services/community_service.dart';
import '../../../../core/constants/community_constants.dart';

class CommunityDetailViewModel extends ChangeNotifier {
  final CommunityProvider _communityProvider;
  final HabitProvider _habitProvider;
  final AuthProvider _authProvider;
  final String communityId;
  final String communityName;

  bool _isInitialized = false;
  String _selectedTimeframe = CommunityTimeframe.allTime;
  int _selectedTabIndex = 0;

  CommunityDetailViewModel({
    required CommunityProvider communityProvider,
    required HabitProvider habitProvider,
    required AuthProvider authProvider,
    required this.communityId,
    required this.communityName,
  }) : _communityProvider = communityProvider,
       _habitProvider = habitProvider,
       _authProvider = authProvider;

  bool get isInitialized => _isInitialized;
  String get selectedTimeframe => _selectedTimeframe;
  int get selectedTabIndex => _selectedTabIndex;

  CommunityDetails? get community => _communityProvider.currentCommunityDetails;
  List<LeaderboardEntry> get leaderboard =>
      _communityProvider.currentLeaderboard;
  bool get isLoading => _communityProvider.isLoading;
  String? get error => _communityProvider.error;

  bool get isMember {
    return _habitProvider.habits.any(
      (habit) => habit.communityId == communityId,
    );
  }

  String? get currentUserId => _authProvider.user?.id;

  LeaderboardEntry? get currentUserEntry {
    if (currentUserId == null) return null;

    try {
      return leaderboard.firstWhere(
        (entry) => entry.member.user.id == currentUserId,
      );
    } catch (_) {
      return null;
    }
  }

  int get userRank {
    if (currentUserId == null || currentUserEntry == null) return 0;

    final index = leaderboard.indexWhere(
      (entry) => entry.member.user.id == currentUserId,
    );

    return index != -1 ? index + 1 : 0;
  }

  int get userStreak => currentUserEntry?.member.currentStreak ?? 0;

  Future<void> initialize() async {
    try {
      await loadCommunityDetails();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadCommunityDetails() async {
    try {
      await _communityProvider.loadCommunityDetails(communityId);
      await _communityProvider.loadLeaderboard(communityId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTimeframe(String timeframe) async {
    if (timeframe.isEmpty) return;
    if (_selectedTimeframe == timeframe) return;

    try {
      _selectedTimeframe = timeframe;
      notifyListeners();
      await _communityProvider.loadLeaderboard(communityId, timeframe: timeframe);
    } catch (e) {
      _selectedTimeframe = CommunityTimeframe.allTime;
      notifyListeners();
      rethrow;
    }
  }

  void updateTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<bool> joinCommunity() async {
    try {
      final success = await _communityProvider.joinCommunity(
        communityId,
        _habitProvider,
      );

      if (success) {
        await loadCommunityDetails();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> leaveCommunity() async {
    try {
      final success = await _communityProvider.leaveCommunity(communityId);

      if (success) {
        await loadCommunityDetails();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}
