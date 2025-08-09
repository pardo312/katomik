import 'package:flutter/foundation.dart';

class GovernanceViewModel extends ChangeNotifier {
  final String communityId;
  final String communityName;

  int _selectedTabIndex = 0;
  final bool _hasVotingRights = false;
  List<VotingMember> _votingMembers = [];
  List<Proposal> _activeProposals = [];
  List<Proposal> _proposalHistory = [];

  GovernanceViewModel({
    required this.communityId,
    required this.communityName,
  }) {
    _loadMockData();
  }

  int get selectedTabIndex => _selectedTabIndex;
  bool get hasVotingRights => _hasVotingRights;
  List<VotingMember> get votingMembers => _votingMembers;
  List<Proposal> get activeProposals => _activeProposals;
  List<Proposal> get proposalHistory => _proposalHistory;

  void updateTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> voteOnProposal(String proposalId, bool approve) async {
    final proposalIndex = _activeProposals.indexWhere(
      (p) => p.id == proposalId,
    );
    if (proposalIndex != -1) {
      _activeProposals[proposalIndex].addVote(
        Vote(voterName: 'Current User', isApprove: approve),
      );
      notifyListeners();
    }
  }

  Future<void> createProposal(
    String type,
    String title,
    String description,
  ) async {
    final newProposal = Proposal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      description: description,
      proposedBy: 'Current User',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      votesRequired: 3,
      votes: [],
      status: ProposalStatus.pending,
    );

    _activeProposals.add(newProposal);
    notifyListeners();
  }

  void _loadMockData() {
    _votingMembers = [
      VotingMember(
        rank: 1,
        name: 'Sarah M.',
        avatar: '👩',
        streak: 156,
        isCreator: true,
      ),
      VotingMember(
        rank: 2,
        name: 'John D.',
        avatar: '👨',
        streak: 142,
        isCreator: false,
      ),
      VotingMember(
        rank: 3,
        name: 'Emma L.',
        avatar: '👩‍🦰',
        streak: 98,
        isCreator: false,
      ),
      VotingMember(
        rank: 4,
        name: 'Mike R.',
        avatar: '👨‍🦱',
        streak: 87,
        isCreator: false,
      ),
      VotingMember(
        rank: 5,
        name: 'Lisa K.',
        avatar: '👩‍🦳',
        streak: 76,
        isCreator: false,
      ),
    ];

    _activeProposals = [
      Proposal(
        id: '1',
        type: 'MODIFY_HABIT',
        title: 'Change reminder time to 7 AM',
        description: 'Adjust the default reminder time for better engagement',
        proposedBy: 'John D.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        votesRequired: 3,
        votes: [
          Vote(voterName: 'John D.', isApprove: true),
          Vote(voterName: 'Emma L.', isApprove: true),
        ],
        status: ProposalStatus.pending,
      ),
    ];

    _proposalHistory = [
      Proposal(
        id: '2',
        type: 'CHANGE_SETTINGS',
        title: 'Update community description',
        description: 'Make the description more engaging',
        proposedBy: 'Sarah M.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        expiresAt: DateTime.now().subtract(const Duration(days: 4)),
        votesRequired: 3,
        votes: [
          Vote(voterName: 'Sarah M.', isApprove: true),
          Vote(voterName: 'John D.', isApprove: true),
          Vote(voterName: 'Emma L.', isApprove: true),
        ],
        status: ProposalStatus.approved,
      ),
    ];
  }
}

class VotingMember {
  final int rank;
  final String name;
  final String avatar;
  final int streak;
  final bool isCreator;

  VotingMember({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.streak,
    required this.isCreator,
  });
}

class Proposal {
  final String id;
  final String type;
  final String title;
  final String description;
  final String proposedBy;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int votesRequired;
  final List<Vote> votes;
  ProposalStatus status;

  Proposal({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.proposedBy,
    required this.createdAt,
    required this.expiresAt,
    required this.votesRequired,
    required this.votes,
    required this.status,
  });

  void addVote(Vote vote) {
    votes.add(vote);
    if (votes.where((v) => v.isApprove).length >= votesRequired) {
      status = ProposalStatus.approved;
    }
  }

  String get timeRemaining {
    final difference = expiresAt.difference(DateTime.now());
    if (difference.isNegative) return 'Expired';
    if (difference.inDays > 0) return '${difference.inDays} days';
    if (difference.inHours > 0) return '${difference.inHours} hours';
    return '${difference.inMinutes} minutes';
  }
}

class Vote {
  final String voterName;
  final bool isApprove;

  Vote({required this.voterName, required this.isApprove});
}

enum ProposalStatus { pending, approved, rejected, expired }
