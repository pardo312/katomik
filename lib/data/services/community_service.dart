import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:katomik/data/services/graphql_client.dart';
import 'package:katomik/core/logging/logger_service.dart';
import 'package:katomik/core/network/retry_service.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  
  final _logger = LoggerService();
  final _retryService = RetryService();
  
  CommunityService._internal() {
    _logger.setContext('CommunityService');
  }

  // Queries
  static const String searchCommunitiesQuery = r'''
    query SearchCommunityHabits($searchTerm: String, $category: String, $difficulty: String, $limit: Int, $offset: Int) {
      searchCommunityHabits(
        searchTerm: $searchTerm
        category: $category
        difficulty: $difficulty
        limit: $limit
        offset: $offset
      ) {
        id
        habitId
        habit {
          id
          name
          icon
          color
        }
        template {
          id
          name
          description
          category
          difficultyLevel
        }
        memberCount
        totalCompletions
        originalCreator {
          id
          displayName
        }
      }
    }
  ''';

  static const String popularCommunitiesQuery = r'''
    query PopularCommunities($limit: Int) {
      popularCommunities(limit: $limit) {
        id
        habitId
        habit {
          id
          name
          icon
          color
        }
        template {
          id
          name
          description
          category
          difficultyLevel
        }
        memberCount
        totalCompletions
      }
    }
  ''';

  static const String communityDetailsQuery = r'''
    query CommunityDetails($communityId: ID!) {
      communityDetails(communityId: $communityId) {
        id
        habitId
        habit {
          id
          name
          icon
          color
        }
        template {
          id
          name
          description
          category
          difficultyLevel
        }
        memberCount
        totalCompletions
        createdAt
        originalCreator {
          id
          displayName
        }
      }
    }
  ''';

  static const String communityLeaderboardQuery = r'''
    query CommunityLeaderboard($communityId: ID!, $timeframe: TimeFrame) {
      communityLeaderboard(communityId: $communityId, timeframe: $timeframe) {
        rank
        member {
          user {
            id
            displayName
            avatarUrl
          }
          currentStreak
          longestStreak
          totalCompletions
          joinedAt
        }
      }
    }
  ''';

  static const String userCommunitiesQuery = r'''
    query UserCommunities {
      userCommunities {
        community {
          id
          habitId
          habit {
            id
            name
            icon
            color
          }
          memberCount
          }
        currentStreak
        totalCompletions
        joinedAt
        isActive
      }
    }
  ''';

  // Mutations
  static const String makeHabitPublicMutation = r'''
    mutation MakeHabitPublic($habitId: ID!, $settings: CommunitySettings!) {
      makeHabitPublic(habitId: $habitId, settings: $settings) {
        id
        habitId
        habit {
          id
          name
        }
        memberCount
      }
    }
  ''';

  static const String joinCommunityMutation = r'''
    mutation JoinCommunityHabit($communityId: ID!) {
      joinCommunityHabit(communityId: $communityId) {
        habitId
        community {
          id
          habitId
          habit {
            id
            name
          }
        }
        joinedAt
      }
    }
  ''';

  static const String leaveCommunityMutation = r'''
    mutation LeaveCommunityHabit($communityId: ID!) {
      leaveCommunityHabit(communityId: $communityId)
    }
  ''';

  static const String retireFromCommunityMutation = r'''
    mutation RetireFromCommunity($communityId: ID!) {
      retireFromCommunity(communityId: $communityId)
    }
  ''';

  static const String proposeChangeMutation = r'''
    mutation ProposeChange($communityId: ID!, $proposal: ProposalInput!) {
      proposeChange(communityId: $communityId, proposal: $proposal) {
        id
        title
        description
        status
        createdAt
      }
    }
  ''';

  static const String voteOnProposalMutation = r'''
    mutation VoteOnProposal($proposalId: ID!, $vote: Boolean!) {
      voteOnProposal(proposalId: $proposalId, vote: $vote) {
        id
        status
        yesVotes
        noVotes
      }
    }
  ''';

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
            document: gql(searchCommunitiesQuery),
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
          shouldRetry: (error) => _isRetryableError(error),
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in searchCommunities',
          error: result.exception,
          data: {'query': 'searchCommunitiesQuery'},
        );
        _handleGraphQLException(result.exception!);
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
      throw _mapException(e);
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
          document: gql(popularCommunitiesQuery),
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
        _handleGraphQLException(result.exception!);
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
      throw _mapException(e);
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
          document: gql(communityDetailsQuery),
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
        _handleGraphQLException(result.exception!);
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
      throw _mapException(e);
    }
  }

  Future<List<LeaderboardEntry>> getCommunityLeaderboard(
    String communityId, {
    String timeframe = 'ALL_TIME',
  }) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(communityLeaderboardQuery),
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
          document: gql(userCommunitiesQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in getUserCommunities',
          error: result.exception,
        );
        _handleGraphQLException(result.exception!);
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
      throw _mapException(e);
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
          document: gql(makeHabitPublicMutation),
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
        _handleGraphQLException(result.exception!);
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
      throw _mapException(e);
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
          document: gql(joinCommunityMutation),
          variables: {'communityId': communityId},
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in joinCommunity',
          error: result.exception,
          data: {'communityId': communityId},
        );
        _handleGraphQLException(result.exception!);
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
      throw _mapException(e);
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
          document: gql(leaveCommunityMutation),
          variables: {'communityId': communityId},
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in leaveCommunity',
          error: result.exception,
          data: {'communityId': communityId},
        );
        _handleGraphQLException(result.exception!);
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
      throw _mapException(e);
    }
  }

  Future<bool> retireFromCommunity(String communityId) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(retireFromCommunityMutation),
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
        document: gql(proposeChangeMutation),
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
        document: gql(voteOnProposalMutation),
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

