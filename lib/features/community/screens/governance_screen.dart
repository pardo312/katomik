import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/governance_member_card.dart';
import '../widgets/proposal_card.dart';
import '../widgets/create_proposal_dialog.dart';

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
  final bool _hasVotingRights = false; // Will be fetched from API

  // Mock data
  final List<Map<String, dynamic>> _votingMembers = [
    {
      'rank': 1,
      'name': 'Sarah M.',
      'avatar': '👩',
      'streak': 156,
      'isCreator': true,
    },
    {
      'rank': 2,
      'name': 'John D.',
      'avatar': '👨',
      'streak': 142,
      'isCreator': false,
    },
    {
      'rank': 3,
      'name': 'Emma L.',
      'avatar': '👩‍🦰',
      'streak': 98,
      'isCreator': false,
    },
    {
      'rank': 4,
      'name': 'Mike R.',
      'avatar': '👨‍🦱',
      'streak': 87,
      'isCreator': false,
    },
    {
      'rank': 5,
      'name': 'Lisa K.',
      'avatar': '👩‍🦳',
      'streak': 76,
      'isCreator': false,
    },
  ];

  final List<Map<String, dynamic>> _activeProposals = [
    {
      'id': '1',
      'type': 'MODIFY_HABIT',
      'title': 'Change reminder time to 7 AM',
      'proposedBy': 'John D.',
      'createdAt': '2 days ago',
      'expiresIn': '1 day',
      'votesRequired': 3,
      'votes': [
        {'voter': 'John D.', 'vote': 'APPROVE'},
        {'voter': 'Emma L.', 'vote': 'APPROVE'},
      ],
      'status': 'PENDING',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateProposalDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateProposalDialog(
        communityName: widget.communityName,
        onSubmit: (type, data) {
          // Handle proposal creation
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proposal submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.arrow_left),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Community Governance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Top 5 members have voting rights',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Voting Members'),
                  Tab(text: 'Active Proposals'),
                  Tab(text: 'History'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Voting Members Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _votingMembers.length,
                    itemBuilder: (context, index) {
                      final member = _votingMembers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GovernanceMemberCard(
                          rank: member['rank'],
                          name: member['name'],
                          avatar: member['avatar'],
                          streak: member['streak'],
                          isCreator: member['isCreator'],
                        ),
                      );
                    },
                  ),
                  
                  // Active Proposals Tab
                  _activeProposals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.doc_text,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No active proposals',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _activeProposals.length,
                        itemBuilder: (context, index) {
                          final proposal = _activeProposals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ProposalCard(
                              proposal: proposal,
                              hasVotingRights: _hasVotingRights,
                              onVote: (vote) {
                                // Handle vote
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Your vote has been recorded: $vote'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                  
                  // History Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Proposal history coming soon',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Create Proposal Button (only for voting members)
            if (_hasVotingRights)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _showCreateProposalDialog,
                    icon: const Icon(CupertinoIcons.add),
                    label: const Text(
                      'Create Proposal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}