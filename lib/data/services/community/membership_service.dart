import '../../../shared/models/community_models.dart';
import 'mutations.dart';
import 'base_service.dart';

class CommunityMembershipService extends BaseCommunityService {
  Future<CommunityMembership> join(String communityId) async {
    _validateCommunityId(communityId);
    
    return executeMutation(
      mutationDocument: CommunityMutations.joinCommunity,
      variables: {'communityId': communityId},
      dataExtractor: (data) => CommunityMembership.fromJson(data['joinCommunityHabit']),
      operationName: 'joinCommunity',
    );
  }

  Future<bool> leave(String communityId) async {
    _validateCommunityId(communityId);
    
    return executeMutation(
      mutationDocument: CommunityMutations.leaveCommunity,
      variables: {'communityId': communityId},
      dataExtractor: (data) => data['leaveCommunityHabit'] as bool? ?? false,
      operationName: 'leaveCommunity',
    );
  }

  Future<bool> retire(String communityId) async {
    _validateCommunityId(communityId);
    
    return executeMutation(
      mutationDocument: CommunityMutations.retireFromCommunity,
      variables: {'communityId': communityId},
      dataExtractor: (data) => data['retireFromCommunity'] as bool,
      operationName: 'retireFromCommunity',
    );
  }

  void _validateCommunityId(String communityId) {
    if (communityId.isEmpty) {
      throw ArgumentError('Community ID cannot be empty');
    }
  }
}