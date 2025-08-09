import '../../models/community_models.dart';

class CommunityCache {
  final Map<String, CachedData<List<CommunityHabit>>> _searchCache = {};
  CachedData<List<CommunityHabit>>? _popularCache;
  final Map<String, CachedData<CommunityDetails>> _detailsCache = {};
  CachedData<List<UserCommunity>>? _userCommunitiesCache;
  
  static const Duration _cacheExpiration = Duration(minutes: 5);
  static const Duration _searchCacheExpiration = Duration(minutes: 2);

  List<CommunityHabit>? getSearchResults(String key) {
    final cached = _searchCache[key];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }
    _searchCache.remove(key);
    return null;
  }

  void cacheSearchResults(String key, List<CommunityHabit> results) {
    _searchCache[key] = CachedData(
      data: results,
      timestamp: DateTime.now(),
      expiration: _searchCacheExpiration,
    );
    _cleanupOldSearchCache();
  }

  List<CommunityHabit>? getPopularCommunities() {
    if (_popularCache != null && !_popularCache!.isExpired) {
      return _popularCache!.data;
    }
    _popularCache = null;
    return null;
  }

  void cachePopularCommunities(List<CommunityHabit> communities) {
    _popularCache = CachedData(
      data: communities,
      timestamp: DateTime.now(),
      expiration: _cacheExpiration,
    );
  }

  CommunityDetails? getCommunityDetails(String communityId) {
    final cached = _detailsCache[communityId];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }
    _detailsCache.remove(communityId);
    return null;
  }

  void cacheCommunityDetails(String communityId, CommunityDetails details) {
    _detailsCache[communityId] = CachedData(
      data: details,
      timestamp: DateTime.now(),
      expiration: _cacheExpiration,
    );
  }

  List<UserCommunity>? getUserCommunities() {
    if (_userCommunitiesCache != null && !_userCommunitiesCache!.isExpired) {
      return _userCommunitiesCache!.data;
    }
    _userCommunitiesCache = null;
    return null;
  }

  void cacheUserCommunities(List<UserCommunity> communities) {
    _userCommunitiesCache = CachedData(
      data: communities,
      timestamp: DateTime.now(),
      expiration: _cacheExpiration,
    );
  }

  void invalidateCommunityDetails(String communityId) {
    _detailsCache.remove(communityId);
  }

  void invalidateUserCommunities() {
    _userCommunitiesCache = null;
  }

  void invalidatePopular() {
    _popularCache = null;
  }

  void invalidateSearch() {
    _searchCache.clear();
  }

  void invalidateAll() {
    _searchCache.clear();
    _popularCache = null;
    _detailsCache.clear();
    _userCommunitiesCache = null;
  }

  void _cleanupOldSearchCache() {
    if (_searchCache.length > 20) {
      final entries = _searchCache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));
      
      for (var i = 0; i < 10; i++) {
        _searchCache.remove(entries[i].key);
      }
    }
  }
}

class CachedData<T> {
  final T data;
  final DateTime timestamp;
  final Duration expiration;

  CachedData({
    required this.data,
    required this.timestamp,
    required this.expiration,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > expiration;
}