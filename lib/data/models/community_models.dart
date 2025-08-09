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
                  icon: habit['icon'] ?? 'flag',
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
      icon: json['icon'] ?? 'flag',
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