// Data Models for Community Features
class CommunityHabit {
  final String id;
  final String habitId;
  final String name;
  final String description;
  final String? category;
  final String? difficulty;
  final int memberCount;
  final double averageStreak;
  final int totalCompletions;
  final double successRate;
  final HabitTemplate? habitTemplate;
  final User? createdByUser;

  CommunityHabit({
    required this.id,
    required this.habitId,
    required this.name,
    required this.description,
    this.category,
    this.difficulty,
    required this.memberCount,
    required this.averageStreak,
    required this.totalCompletions,
    required this.successRate,
    this.habitTemplate,
    this.createdByUser,
  });

  factory CommunityHabit.fromJson(Map<String, dynamic> json) {
    // Handle both direct fields and nested habit/template objects
    final habit = json['habit'];
    final template = json['template'] ?? json['habitTemplate'];
    
    return CommunityHabit(
      id: json['id'],
      habitId: json['habitId'],
      name: json['name'] ?? template?['name'] ?? habit?['name'] ?? '',
      description: json['description'] ?? template?['description'] ?? '',
      category: json['category'] ?? template?['category'] ?? 'general',
      difficulty: json['difficulty'] ?? template?['difficultyLevel']?.toString().toLowerCase() ?? 'medium',
      memberCount: json['memberCount'] ?? 0,
      averageStreak: (json['averageStreak'] ?? 0).toDouble(),
      totalCompletions: json['totalCompletions'] ?? 0,
      successRate: (json['successRate'] ?? 0).toDouble(),
      habitTemplate: template != null
          ? HabitTemplate.fromJson(template)
          : habit != null
              ? HabitTemplate(
                  name: habit['name'] ?? '',
                  description: '',
                  icon: habit['icon'] ?? '🎯',
                  color: habit['color'] ?? '#FF6B6B',
                )
              : null,
      createdByUser: json['createdByUser'] != null
          ? User.fromJson(json['createdByUser'])
          : json['originalCreator'] != null
              ? User.fromJson(json['originalCreator'])
              : null,
    );
  }
}

class HabitTemplate {
  final String name;
  final String description;
  final String icon;
  final String color;

  HabitTemplate({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🎯',
      color: json['color'] ?? '#FF6B6B',
    );
  }
}

