import 'package:flutter/material.dart';
import '../view_models/governance_view_model.dart';
import '../widgets/governance_member_card.dart';

class VotingMembersTab extends StatelessWidget {
  final List<VotingMember> members;
  final bool hasVotingRights;

  const VotingMembersTab({
    super.key,
    required this.members,
    required this.hasVotingRights,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildVotingRightsInfo(context),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GovernanceMemberCard(
                  rank: member.rank,
                  name: member.name,
                  avatar: member.avatar,
                  streak: member.streak,
                  isCreator: member.isCreator,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVotingRightsInfo(BuildContext context) {
    if (hasVotingRights) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voting Rights Requirements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To gain voting rights, maintain a 30-day streak in this community.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.3,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '9/30 days completed',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}