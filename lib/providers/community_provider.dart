import 'package:flutter/foundation.dart';
import 'package:katomik/data/services/community_service.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/data/services/database_service.dart';
import 'package:katomik/providers/habit_provider.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  final DatabaseService _databaseService = DatabaseService();
  
  // State
  List<CommunityHabit> _popularCommunities = [];
  List<CommunityHabit> _searchResults = [];
  List<UserCommunity> _userCommunities = [];
  CommunityDetails? _currentCommunityDetails;
  List<LeaderboardEntry> _currentLeaderboard = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CommunityHabit> get popularCommunities => _popularCommunities;
  List<CommunityHabit> get searchResults => _searchResults;
  List<UserCommunity> get userCommunities => _userCommunities;
  CommunityDetails? get currentCommunityDetails => _currentCommunityDetails;
  List<LeaderboardEntry> get currentLeaderboard => _currentLeaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Popular Communities
  Future<void> loadPopularCommunities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _popularCommunities = await _communityService.getPopularCommunities();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search Communities
  Future<void> searchCommunities({
    String? searchTerm,
    String? category,
    String? difficulty,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _communityService.searchCommunities(
        searchTerm: searchTerm,
        category: category,
        difficulty: difficulty,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // User Communities
  Future<void> loadUserCommunities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userCommunities = await _communityService.getUserCommunities();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Community Details
  Future<void> loadCommunityDetails(String communityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCommunityDetails = await _communityService.getCommunityDetails(communityId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Leaderboard
  Future<void> loadLeaderboard(String communityId, {String timeframe = 'all'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLeaderboard = await _communityService.getCommunityLeaderboard(
        communityId,
        timeframe: timeframe,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Make Habit Public
  Future<bool> makeHabitPublic(
    Habit habit,
    CommunitySettings settings,
    HabitProvider habitProvider,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Ensure habit has a server ID
      if (habit.id == null) {
        _error = 'Habit must be saved to server first';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final community = await _communityService.makeHabitPublic(
        habit.id!,
        settings,
      );

      // Update local habit to reflect it's now a community habit
      final updatedHabit = habit.copyWith(
        isCommunityHabit: true,
        communityId: community.id,
        communityName: community.name,
      );
      
      await _databaseService.updateHabit(updatedHabit);
      await habitProvider.loadHabits();
      
      return true;
    } catch (e) {
      _error = e.toString();
      // Log detailed error for debugging
      debugPrint('Error making habit public: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join Community
  Future<bool> joinCommunity(
    String communityId,
    HabitProvider habitProvider,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _communityService.joinCommunity(communityId);

      // Reload habits to include the new community habit
      await habitProvider.loadHabits();
      
      // Reload user communities
      await loadUserCommunities();
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Leave Community
  Future<bool> leaveCommunity(String communityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _communityService.leaveCommunity(communityId);
      
      // Reload user communities
      await loadUserCommunities();
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Retire from Community
  Future<bool> retireFromCommunity(
    String communityId,
    String habitId,
    HabitProvider habitProvider,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _communityService.retireFromCommunity(communityId);
      
      // Delete the habit from server
      await habitProvider.deleteHabit(habitId);
      
      // Reload user communities
      await loadUserCommunities();
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Propose Change
  Future<bool> proposeChange(String communityId, ProposalInput proposal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _communityService.proposeChange(communityId, proposal);
      
      // Reload community details to get updated proposals
      await loadCommunityDetails(communityId);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vote on Proposal
  Future<bool> voteOnProposal(String proposalId, bool vote) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _communityService.voteOnProposal(proposalId, vote);
      
      // Reload community details if we have one
      if (_currentCommunityDetails != null) {
        await loadCommunityDetails(_currentCommunityDetails!.id);
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _popularCommunities = [];
    _searchResults = [];
    _userCommunities = [];
    _currentCommunityDetails = null;
    _currentLeaderboard = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}