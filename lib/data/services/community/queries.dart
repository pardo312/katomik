class CommunityQueries {
  static const String searchCommunities = r'''
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

  static const String popularCommunities = r'''
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

  static const String communityDetails = r'''
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

  static const String communityLeaderboard = r'''
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

  static const String userCommunities = r'''
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
}