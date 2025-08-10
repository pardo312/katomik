import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:katomik/data/services/graphql_client.dart';
import 'package:katomik/core/logging/logger_service.dart';
import 'package:katomik/core/network/retry_service.dart';
import 'package:katomik/shared/models/community_models.dart';
import 'package:katomik/data/services/community/queries.dart';
import 'package:katomik/data/services/community/mutations.dart';
import 'package:katomik/data/services/community/error_handler.dart';
export 'package:katomik/shared/models/community_models.dart';
export 'package:katomik/data/services/community/error_handler.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  
  final _logger = LoggerService();
  final _retryService = RetryService();
  final _errorHandler = CommunityErrorHandler();
  
  CommunityService._internal() {
    _logger.setContext('CommunityService');
  }


  // Service Methods
  Future<List<CommunityHabit>> searchCommunities({
    String? searchTerm,
    String? category,
    String? difficulty,
    int limit = 20,
    int offset = 0,
  }) async {
    final startTime = DateTime.now();
    _logger.info('Searching communities', data: {
      'searchTerm': searchTerm,
      'category': category,
      'difficulty': difficulty,
      'limit': limit,
      'offset': offset,
    });

    try {
      // Validate inputs
      if (limit < 1 || limit > 100) {
        throw ArgumentError('Limit must be between 1 and 100');
      }
      if (offset < 0) {
        throw ArgumentError('Offset must be non-negative');
      }

      final client = await GraphQLConfig.getClient();
      
      final result = await _retryService.executeWithTimeout(
        () => client.query(
          QueryOptions(
            document: gql(CommunityQueries.searchCommunities),
            variables: {
              'searchTerm': searchTerm,
              'category': category,
              'difficulty': difficulty,
              'limit': limit,
              'offset': offset,
            },
          ),
        ),
        operationName: 'searchCommunities',
        timeout: const Duration(seconds: 10),
        options: RetryOptions(
          maxAttempts: 3,
          shouldRetry: (error) => _errorHandler.isRetryableError(error),
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in searchCommunities',
          error: result.exception,
          data: {'query': 'searchCommunitiesQuery'},
        );
        _errorHandler.handleGraphQLException(result.exception!);
      }

      final List<dynamic> communities = result.data?['searchCommunityHabits'] ?? [];
      final results = communities.map((c) => CommunityHabit.fromJson(c)).toList();
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logPerformance('searchCommunities', duration, data: {
        'resultCount': results.length,
        'hasSearchTerm': searchTerm != null,
      });
      
      return results;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to search communities',
        error: e,
        stackTrace: stackTrace,
      );
      throw _errorHandler.mapException(e);
    }
  }

  Future<List<CommunityHabit>> getPopularCommunities({int limit = 10}) async {
    final startTime = DateTime.now();
    _logger.info('Fetching popular communities', data: {'limit': limit});

    try {
      // Validate input
      if (limit < 1 || limit > 100) {
        throw ArgumentError('Limit must be between 1 and 100');
      }

      final client = await GraphQLConfig.getClient();
      
      final result = await client.query(
        QueryOptions(
          document: gql(CommunityQueries.popularCommunities),
          variables: {'limit': limit},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in getPopularCommunities',
          error: result.exception,
          data: {'query': 'popularCommunitiesQuery'},
        );
        _errorHandler.handleGraphQLException(result.exception!);
      }

      final List<dynamic> communities = result.data?['popularCommunities'] ?? [];
      final results = communities.map((c) => CommunityHabit.fromJson(c)).toList();
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logPerformance('getPopularCommunities', duration, data: {
        'resultCount': results.length,
      });
      
      return results;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch popular communities',
        error: e,
        stackTrace: stackTrace,
      );
      throw _errorHandler.mapException(e);
    }
  }

  Future<CommunityDetails> getCommunityDetails(String communityId) async {
    final startTime = DateTime.now();
    _logger.info('Fetching community details', data: {'communityId': communityId});

    try {
      // Validate input
      if (communityId.isEmpty) {
        throw ArgumentError('Community ID cannot be empty');
      }

      final client = await GraphQLConfig.getClient();
      
      final result = await client.query(
        QueryOptions(
          document: gql(CommunityQueries.communityDetails),
          variables: {'communityId': communityId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in getCommunityDetails',
          error: result.exception,
          data: {'communityId': communityId},
        );
        _errorHandler.handleGraphQLException(result.exception!);
      }

      if (result.data?['communityDetails'] == null) {
        throw CommunityServiceException(
          'Community not found',
          type: CommunityErrorType.notFound,
        );
      }

      final details = CommunityDetails.fromJson(result.data!['communityDetails']);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logPerformance('getCommunityDetails', duration, data: {
        'communityId': communityId,
        'memberCount': details.memberCount,
      });
      
      return details;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch community details',
        error: e,
        stackTrace: stackTrace,
        data: {'communityId': communityId},
      );
      throw _errorHandler.mapException(e);
    }
  }

  Future<List<LeaderboardEntry>> getCommunityLeaderboard(
    String communityId, {
    String timeframe = 'ALL_TIME',
  }) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(CommunityQueries.communityLeaderboard),
        variables: {
          'communityId': communityId,
          'timeframe': timeframe,
        },
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to fetch leaderboard: ${result.exception}');
    }

    final List<dynamic> entries = result.data?['communityLeaderboard'] ?? [];
    return entries.map((e) => LeaderboardEntry.fromJson(e)).toList();
  }

  Future<List<UserCommunity>> getUserCommunities() async {
    final startTime = DateTime.now();
    _logger.info('Fetching user communities');

    try {
      final client = await GraphQLConfig.getClient();
      
      final result = await client.query(
        QueryOptions(
          document: gql(CommunityQueries.userCommunities),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in getUserCommunities',
          error: result.exception,
        );
        _errorHandler.handleGraphQLException(result.exception!);
      }

      final List<dynamic> communities = result.data?['userCommunities'] ?? [];
      final results = communities.map((c) => UserCommunity.fromJson(c)).toList();
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logPerformance('getUserCommunities', duration, data: {
        'count': results.length,
        'activeCount': results.where((c) => c.isActive).length,
      });
      
      return results;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch user communities',
        error: e,
        stackTrace: stackTrace,
      );
      throw _errorHandler.mapException(e);
    }
  }

  Future<CommunityHabit> makeHabitPublic(
    String habitId,
    CommunitySettings settings,
  ) async {
    final startTime = DateTime.now();
    _logger.info('Making habit public', data: {
      'habitId': habitId,
      'settings': settings.toJson(),
    });

    try {
      // Validate inputs
      if (habitId.isEmpty) {
        throw ArgumentError('Habit ID cannot be empty');
      }
      if (settings.description == null || settings.description!.isEmpty) {
        throw ArgumentError('Community description is required');
      }
      if (settings.category == null || settings.category!.isEmpty) {
        throw ArgumentError('Category is required');
      }

      final client = await GraphQLConfig.getClient();
      
      final result = await client.mutate(
        MutationOptions(
          document: gql(CommunityMutations.makeHabitPublic),
          variables: {
            'habitId': habitId,
            'settings': settings.toJson(),
          },
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in makeHabitPublic',
          error: result.exception,
          data: {'habitId': habitId},
        );
        _errorHandler.handleGraphQLException(result.exception!);
      }

      if (result.data?['makeHabitPublic'] == null) {
        throw CommunityServiceException(
          'Failed to make habit public - no data returned',
          type: CommunityErrorType.unknown,
        );
      }

      final community = CommunityHabit.fromJson(result.data!['makeHabitPublic']);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logPerformance('makeHabitPublic', duration, data: {
        'habitId': habitId,
        'communityId': community.id,
      });
      
      _logger.info('Successfully made habit public', data: {
        'habitId': habitId,
        'communityId': community.id,
        'memberCount': community.memberCount,
      });
      
      return community;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to make habit public',
        error: e,
        stackTrace: stackTrace,
        data: {'habitId': habitId},
      );
      throw _errorHandler.mapException(e);
    }
  }

  Future<CommunityMembership> joinCommunity(String communityId) async {
    final startTime = DateTime.now();
    _logger.info('Joining community', data: {'communityId': communityId});

    try {
      // Validate input
      if (communityId.isEmpty) {
        throw ArgumentError('Community ID cannot be empty');
      }

      final client = await GraphQLConfig.getClient();
      
      final result = await client.mutate(
        MutationOptions(
          document: gql(CommunityMutations.joinCommunity),
          variables: {'communityId': communityId},
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in joinCommunity',
          error: result.exception,
          data: {'communityId': communityId},
        );
        _errorHandler.handleGraphQLException(result.exception!);
      }

      if (result.data?['joinCommunityHabit'] == null) {
        throw CommunityServiceException(
          'Failed to join community - no data returned',
          type: CommunityErrorType.unknown,
        );
      }

      final membership = CommunityMembership.fromJson(result.data!['joinCommunityHabit']);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logPerformance('joinCommunity', duration, data: {
        'communityId': communityId,
        'habitId': membership.habitId,
      });
      
      _logger.info('Successfully joined community', data: {
        'communityId': communityId,
        'habitId': membership.habitId,
      });
      
      return membership;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to join community',
        error: e,
        stackTrace: stackTrace,
        data: {'communityId': communityId},
      );
      throw _errorHandler.mapException(e);
    }
  }

  Future<bool> leaveCommunity(String communityId) async {
    final startTime = DateTime.now();
    _logger.info('Leaving community', data: {'communityId': communityId});

    try {
      // Validate input
      if (communityId.isEmpty) {
        throw ArgumentError('Community ID cannot be empty');
      }

      final client = await GraphQLConfig.getClient();
      
      final result = await client.mutate(
        MutationOptions(
          document: gql(CommunityMutations.leaveCommunity),
          variables: {'communityId': communityId},
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in leaveCommunity',
          error: result.exception,
          data: {'communityId': communityId},
        );
        _errorHandler.handleGraphQLException(result.exception!);
      }

      final success = result.data?['leaveCommunityHabit'] as bool? ?? false;
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logPerformance('leaveCommunity', duration, data: {
        'communityId': communityId,
        'success': success,
      });
      
      if (success) {
        _logger.info('Successfully left community', data: {'communityId': communityId});
      } else {
        _logger.warning('Leave community returned false', data: {'communityId': communityId});
      }
      
      return success;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to leave community',
        error: e,
        stackTrace: stackTrace,
        data: {'communityId': communityId},
      );
      throw _errorHandler.mapException(e);
    }
  }

  Future<bool> retireFromCommunity(String communityId) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(CommunityMutations.retireFromCommunity),
        variables: {'communityId': communityId},
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to retire from community: ${result.exception}');
    }

    return result.data!['retireFromCommunity'] as bool;
  }

  Future<Proposal> proposeChange(String communityId, ProposalInput proposal) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(CommunityMutations.proposeChange),
        variables: {
          'communityId': communityId,
          'proposal': proposal.toJson(),
        },
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to propose change: ${result.exception}');
    }

    return Proposal.fromJson(result.data!['proposeChange']);
  }

  Future<Proposal> voteOnProposal(String proposalId, bool vote) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(CommunityMutations.voteOnProposal),
        variables: {
          'proposalId': proposalId,
          'vote': vote,
        },
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to vote on proposal: ${result.exception}');
    }

    return Proposal.fromJson(result.data!['voteOnProposal']);
  }
}