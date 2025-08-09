import 'package:flutter/foundation.dart';
import '../data/repositories/community_repository.dart';
import '../data/models/community_models.dart';
import '../data/models/habit.dart';
import 'habit_provider.dart';

class CommunityProvider extends ChangeNotifier {
  final ICommunityRepository _repository;
  
  CommunityState _state = CommunityState.initial();

  CommunityProvider({ICommunityRepository? repository})
      : _repository = repository ?? CommunityRepository();

  CommunityState get state => _state;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  
  List<CommunityHabit> get popularCommunities => _state.popularCommunities;
  List<CommunityHabit> get searchResults => _state.searchResults;
  List<UserCommunity> get userCommunities => _state.userCommunities;
  CommunityDetails? get currentCommunityDetails => _state.currentCommunityDetails;
  List<LeaderboardEntry> get currentLeaderboard => _state.currentLeaderboard;

  Future<void> loadPopularCommunities() async {
    await _execute(() async {
      final communities = await _repository.getPopularCommunities();
      _updateState((state) => state.copyWith(popularCommunities: communities));
    });
  }

  Future<void> searchCommunities({
    String? searchTerm,
    String? category,
    String? difficulty,
  }) async {
    await _execute(() async {
      final results = await _repository.searchCommunities(
        searchTerm: searchTerm,
        category: category,
        difficulty: difficulty,
      );
      _updateState((state) => state.copyWith(searchResults: results));
    });
  }

  Future<void> loadUserCommunities() async {
    await _execute(() async {
      final communities = await _repository.getUserCommunities();
      _updateState((state) => state.copyWith(userCommunities: communities));
    });
  }

  Future<void> loadCommunityDetails(String communityId) async {
    await _execute(() async {
      final details = await _repository.getCommunityDetails(communityId);
      _updateState((state) => state.copyWith(currentCommunityDetails: details));
    });
  }

  Future<void> loadLeaderboard(String communityId, {String timeframe = 'ALL_TIME'}) async {
    try {
      final leaderboard = await _repository.getCommunityLeaderboard(
        communityId,
        timeframe: timeframe,
      );
      _updateState((state) => state.copyWith(currentLeaderboard: leaderboard));
    } catch (e) {
      debugPrint('Failed to load leaderboard: $e');
    }
  }

  Future<bool> makeHabitPublic(
    Habit habit,
    CommunitySettings settings,
    HabitProvider habitProvider,
  ) async {
    if (habit.id == null) {
      _setError('Habit must be saved to server first');
      return false;
    }

    return await _executeWithResult(() async {
      final community = await _repository.makeHabitPublic(habit.id!, settings);
      
      final updatedHabit = habit.copyWith(
        communityId: community.id,
        communityName: community.name,
      );
      
      await habitProvider.updateHabit(updatedHabit);
      return true;
    });
  }

  Future<bool> joinCommunity(
    String communityId,
    HabitProvider habitProvider,
  ) async {
    return await _executeWithResult(() async {
      await _repository.joinCommunity(communityId);
      await habitProvider.loadHabits();
      await loadUserCommunities();
      return true;
    });
  }

  Future<bool> leaveCommunity(String communityId) async {
    return await _executeWithResult(() async {
      final success = await _repository.leaveCommunity(communityId);
      if (success) await loadUserCommunities();
      return success;
    });
  }

  void clearError() {
    _updateState((state) => state.copyWith(error: null));
  }

  void reset() {
    _state = CommunityState.initial();
    notifyListeners();
  }

  Future<void> _execute(Future<void> Function() operation) async {
    _setLoading(true);
    try {
      await operation();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _executeWithResult(Future<bool> Function() operation) async {
    _setLoading(true);
    try {
      return await operation();
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _updateState((state) => state.copyWith(isLoading: loading));
  }

  void _setError(String error) {
    _updateState((state) => state.copyWith(error: error));
  }

  void _updateState(CommunityState Function(CommunityState) updater) {
    _state = updater(_state);
    notifyListeners();
  }
}

class CommunityState {
  final bool isLoading;
  final String? error;
  final List<CommunityHabit> popularCommunities;
  final List<CommunityHabit> searchResults;
  final List<UserCommunity> userCommunities;
  final CommunityDetails? currentCommunityDetails;
  final List<LeaderboardEntry> currentLeaderboard;

  CommunityState({
    required this.isLoading,
    this.error,
    required this.popularCommunities,
    required this.searchResults,
    required this.userCommunities,
    this.currentCommunityDetails,
    required this.currentLeaderboard,
  });

  factory CommunityState.initial() {
    return CommunityState(
      isLoading: false,
      error: null,
      popularCommunities: [],
      searchResults: [],
      userCommunities: [],
      currentCommunityDetails: null,
      currentLeaderboard: [],
    );
  }

  CommunityState copyWith({
    bool? isLoading,
    String? error,
    List<CommunityHabit>? popularCommunities,
    List<CommunityHabit>? searchResults,
    List<UserCommunity>? userCommunities,
    CommunityDetails? currentCommunityDetails,
    List<LeaderboardEntry>? currentLeaderboard,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      popularCommunities: popularCommunities ?? this.popularCommunities,
      searchResults: searchResults ?? this.searchResults,
      userCommunities: userCommunities ?? this.userCommunities,
      currentCommunityDetails: currentCommunityDetails ?? this.currentCommunityDetails,
      currentLeaderboard: currentLeaderboard ?? this.currentLeaderboard,
    );
  }
}