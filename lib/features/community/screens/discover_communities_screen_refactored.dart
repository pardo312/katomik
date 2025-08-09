import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/community_provider.dart';
import '../../../data/services/community_service.dart';
import '../widgets/community_card.dart';
import '../widgets/community_search_bar.dart';
import '../widgets/community_filters.dart';
import '../widgets/loading_state.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import '../view_models/discover_view_model.dart';
import 'community_detail_screen.dart';

class DiscoverCommunitiesScreen extends StatefulWidget {
  const DiscoverCommunitiesScreen({super.key});

  @override
  State<DiscoverCommunitiesScreen> createState() => _DiscoverCommunitiesScreenState();
}

class _DiscoverCommunitiesScreenState extends State<DiscoverCommunitiesScreen> {
  late final DiscoverViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DiscoverViewModel(context.read<CommunityProvider>());
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (_viewModel.showFilters) _buildFilters(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Text(
              'Discover Communities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.slider_horizontal_3,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => setState(() => _viewModel.toggleFilters()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CommunitySearchBar(
        onChanged: (value) {
          setState(() => _viewModel.updateSearchQuery(value));
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CommunityFilters(
        selectedCategory: _viewModel.selectedCategory,
        selectedDifficulty: _viewModel.selectedDifficulty,
        onCategoryChanged: (value) {
          setState(() => _viewModel.updateCategory(value));
        },
        onDifficultyChanged: (value) {
          setState(() => _viewModel.updateDifficulty(value));
        },
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (!_viewModel.isInitialized || provider.isLoading) {
          return const LoadingState(message: 'Loading communities...');
        }

        if (provider.error != null) {
          return ErrorState(
            message: 'Error loading communities',
            onRetry: _viewModel.reload,
          );
        }

        final communities = _viewModel.getCommunities(provider);

        if (communities.isEmpty) {
          return EmptyState(
            icon: CupertinoIcons.search,
            title: 'No communities found',
            subtitle: _viewModel.hasActiveFilters
                ? 'Try adjusting your filters'
                : 'Be the first to create one!',
          );
        }

        return _buildCommunityList(communities);
      },
    );
  }

  Widget _buildCommunityList(List<CommunityHabit> communities) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final community = communities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CommunityCard(
            id: community.id,
            name: community.name,
            icon: community.habitTemplate?.icon ?? 'flag',
            iconColor: community.habitTemplate?.color,
            memberCount: community.memberCount,
            averageStreak: community.averageStreak.toInt(),
            description: community.description,
            category: community.category ?? 'general',
            difficulty: community.difficulty ?? 'medium',
            tags: [],
            onTap: () => _navigateToCommunityDetail(community),
          ),
        );
      },
    );
  }

  void _navigateToCommunityDetail(CommunityHabit community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityDetailScreen(
          communityId: community.id,
          communityName: community.name,
        ),
      ),
    );
  }
}