class User {
  final String id;
  final String name;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['displayName'] ?? json['name'] ?? '',
      profileImage: json['avatarUrl'] ?? json['profileImage'],
    );
  }
}

class CommunityDetails extends CommunityHabit {
  final DateTime createdAt;
  final CommunitySettings settings;
  final MemberStatus? memberStatus;

  CommunityDetails({
    required super.id,
    required super.habitId,
    required super.name,
    required super.description,
    super.category,
    super.difficulty,
    required super.memberCount,
    required super.averageStreak,
    required super.totalCompletions,
    required super.successRate,
    super.habitTemplate,
    super.createdByUser,
    required this.createdAt,
    required this.settings,
    this.memberStatus,
  });

  factory CommunityDetails.fromJson(Map<String, dynamic> json) {
    final base = CommunityHabit.fromJson(json);
    return CommunityDetails(
      id: base.id,
      habitId: base.habitId,
      name: base.name,
      description: base.description,
      category: base.category,
      difficulty: base.difficulty,
      memberCount: base.memberCount,
      averageStreak: base.averageStreak,
      totalCompletions: base.totalCompletions,
      successRate: base.successRate,
      habitTemplate: base.habitTemplate,
      createdByUser: base.createdByUser,
      createdAt: DateTime.parse(json['createdAt']),
      settings: json['settings'] != null
          ? CommunitySettings.fromJson(json['settings'])
          : CommunitySettings(),
      memberStatus: json['memberStatus'] != null
          ? MemberStatus.fromJson(json['memberStatus'])
          : null,
    );
  }
}

class CommunitySettings {
  final String? description;
  final String? category;
  final String? difficultyLevel;
  final Map<String, dynamic>? suggestedFrequency;
  final List<String>? tags;

  CommunitySettings({
    this.description,
    this.category,
    this.difficultyLevel,
    this.suggestedFrequency,
    this.tags,
  });

