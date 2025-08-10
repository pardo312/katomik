import '../../../shared/models/community_models.dart';
import 'queries.dart';
import 'base_service.dart';
import 'error_handler.dart';

class CommunityDetailsService extends BaseCommunityService {
  Future<CommunityDetails> getDetails(String communityId) async {
    _validateCommunityId(communityId);
    
    return executeQuery(
      queryDocument: CommunityQueries.communityDetails,
      variables: {'communityId': communityId},
      dataExtractor: (data) {
        final details = data['communityDetails'];
        if (details == null) {
          throw CommunityServiceException(
            'Community not found',
            type: CommunityErrorType.notFound,
          );
        }
        return CommunityDetails.fromJson(details);
      },
      operationName: 'getCommunityDetails',
      useCache: false,
    );
  }

  Future<List<LeaderboardEntry>> getLeaderboard(
    String communityId, {
    String timeframe = 'ALL_TIME',
  }) async {
    _validateCommunityId(communityId);
    _validateTimeframe(timeframe);
    
    return executeQuery(
      queryDocument: CommunityQueries.communityLeaderboard,
      variables: {
        'communityId': communityId,
        'timeframe': timeframe,
      },
      dataExtractor: (data) => (data['communityLeaderboard'] as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
      operationName: 'getCommunityLeaderboard',
    );
  }

  Future<List<UserCommunity>> getUserCommunities() async {
    return executeQuery(
      queryDocument: CommunityQueries.userCommunities,
      variables: {},
      dataExtractor: (data) => (data['userCommunities'] as List)
          .map((c) => UserCommunity.fromJson(c))
          .toList(),
      operationName: 'getUserCommunities',
      useCache: false,
    );
  }

  void _validateCommunityId(String communityId) {
    if (communityId.isEmpty) {
      throw ArgumentError('Community ID cannot be empty');
    }
  }

  void _validateTimeframe(String timeframe) {
    const validTimeframes = ['DAILY', 'WEEKLY', 'MONTHLY', 'ALL_TIME'];
    if (!validTimeframes.contains(timeframe)) {
      throw ArgumentError('Invalid timeframe: $timeframe');
    }
  }
}