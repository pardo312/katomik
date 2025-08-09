import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:katomik/data/services/community_service.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/providers/habit_provider.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  
  List<CommunityHabit> _popularCommunities = [];
  List<CommunityHabit> _searchResults = [];
  List<UserCommunity> _userCommunities = [];
  CommunityDetails? _currentCommunityDetails;
  List<LeaderboardEntry> _currentLeaderboard = [];
  bool _isLoading = false;
  String? _error;

  List<CommunityHabit> get popularCommunities => _popularCommunities;
  List<CommunityHabit> get searchResults => _searchResults;
  List<UserCommunity> get userCommunities => _userCommunities;
  CommunityDetails? get currentCommunityDetails => _currentCommunityDetails;
  List<LeaderboardEntry> get currentLeaderboard => _currentLeaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearData() {
    _popularCommunities = [];
    _searchResults = [];
    _userCommunities = [];
    _currentCommunityDetails = null;
    _currentLeaderboard = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> loadPopularCommunities() async {
    await _executeAsync(() async {
      _popularCommunities = await _communityService.getPopularCommunities();
    });
  }

  Future<void> searchCommunities({
    String? searchTerm,
    String? category,
    String? difficulty,
  }) async {
    await _executeAsync(() async {
      _searchResults = await _communityService.searchCommunities(
        searchTerm: searchTerm,
        category: category,
        difficulty: difficulty,
      );
    });
  }

  Future<void> loadUserCommunities() async {
    await _executeAsync(() async {
      _userCommunities = await _communityService.getUserCommunities();
    });
  }

  Future<void> loadCommunityDetails(String communityId) async {
    await _executeAsync(() async {
      _currentCommunityDetails = await _communityService.getCommunityDetails(communityId);
    });
  }

  Future<void> loadLeaderboard(String communityId, {String timeframe = 'ALL_TIME'}) async {
    try {
      _currentLeaderboard = await _communityService.getCommunityLeaderboard(
        communityId,
        timeframe: timeframe,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load leaderboard: $e');
      _currentLeaderboard = [];
      notifyListeners();
    }
  }

  Future<bool> makeHabitPublic(
    Habit habit,
    CommunitySettings settings,
    HabitProvider habitProvider,
  ) async {
    return await _executeWithResult(() async {
      _validateHabitForPublishing(habit);
      
      final community = await _communityService.makeHabitPublic(
        habit.id!,
        settings,
      );

      await _updateHabitWithCommunity(habit, community, habitProvider);
      return true;
    });
  }

  Future<bool> joinCommunity(
    String communityId,
    HabitProvider habitProvider,
  ) async {
    return await _executeWithResult(() async {
      await _communityService.joinCommunity(communityId);
      await habitProvider.loadHabits();
      await loadUserCommunities();
      return true;
    });
  }

  Future<bool> leaveCommunity(String communityId) async {
    return await _executeWithResult(() async {
      await _communityService.leaveCommunity(communityId);
      await loadUserCommunities();
      return true;
    });
  }

  Future<bool> retireFromCommunity(
    String communityId,
    String habitId,
    HabitProvider habitProvider,
  ) async {
    return await _executeWithResult(() async {
      await _communityService.retireFromCommunity(communityId);
      await habitProvider.deleteHabit(habitId);
      await loadUserCommunities();
      return true;
    });
  }

  Future<bool> proposeChange(String communityId, ProposalInput proposal) async {
    return await _executeWithResult(() async {
      await _communityService.proposeChange(communityId, proposal);
      await loadCommunityDetails(communityId);
      return true;
    });
  }

  Future<bool> voteOnProposal(String proposalId, bool vote) async {
    return await _executeWithResult(() async {
      await _communityService.voteOnProposal(proposalId, vote);
      
      if (_currentCommunityDetails != null) {
        await loadCommunityDetails(_currentCommunityDetails!.id);
      }
      
      return true;
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    clearData();
  }

  Future<void> _executeAsync(Future<void> Function() operation) async {
    _setLoadingState(true);
    _clearError();

    try {
      await operation();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  Future<bool> _executeWithResult(Future<bool> Function() operation) async {
    _setLoadingState(true);
    _clearError();

    try {
      return await operation();
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  void _setLoadingState(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    _error = null;
  }

  void _handleError(dynamic error) {
    _error = _formatErrorMessage(error);
    debugPrint('Community operation error: $error');
  }

  String _formatErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('already public')) {
      return 'This habit is already shared with the community';
    } else if (errorString.contains('BadRequestException')) {
      final match = RegExp(r'BadRequestException: (.+)').firstMatch(errorString);
      return match?.group(1) ?? 'Invalid request';
    } else if (errorString.contains('NetworkException')) {
      return 'Network error. Please check your connection and try again.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  void _validateHabitForPublishing(Habit habit) {
    if (habit.id == null) {
      throw Exception('Habit must be saved to server first');
    }
  }

  Future<void> _updateHabitWithCommunity(
    Habit habit,
    CommunityHabit community,
    HabitProvider habitProvider,
  ) async {
    final updatedHabit = habit.copyWith(
      communityId: community.id,
      communityName: community.name,
    );
    
    await habitProvider.updateHabit(updatedHabit);
  }
}