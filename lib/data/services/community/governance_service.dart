import '../../../shared/models/community_models.dart';
import 'mutations.dart';
import 'base_service.dart';

class CommunityGovernanceService extends BaseCommunityService {
  Future<Proposal> proposeChange(
    String communityId,
    ProposalInput proposal,
  ) async {
    _validateProposalInput(communityId, proposal);
    
    return executeMutation(
      mutationDocument: CommunityMutations.proposeChange,
      variables: {
        'communityId': communityId,
        'proposal': proposal.toJson(),
      },
      dataExtractor: (data) => Proposal.fromJson(data['proposeChange']),
      operationName: 'proposeChange',
    );
  }

  Future<Proposal> voteOnProposal(String proposalId, bool vote) async {
    _validateProposalId(proposalId);
    
    return executeMutation(
      mutationDocument: CommunityMutations.voteOnProposal,
      variables: {
        'proposalId': proposalId,
        'vote': vote,
      },
      dataExtractor: (data) => Proposal.fromJson(data['voteOnProposal']),
      operationName: 'voteOnProposal',
    );
  }

  void _validateProposalInput(String communityId, ProposalInput proposal) {
    if (communityId.isEmpty) {
      throw ArgumentError('Community ID cannot be empty');
    }
    
    if (proposal.title.isEmpty) {
      throw ArgumentError('Proposal title cannot be empty');
    }
    
    if (proposal.title.length > 100) {
      throw ArgumentError('Proposal title must be 100 characters or less');
    }
    
    if (proposal.description.isEmpty) {
      throw ArgumentError('Proposal description cannot be empty');
    }
    
    if (proposal.description.length > 500) {
      throw ArgumentError('Proposal description must be 500 characters or less');
    }
  }

  void _validateProposalId(String proposalId) {
    if (proposalId.isEmpty) {
      throw ArgumentError('Proposal ID cannot be empty');
    }
  }
}