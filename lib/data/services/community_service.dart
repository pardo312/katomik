import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:katomik/data/services/graphql_client.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

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
        isPublic
        totalCompletions
        originalCreator {
          id
          name
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
        isPublic
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
        isPublic
        createdAt
        originalCreator {
          id
          name
        }
        memberStatus {
          isMember
          joinedAt
          currentStreak
          totalCompletions
        }
      }
    }
  ''';

  static const String communityLeaderboardQuery = r'''
    query CommunityLeaderboard($communityId: ID!, $timeframe: String, $limit: Int) {
      communityLeaderboard(communityId: $communityId, timeframe: $timeframe, limit: $limit) {
        rank
        member {
          user {
            id
            name
            profileImage
          }
          currentStreak
          longestStreak
          totalCompletions
          completionRate
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
          isPublic
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
        isPublic
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
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
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
    );

    if (result.hasException) {
      throw Exception('Failed to search communities: ${result.exception}');
    }

    final List<dynamic> communities = result.data?['searchCommunityHabits'] ?? [];
    return communities.map((c) => CommunityHabit.fromJson(c)).toList();
  }

  Future<List<CommunityHabit>> getPopularCommunities({int limit = 10}) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(popularCommunitiesQuery),
        variables: {'limit': limit},
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to fetch popular communities: ${result.exception}');
    }

    final List<dynamic> communities = result.data?['popularCommunities'] ?? [];
    return communities.map((c) => CommunityHabit.fromJson(c)).toList();
  }

  Future<CommunityDetails> getCommunityDetails(String communityId) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(communityDetailsQuery),
        variables: {'communityId': communityId},
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to fetch community details: ${result.exception}');
    }

    return CommunityDetails.fromJson(result.data!['communityDetails']);
  }

  Future<List<LeaderboardEntry>> getCommunityLeaderboard(
    String communityId, {
    String timeframe = 'all',
    int limit = 50,
  }) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(communityLeaderboardQuery),
        variables: {
          'communityId': communityId,
          'timeframe': timeframe,
          'limit': limit,
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
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(userCommunitiesQuery),
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to fetch user communities: ${result.exception}');
    }

    final List<dynamic> communities = result.data?['userCommunities'] ?? [];
    return communities.map((c) => UserCommunity.fromJson(c)).toList();
  }

  Future<CommunityHabit> makeHabitPublic(
    String habitId,
    CommunitySettings settings,
  ) async {
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
      throw Exception('Failed to make habit public: ${result.exception}');
    }

    return CommunityHabit.fromJson(result.data!['makeHabitPublic']);
  }

  Future<CommunityMembership> joinCommunity(String communityId) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(joinCommunityMutation),
        variables: {'communityId': communityId},
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to join community: ${result.exception}');
    }

    return CommunityMembership.fromJson(result.data!['joinCommunityHabit']);
  }

  Future<bool> leaveCommunity(String communityId) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(leaveCommunityMutation),
        variables: {'communityId': communityId},
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to leave community: ${result.exception}');
    }

    return result.data!['leaveCommunityHabit'] as bool;
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
  final bool isPublic;
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
    required this.isPublic,
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
      isPublic: json['isPublic'] ?? false,
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
      name: json['name'],
      profileImage: json['profileImage'],
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
    required super.isPublic,
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
      isPublic: base.isPublic,
      habitTemplate: base.habitTemplate,
      createdByUser: base.createdByUser,
      createdAt: DateTime.parse(json['createdAt']),
      settings: CommunitySettings.fromJson(json['settings']),
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
  final double completionRate;
  final DateTime joinedAt;

  CommunityMember({
    required this.user,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.completionRate,
    required this.joinedAt,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      user: User.fromJson(json['user']),
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
      totalCompletions: json['totalCompletions'],
      completionRate: json['completionRate'].toDouble(),
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