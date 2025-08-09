import '../services/community_service_refactored.dart';
import 'cache/community_cache.dart';

abstract class ICommunityRepository {
  Future<List<CommunityHabit>> searchCommunities({
    String? searchTerm,
    String? category,
    String? difficulty,
    int limit = 20,
    int offset = 0,
  });

  Future<List<CommunityHabit>> getPopularCommunities({int limit = 10});
  Future<CommunityDetails> getCommunityDetails(String communityId);
  Future<List<LeaderboardEntry>> getCommunityLeaderboard(
    String communityId, {
    String timeframe,
  });
  Future<List<UserCommunity>> getUserCommunities();
  Future<CommunityHabit> makeHabitPublic(
    String habitId,
    CommunitySettings settings,
  );
  Future<CommunityMembership> joinCommunity(String communityId);
  Future<bool> leaveCommunity(String communityId);
  Future<bool> retireFromCommunity(String communityId);
  Future<Proposal> proposeChange(String communityId, ProposalInput proposal);
  Future<Proposal> voteOnProposal(String proposalId, bool vote);
}

class CommunityRepository implements ICommunityRepository {
  final CommunityService _service;
  final CommunityCache _cache;

  CommunityRepository({CommunityService? service, CommunityCache? cache})
    : _service = service ?? CommunityService(),
      _cache = cache ?? CommunityCache();

  @override
  Future<List<CommunityHabit>> searchCommunities({
    String? searchTerm,
    String? category,
    String? difficulty,
    int limit = 20,
    int offset = 0,
  }) async {
    final cacheKey = _buildSearchCacheKey(
      searchTerm,
      category,
      difficulty,
      limit,
      offset,
    );

    final cached = _cache.getSearchResults(cacheKey);
    if (cached != null) return cached;

    final results = await _service.searchCommunities(
      searchTerm: searchTerm,
      category: category,
      difficulty: difficulty,
      limit: limit,
      offset: offset,
    );

    _cache.cacheSearchResults(cacheKey, results);
    return results;
  }

  @override
  Future<List<CommunityHabit>> getPopularCommunities({int limit = 10}) async {
    final cached = _cache.getPopularCommunities();
    if (cached != null) return cached;

    final results = await _service.getPopularCommunities(limit: limit);
    _cache.cachePopularCommunities(results);
    return results;
  }

  @override
  Future<CommunityDetails> getCommunityDetails(String communityId) async {
    final cached = _cache.getCommunityDetails(communityId);
    if (cached != null) return cached;

    final details = await _service.getCommunityDetails(communityId);
    _cache.cacheCommunityDetails(communityId, details);
    return details;
  }

  @override
  Future<List<LeaderboardEntry>> getCommunityLeaderboard(
    String communityId, {
    String timeframe = 'ALL_TIME',
  }) async {
    return _service.getCommunityLeaderboard(communityId, timeframe: timeframe);
  }

  @override
  Future<List<UserCommunity>> getUserCommunities() async {
    final results = await _service.getUserCommunities();
    _cache.cacheUserCommunities(results);
    return results;
  }

  @override
  Future<CommunityHabit> makeHabitPublic(
    String habitId,
    CommunitySettings settings,
  ) async {
    final result = await _service.makeHabitPublic(habitId, settings);
    _cache.invalidateAll();
    return result;
  }

  @override
  Future<CommunityMembership> joinCommunity(String communityId) async {
    final result = await _service.joinCommunity(communityId);
    _cache.invalidateUserCommunities();
    _cache.invalidateCommunityDetails(communityId);
    return result;
  }

  @override
  Future<bool> leaveCommunity(String communityId) async {
    final result = await _service.leaveCommunity(communityId);
    if (result) {
      _cache.invalidateUserCommunities();
      _cache.invalidateCommunityDetails(communityId);
    }
    return result;
  }

  @override
  Future<bool> retireFromCommunity(String communityId) async {
    final result = await _service.retireFromCommunity(communityId);
    if (result) {
      _cache.invalidateUserCommunities();
      _cache.invalidateCommunityDetails(communityId);
    }
    return result;
  }

  @override
  Future<Proposal> proposeChange(
    String communityId,
    ProposalInput proposal,
  ) async {
    final result = await _service.proposeChange(communityId, proposal);
    _cache.invalidateCommunityDetails(communityId);
    return result;
  }

  @override
  Future<Proposal> voteOnProposal(String proposalId, bool vote) async {
    return _service.voteOnProposal(proposalId, vote);
  }

  String _buildSearchCacheKey(
    String? searchTerm,
    String? category,
    String? difficulty,
    int limit,
    int offset,
  ) {
    return 'search_${searchTerm ?? ''}_${category ?? ''}_${difficulty ?? ''}_${limit}_$offset';
  }
}
