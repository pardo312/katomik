import 'package:katomik/data/models/community_models.dart';
import 'community/search_service.dart';
import 'community/details_service.dart';
import 'community/membership_service.dart';
import 'community/publishing_service.dart';
import 'community/governance_service.dart';

export 'package:katomik/data/models/community_models.dart';
export 'community/error_handler.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  
  late final CommunitySearchService _searchService;
  late final CommunityDetailsService _detailsService;
  late final CommunityMembershipService _membershipService;
  late final CommunityPublishingService _publishingService;
  late final CommunityGovernanceService _governanceService;
  
  CommunityService._internal() {
    _searchService = CommunitySearchService();
    _detailsService = CommunityDetailsService();
    _membershipService = CommunityMembershipService();
    _publishingService = CommunityPublishingService();
    _governanceService = CommunityGovernanceService();
  }

  Future<List<CommunityHabit>> searchCommunities({
    String? searchTerm,
    String? category,
    String? difficulty,
    int limit = 20,
    int offset = 0,
  }) => _searchService.search(
    searchTerm: searchTerm,
    category: category,
    difficulty: difficulty,
    limit: limit,
    offset: offset,
  );

  Future<List<CommunityHabit>> getPopularCommunities({int limit = 10}) =>
      _searchService.getPopular(limit: limit);

  Future<CommunityDetails> getCommunityDetails(String communityId) =>
      _detailsService.getDetails(communityId);

  Future<List<LeaderboardEntry>> getCommunityLeaderboard(
    String communityId, {
    String timeframe = 'ALL_TIME',
  }) => _detailsService.getLeaderboard(
    communityId,
    timeframe: timeframe,
  );

  Future<List<UserCommunity>> getUserCommunities() =>
      _detailsService.getUserCommunities();

  Future<CommunityHabit> makeHabitPublic(
    String habitId,
    CommunitySettings settings,
  ) => _publishingService.makeHabitPublic(habitId, settings);

  Future<CommunityMembership> joinCommunity(String communityId) =>
      _membershipService.join(communityId);

  Future<bool> leaveCommunity(String communityId) =>
      _membershipService.leave(communityId);

  Future<bool> retireFromCommunity(String communityId) =>
      _membershipService.retire(communityId);

  Future<Proposal> proposeChange(String communityId, ProposalInput proposal) =>
      _governanceService.proposeChange(communityId, proposal);

  Future<Proposal> voteOnProposal(String proposalId, bool vote) =>
      _governanceService.voteOnProposal(proposalId, vote);
}