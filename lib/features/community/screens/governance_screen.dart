import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../view_models/governance_view_model.dart';
import '../tabs/voting_members_tab.dart';
import '../tabs/proposals_tab.dart';
import '../widgets/create_proposal_dialog.dart';
import '../../../core/constants/app_colors.dart';

class GovernanceScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const GovernanceScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  State<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends State<GovernanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GovernanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel = GovernanceViewModel(
      communityId: widget.communityId,
      communityName: widget.communityName,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      VotingMembersTab(
                        members: _viewModel.votingMembers,
                        hasVotingRights: _viewModel.hasVotingRights,
                      ),
                      ProposalsTab(
                        proposals: _viewModel.activeProposals,
                        hasVotingRights: _viewModel.hasVotingRights,
                        onVote: _viewModel.voteOnProposal,
                        onCreateProposal: _showCreateProposalDialog,
                      ),
                      ProposalsTab(
                        proposals: _viewModel.proposalHistory,
                        hasVotingRights: false,
                        onVote: (_, __) {},
                        onCreateProposal: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              CupertinoIcons.arrow_left,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Governance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.communityName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Members'),
          Tab(text: 'Proposals'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  void _showCreateProposalDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateProposalDialog(
        communityName: widget.communityName,
        onSubmit: (type, data) {
          Navigator.pop(context);
          _viewModel.createProposal(
            type,
            data['title'] ?? '',
            data['description'] ?? '',
          );
          _showSuccessMessage('Proposal created successfully');
        },
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }
}