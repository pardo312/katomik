class CommunityMutations {
  static const String makeHabitPublic = r'''
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

  static const String joinCommunity = r'''
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

  static const String leaveCommunity = r'''
    mutation LeaveCommunityHabit($communityId: ID!) {
      leaveCommunityHabit(communityId: $communityId)
    }
  ''';

  static const String retireFromCommunity = r'''
    mutation RetireFromCommunity($communityId: ID!) {
      retireFromCommunity(communityId: $communityId)
    }
  ''';

  static const String proposeChange = r'''
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

  static const String voteOnProposal = r'''
    mutation VoteOnProposal($proposalId: ID!, $vote: Boolean!) {
      voteOnProposal(proposalId: $proposalId, vote: $vote) {
        id
        status
        yesVotes
        noVotes
      }
    }
  ''';
}