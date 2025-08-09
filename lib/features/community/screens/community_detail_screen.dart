import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/community_provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/platform_provider.dart';
import '../../../data/models/community_models.dart';
import '../view_models/community_detail_view_model.dart';
import '../widgets/community_header.dart';
import '../widgets/community_member_status.dart';
import '../widgets/loading_state.dart';
import '../widgets/error_state.dart';
import '../widgets/join_community_dialog.dart';
import '../dialogs/leave_community_dialog.dart';
import '../tabs/leaderboard_tab.dart';
import '../tabs/stats_tab.dart';
import '../tabs/about_tab.dart';
import '../utils/message_handler.dart';
import 'governance_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityDetailScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CommunityDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeViewModel();
  }

  void _initializeViewModel() {
    _viewModel = CommunityDetailViewModel(
      communityProvider: context.read<CommunityProvider>(),
      habitProvider: context.read<HabitProvider>(),
      authProvider: context.read<AuthProvider>(),
      communityId: widget.communityId,
      communityName: widget.communityName,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize();
    });
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
            if (!_viewModel.isInitialized || _viewModel.isLoading) {
              return const LoadingState(message: 'Loading community...');
            }

            if (_viewModel.error != null) {
              return ErrorState(
                message: 'Error loading community',
                onRetry: _viewModel.loadCommunityDetails,
              );
            }

            final community = _viewModel.community;
            if (community == null) {
              return const Center(child: Text('Community not found'));
            }

            return _buildContent(community);
          },
        ),
      ),
    );
  }

  Widget _buildContent(CommunityDetails community) {
    return Column(
      children: [
        CommunityHeader(
          name: community.name,
          icon: community.habitTemplate?.icon ?? 'flag',
          iconColor: community.habitTemplate?.color,
          onBack: () => Navigator.pop(context),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: CommunityMemberStatus(
            isMember: _viewModel.isMember,
            memberCount: community.memberCount,
            userRank: _viewModel.userRank,
            userStreak: _viewModel.userStreak,
            onJoin: _handleJoinCommunity,
            onLeave: _handleLeaveCommunity,
            onGovernance: _navigateToGovernance,
          ),
        ),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              LeaderboardTab(
                communityId: widget.communityId,
                isMember: _viewModel.isMember,
                userRank: _viewModel.userRank,
                currentUserEntry: _viewModel.currentUserEntry,
                leaderboard: _viewModel.leaderboard,
                selectedTimeframe: _viewModel.selectedTimeframe,
                onTimeframeChanged: _viewModel.updateTimeframe,
              ),
              StatsTab(
                memberCount: community.memberCount,
                totalCompletions: community.totalCompletions,
                averageStreak: community.averageStreak.toInt(),
                successRate: community.successRate,
                createdDate: _viewModel.formatDate(community.createdAt),
              ),
              AboutTab(
                description: community.description,
                category: community.category ?? 'general',
                difficulty: community.difficulty ?? 'medium',
                creatorName: community.createdByUser?.name,
                suggestedFrequency: community.settings.suggestedFrequency,
                tags: community.settings.tags,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Tab(text: 'Leaderboard'),
          Tab(text: 'Stats'),
          Tab(text: 'About'),
        ],
      ),
    );
  }

  void _handleJoinCommunity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => JoinCommunityDialog(
        communityName: widget.communityName,
        onJoin: () async {
          Navigator.pop(bottomSheetContext);
          final success = await _viewModel.joinCommunity();
          
          if (mounted) {
            final isIOS = context.read<PlatformProvider>().isIOS;
            MessageHandler.showMessage(
              context,
              success
                  ? 'Welcome to ${widget.communityName}!'
                  : 'Failed to join community',
              isError: !success,
              isIOS: isIOS,
            );
          }
        },
      ),
    );
  }

  void _handleLeaveCommunity() {
    showDialog(
      context: context,
      builder: (dialogContext) => LeaveCommunityDialog(
        communityName: widget.communityName,
        onConfirm: () async {
          final success = await _viewModel.leaveCommunity();
          
          if (mounted) {
            final isIOS = context.read<PlatformProvider>().isIOS;
            MessageHandler.showMessage(
              context,
              success
                  ? 'You have left the community'
                  : 'Failed to leave community',
              isError: !success,
              isIOS: isIOS,
            );
          }
        },
      ),
    );
  }

  void _navigateToGovernance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GovernanceScreen(
          communityId: widget.communityId,
          communityName: widget.communityName,
        ),
      ),
    );
  }
}