import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../view_models/governance_view_model.dart';
import '../widgets/proposal_card.dart';
import '../../../core/constants/app_colors.dart';

class ProposalsTab extends StatelessWidget {
  final List<Proposal> proposals;
  final bool hasVotingRights;
  final Function(String, bool) onVote;
  final VoidCallback onCreateProposal;

  const ProposalsTab({
    super.key,
    required this.proposals,
    required this.hasVotingRights,
    required this.onVote,
    required this.onCreateProposal,
  });

  @override
  Widget build(BuildContext context) {
    if (proposals.isEmpty) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: proposals.length,
          itemBuilder: (context, index) {
            final proposal = proposals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProposalCard(
                proposal: {
                  'id': proposal.id,
                  'type': proposal.type,
                  'title': proposal.title,
                  'proposedBy': proposal.proposedBy,
                  'createdAt': _formatTime(proposal.createdAt),
                  'expiresIn': proposal.timeRemaining,
                  'votesRequired': proposal.votesRequired,
                  'votes': proposal.votes.map((v) => {
                    'voter': v.voterName,
                    'vote': v.isApprove ? 'APPROVE' : 'REJECT',
                  }).toList(),
                  'status': proposal.status.name.toUpperCase(),
                },
                hasVotingRights: hasVotingRights,
                onVote: (voteType) {
                  if (voteType == 'APPROVE') {
                    onVote(proposal.id, true);
                  } else {
                    onVote(proposal.id, false);
                  }
                },
              ),
            );
          },
        ),
        if (hasVotingRights)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: onCreateProposal,
              backgroundColor: AppColors.primary,
              child: const Icon(CupertinoIcons.add, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.doc_text,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Proposals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasVotingRights
                ? 'Be the first to propose a change'
                : 'Check back later for new proposals',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          if (hasVotingRights) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateProposal,
              icon: const Icon(CupertinoIcons.add),
              label: const Text('Create Proposal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    return '${difference.inMinutes} minutes ago';
  }
}