import '../../../shared/models/community_models.dart';
import 'queries.dart';
import 'base_service.dart';

class CommunitySearchService extends BaseCommunityService {
  Future<List<CommunityHabit>> search({
    String? searchTerm,
    String? category,
    String? difficulty,
    int limit = 20,
    int offset = 0,
  }) async {
    validatePagination(limit, offset);

    return executeQuery(
      queryDocument: CommunityQueries.searchCommunities,
      variables: {
        'searchTerm': searchTerm,
        'category': category,
        'difficulty': difficulty,
        'limit': limit,
        'offset': offset,
      },
      dataExtractor: (data) => (data['searchCommunityHabits'] as List)
          .map((c) => CommunityHabit.fromJson(c))
          .toList(),
      operationName: 'searchCommunities',
    );
  }

  Future<List<CommunityHabit>> getPopular({int limit = 10}) async {
    validateLimit(limit);

    return executeQuery(
      queryDocument: CommunityQueries.popularCommunities,
      variables: {'limit': limit},
      dataExtractor: (data) => (data['popularCommunities'] as List)
          .map((c) => CommunityHabit.fromJson(c))
          .toList(),
      operationName: 'getPopularCommunities',
      useCache: false,
    );
  }

  void validatePagination(int limit, int offset) {
    if (limit < 1 || limit > 100) {
      throw ArgumentError('Limit must be between 1 and 100');
    }
    if (offset < 0) {
      throw ArgumentError('Offset must be non-negative');
    }
  }

  void validateLimit(int limit) {
    if (limit < 1 || limit > 100) {
      throw ArgumentError('Limit must be between 1 and 100');
    }
  }
}
