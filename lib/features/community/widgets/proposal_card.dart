import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';

class ProposalCard extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final bool hasVotingRights;
  final Function(String) onVote;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.hasVotingRights,
    required this.onVote,
  });

  IconData _getProposalIcon(String type) {
    switch (type) {
      case 'MODIFY_HABIT':
        return CupertinoIcons.pencil_circle_fill;
      case 'DELETE_HABIT':
        return CupertinoIcons.trash_circle_fill;
      case 'CHANGE_RULES':
        return CupertinoIcons.doc_text_fill;
      case 'REMOVE_MEMBER':
        return CupertinoIcons.person_crop_circle_badge_xmark;
      default:
        return CupertinoIcons.question_circle_fill;
    }
  }

  Color _getProposalColor(String type) {
    switch (type) {
      case 'MODIFY_HABIT':
        return Colors.blue;
      case 'DELETE_HABIT':
        return Colors.red;
      case 'CHANGE_RULES':
        return Colors.orange;
      case 'REMOVE_MEMBER':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getProposalTypeLabel(String type) {
    switch (type) {
      case 'MODIFY_HABIT':
        return 'Modify Habit';
      case 'DELETE_HABIT':
        return 'Delete Habit';
      case 'CHANGE_RULES':
        return 'Change Rules';
      case 'REMOVE_MEMBER':
        return 'Remove Member';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = proposal['type'] as String;
    final votes = (proposal['votes'] as List).cast<Map<String, dynamic>>();
    final votesRequired = proposal['votesRequired'] as int;
    final approveCount = votes.where((v) => v['vote'] == 'APPROVE').length;
    final rejectCount = votes.where((v) => v['vote'] == 'REJECT').length;
    final currentUserVote = votes.firstWhere(
      (v) => v['voter'] == 'You',
      orElse: () => {},
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getProposalColor(type).withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getProposalIcon(type),
                  color: _getProposalColor(type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getProposalColor(type).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getProposalTypeLabel(type),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getProposalColor(type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (proposal['status'] == 'PENDING')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.clock,
                                  size: 12,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Expires in ${proposal['expiresIn']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Proposed by ${proposal['proposedBy']} • ${proposal['createdAt']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Title
          Text(
            proposal['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voting Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Votes: ${votes.length}/$votesRequired required',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '${((approveCount / votesRequired) * 100).toInt()}% approval',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: votes.length / votesRequired,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  approveCount >= (votesRequired * 0.6) 
                    ? Colors.green 
                    : AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Vote Breakdown
          Row(
            children: [
              _buildVoteCount(
                icon: CupertinoIcons.checkmark_circle_fill,
                count: approveCount,
                color: Colors.green,
                label: 'Approve',
              ),
              const SizedBox(width: 16),
              _buildVoteCount(
                icon: CupertinoIcons.xmark_circle_fill,
                count: rejectCount,
                color: Colors.red,
                label: 'Reject',
              ),
            ],
          ),
          
          // Voters List
          if (votes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: votes.map((vote) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: vote['vote'] == 'APPROVE'
                    ? Colors.green.withValues(alpha:0.1)
                    : Colors.red.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      vote['vote'] == 'APPROVE'
                        ? CupertinoIcons.checkmark
                        : CupertinoIcons.xmark,
                      size: 14,
                      color: vote['vote'] == 'APPROVE'
                        ? Colors.green
                        : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vote['voter'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
          
          // Vote Actions
          if (hasVotingRights && 
              proposal['status'] == 'PENDING' && 
              currentUserVote.isEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onVote('REJECT'),
                    icon: const Icon(CupertinoIcons.xmark),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onVote('APPROVE'),
                    icon: const Icon(CupertinoIcons.checkmark),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoteCount({
    required IconData icon,
    required int count,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}