  factory CommunitySettings.fromJson(Map<String, dynamic> json) {
    return CommunitySettings(
      description: json['description'],
      category: json['category'],
      difficultyLevel: json['difficultyLevel'],
      suggestedFrequency: json['suggestedFrequency'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (description != null) data['description'] = description;
    if (category != null) data['category'] = category;
    if (difficultyLevel != null) data['difficultyLevel'] = difficultyLevel;
    if (suggestedFrequency != null) data['suggestedFrequency'] = suggestedFrequency;
    if (tags != null) data['tags'] = tags;
    return data;
  }
}

class MemberStatus {
  final bool isMember;
  final DateTime? joinedAt;
  final int currentStreak;
  final int totalCompletions;

  MemberStatus({
    required this.isMember,
    this.joinedAt,
    required this.currentStreak,
    required this.totalCompletions,
  });

  factory MemberStatus.fromJson(Map<String, dynamic> json) {
    return MemberStatus(
      isMember: json['isMember'],
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : null,
      currentStreak: json['currentStreak'],
      totalCompletions: json['totalCompletions'],
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final CommunityMember member;

  LeaderboardEntry({
    required this.rank,
    required this.member,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'],
      member: CommunityMember.fromJson(json['member']),
    );
  }
}

class CommunityMember {
  final User user;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final DateTime joinedAt;

  CommunityMember({
    required this.user,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.joinedAt,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      user: User.fromJson(json['user']),
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
      totalCompletions: json['totalCompletions'],
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}

class UserCommunity {
  final CommunityHabit community;
  final int currentStreak;
  final int totalCompletions;
  final DateTime joinedAt;
  final bool isActive;

  UserCommunity({
    required this.community,
    required this.currentStreak,
    required this.totalCompletions,
    required this.joinedAt,
    required this.isActive,
  });

  factory UserCommunity.fromJson(Map<String, dynamic> json) {
    return UserCommunity(
      community: CommunityHabit.fromJson(json['community']),
      currentStreak: json['currentStreak'],
      totalCompletions: json['totalCompletions'],
      joinedAt: DateTime.parse(json['joinedAt']),
      isActive: json['isActive'],
    );
  }
}

class CommunityMembership {
  final int habitId;
  final CommunityHabit community;
  final DateTime joinedAt;

  CommunityMembership({
    required this.habitId,
    required this.community,
    required this.joinedAt,
  });

  factory CommunityMembership.fromJson(Map<String, dynamic> json) {
    return CommunityMembership(
      habitId: json['habitId'],
      community: CommunityHabit.fromJson(json['community']),
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}

class Proposal {
  final String id;
  final String title;
  final String description;
  final String status;
  final int yesVotes;
  final int noVotes;
  final DateTime createdAt;

  Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.yesVotes,
    required this.noVotes,
    required this.createdAt,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      yesVotes: json['yesVotes'] ?? 0,
      noVotes: json['noVotes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ProposalInput {
  final String title;
  final String description;
  final ProposalType type;
  final Map<String, dynamic>? changes;

  ProposalInput({
    required this.title,
    required this.description,
    required this.type,
    this.changes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'changes': changes,
    };
  }
}

enum ProposalType {
  changeDescription,
  changeSettings,
  changeName,
  other,
}

// Error handling extension for CommunityService
extension CommunityServiceErrorHandling on CommunityService {
  bool _isRetryableError(dynamic error) {
    if (error is OperationException) {
      // Retry on network errors
      if (error.linkException != null) {
        final linkException = error.linkException!;
        if (linkException is NetworkException || linkException is ServerException) {
          return true;
        }
      }
      
      // Don't retry on GraphQL errors (usually client errors)
      if (error.graphqlErrors.isNotEmpty) {
        final firstError = error.graphqlErrors.first;
        final message = firstError.message.toLowerCase();
        
        // Don't retry on client errors
        if (message.contains('unauthorized') || 
            message.contains('forbidden') ||
            message.contains('not found') ||
            message.contains('already exists') ||
            message.contains('invalid')) {
          return false;
        }
      }
      
      return true;
    }
    
    // Retry on timeout
    if (error is TimeoutException) return true;
    
    // Check error message for network-related issues
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket');
  }
  
  void _handleGraphQLException(OperationException exception) {
    if (exception.linkException != null) {
      final linkException = exception.linkException!;
      if (linkException is NetworkException) {
        throw CommunityServiceException(
          'Network error. Please check your connection.',
          type: CommunityErrorType.network,
        );
      } else if (linkException is ServerException) {
        throw CommunityServiceException(
          'Server error. Please try again later.',
          type: CommunityErrorType.server,
        );
      }
    }

    // Parse GraphQL errors
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final message = error.message;
      
      if (message.contains('not found')) {
        throw CommunityServiceException(
          message,
          type: CommunityErrorType.notFound,
        );
      } else if (message.contains('unauthorized') || message.contains('forbidden')) {
        throw CommunityServiceException(
          message,
          type: CommunityErrorType.unauthorized,
        );
      } else if (message.contains('already')) {
        throw CommunityServiceException(
          message,
          type: CommunityErrorType.duplicate,
        );
      }
    }

    throw CommunityServiceException(
      'An unexpected error occurred',
      type: CommunityErrorType.unknown,
    );
  }

  Exception _mapException(dynamic error) {
    if (error is CommunityServiceException) {
      return error;
    } else if (error is ArgumentError) {
      return CommunityServiceException(
        error.message?.toString() ?? 'Invalid argument',
        type: CommunityErrorType.validation,
      );
    } else if (error is Exception) {
      return CommunityServiceException(
        error.toString(),
        type: CommunityErrorType.unknown,
      );
    } else {
      return CommunityServiceException(
        'An unexpected error occurred',
        type: CommunityErrorType.unknown,
      );
    }
  }
}

enum CommunityErrorType {
  network,
  server,
  notFound,
  unauthorized,
  duplicate,
  validation,
  unknown,
}

class CommunityServiceException implements Exception {
  final String message;
  final CommunityErrorType type;
  final dynamic originalError;

  CommunityServiceException(
    this.message, {
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'CommunityServiceException: $message (type: ${type.name})';
}