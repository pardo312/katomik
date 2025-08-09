import 'package:flutter/foundation.dart';
import '../../../providers/community_provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/services/community_service.dart';

class CommunityDetailViewModel extends ChangeNotifier {
  final CommunityProvider _communityProvider;
  final HabitProvider _habitProvider;
  final AuthProvider _authProvider;
  final String communityId;
  final String communityName;

  bool _isInitialized = false;
  String _selectedTimeframe = 'ALL_TIME';
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
    await loadCommunityDetails();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> loadCommunityDetails() async {
    await _communityProvider.loadCommunityDetails(communityId);
    await _communityProvider.loadLeaderboard(communityId);
  }

  Future<void> updateTimeframe(String timeframe) async {
    if (_selectedTimeframe == timeframe) return;

    _selectedTimeframe = timeframe;
    notifyListeners();
    await _communityProvider.loadLeaderboard(communityId, timeframe: timeframe);
  }

  void updateTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<bool> joinCommunity() async {
    final success = await _communityProvider.joinCommunity(
      communityId,
      _habitProvider,
    );

    if (success) {
      await loadCommunityDetails();
    }

    return success;
  }

  Future<bool> leaveCommunity() async {
    final success = await _communityProvider.leaveCommunity(communityId);

    if (success) {
      await loadCommunityDetails();
    }

    return success;
  }

  String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
