import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/community_provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/services/community_service.dart';
import '../widgets/leaderboard_list.dart';
import '../widgets/community_stats_card.dart';
import '../widgets/join_community_dialog.dart';
import 'governance_screen.dart';
import '../../habit/widgets/habit_icon.dart';

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
  bool _isInitialized = false;
  String _selectedTimeframe = 'ALL_TIME';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommunityDetails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunityDetails() async {
    final provider = context.read<CommunityProvider>();
    await provider.loadCommunityDetails(widget.communityId);
    await provider.loadLeaderboard(widget.communityId);
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadLeaderboard(String timeframe) async {
    final provider = context.read<CommunityProvider>();
    await provider.loadLeaderboard(widget.communityId, timeframe: timeframe);
  }

  void _showJoinDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JoinCommunityDialog(
        communityName: widget.communityName,
        onJoin: () async {
          Navigator.pop(context);
          final communityProvider = context.read<CommunityProvider>();
          final habitProvider = context.read<HabitProvider>();
          
          final success = await communityProvider.joinCommunity(
            widget.communityId,
            habitProvider,
          );
          
          if (success) {
            await _loadCommunityDetails();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcome to ${widget.communityName}!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to join community'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _leaveCommunity() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Community?'),
        content: Text(
          'Are you sure you want to leave ${widget.communityName}? '
          'You can rejoin anytime, and your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<CommunityProvider>();
              
              final success = await provider.leaveCommunity(widget.communityId);
              
              if (success) {
                await _loadCommunityDetails();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have left the community'),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to leave community'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<CommunityProvider>(
          builder: (context, provider, child) {
            if (!_isInitialized || provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading community',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadCommunityDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final community = provider.currentCommunityDetails;
            if (community == null) {
              return const Center(
                child: Text('Community not found'),
              );
            }

            // Check if user is a member by looking at their habits
            final habitProvider = context.watch<HabitProvider>();
            final isMember = habitProvider.habits.any(
              (habit) => habit.communityId == widget.communityId,
            );
            final authProvider = context.watch<AuthProvider>();
            final currentUserId = authProvider.user?.id;
            
            // Find the current user's entry in the leaderboard
            LeaderboardEntry? currentUserEntry;
            int userRank = 0;
            if (currentUserId != null) {
              final userIndex = provider.currentLeaderboard.indexWhere(
                (entry) => entry.member.user.id == currentUserId,
              );
              if (userIndex != -1) {
                currentUserEntry = provider.currentLeaderboard[userIndex];
                userRank = userIndex + 1;
              }
            }
            
            // Get user streak from leaderboard entry if member
            final userStreak = currentUserEntry?.member.currentStreak ?? 0;

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
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
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: community.habitTemplate?.color != null
                                        ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF'))).withValues(alpha: 0.15)
                                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: HabitIcon(
                                      iconName: community.habitTemplate?.icon ?? 'flag',
                                      size: 32,
                                      color: community.habitTemplate?.color != null
                                          ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF')))
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  community.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          if (isMember)
                            IconButton(
                              icon: const Icon(CupertinoIcons.gear),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GovernanceScreen(
                                      communityId: widget.communityId,
                                      communityName: community.name,
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Member Status
                      if (isMember) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (community.habitTemplate?.color != null
                            ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF')))
                            : AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.person_crop_circle_badge_checkmark,
                            size: 20,
                            color: community.habitTemplate?.color != null
                                ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF')))
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Member',
                            style: TextStyle(
                              color: community.habitTemplate?.color != null
                                  ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF')))
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 16,
                            color: (community.habitTemplate?.color != null
                                ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF')))
                                : AppColors.primary).withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 16),
                          if (userRank > 0) ...[  
                            Text(
                              'Rank #$userRank',
                              style: TextStyle(
                                color: community.habitTemplate?.color != null
                                    ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF')))
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: community.habitTemplate?.color != null
                                    ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF')))
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            CupertinoIcons.flame,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$userStreak days',
                            style: TextStyle(
                              color: community.habitTemplate?.color != null
                                  ? Color(int.parse(community.habitTemplate!.color.replaceAll('#', '0xFF')))
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
                // Tab Bar
                Container(
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
                ),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Leaderboard Tab
                      Column(
                        children: [
                          // Timeframe selector
                          Container(
                            color: Theme.of(context).colorScheme.surface,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                _buildTimeframeButton('Week', 'WEEKLY'),
                                const SizedBox(width: 8),
                                _buildTimeframeButton('Month', 'MONTHLY'),
                                const SizedBox(width: 8),
                                _buildTimeframeButton('All Time', 'ALL_TIME'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: LeaderboardList(
                                communityId: widget.communityId,
                                currentUserRank: isMember ? userRank : null,
                                currentUserEntry: isMember ? currentUserEntry : null,
                                leaderboard: provider.currentLeaderboard,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Stats Tab
                      Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CommunityStatsCard(
                                memberCount: community.memberCount,
                                totalCompletions: community.totalCompletions,
                                averageStreak: community.averageStreak.toInt(),
                                successRate: community.successRate,
                                createdDate: _formatDate(community.createdAt),
                              ),
                              const SizedBox(height: 16),
                              // Additional stats widgets can be added here
                            ],
                          ),
                        ),
                      ),
                      
                      // About Tab
                      Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            const Text(
                              'About this Community',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              community.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                        const SizedBox(height: 24),
                        const Text(
                          'Community Rules',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRule('1', 'Complete at least 10 minutes of meditation'),
                        _buildRule('2', 'Log your practice honestly'),
                        _buildRule('3', 'Support and encourage other members'),
                        _buildRule('4', 'Share your experiences and tips'),
                        const SizedBox(height: 24),
                        const Text(
                          'Governance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.star_fill,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Top 5 members by streak length have voting rights '
                                  'on community decisions',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
            
                // Action Button
                if (!isMember)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _showJoinDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Join Community',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _leaveCommunity,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                                side: BorderSide(color: Theme.of(context).colorScheme.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Leave Community',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Retire from Community'),
                                  content: const Text(
                                    'This will permanently delete all your data from this community. '
                                    'This action cannot be undone. Are you sure?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        final habitProvider = context.read<HabitProvider>();
                                        
                                        // Find the local habit ID for this community
                                        final localHabit = habitProvider.habits.firstWhere(
                                          (habit) => habit.communityId == widget.communityId,
                                          orElse: () => throw Exception('Local habit not found for community'),
                                        );
                                        
                                        final success = await provider.retireFromCommunity(
                                          widget.communityId,
                                          localHabit.id!,
                                          habitProvider,
                                        );
                                        if (success && mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('You have retired from the community'),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Retire',
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Retire',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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

  Widget _buildRule(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeButton(String label, String timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeframe = timeframe;
          });
          _loadLeaderboard(timeframe);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}