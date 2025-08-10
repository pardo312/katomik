import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/community_provider.dart';
import '../../../../data/services/community_service.dart';
import '../widgets/community_card.dart';
import '../widgets/community_search_bar.dart';
import '../widgets/community_filters.dart';
import '../../../../shared/widgets/states/loading_state.dart';
import '../../../../shared/widgets/states/error_state.dart';
import '../../../../shared/widgets/states/empty_state.dart';
import '../providers/discover_view_model.dart';
import 'community_detail_screen.dart';
import '../../../../l10n/app_localizations.dart';

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
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
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
              AppLocalizations.of(context).discoverCommunities,
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
            onPressed: () => _viewModel.toggleFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CommunitySearchBar(
        onChanged: (value) => _viewModel.updateSearchQuery(value),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CommunityFilters(
        selectedCategory: _viewModel.selectedCategory,
        selectedDifficulty: _viewModel.selectedDifficulty,
        onCategoryChanged: (value) => _viewModel.updateCategory(value),
        onDifficultyChanged: (value) => _viewModel.updateDifficulty(value),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (!_viewModel.isInitialized || provider.isLoading) {
          return LoadingState(message: AppLocalizations.of(context).loadingCommunities);
        }

        if (provider.error != null) {
          return ErrorState(
            message: AppLocalizations.of(context).errorLoadingCommunities,
            onRetry: _viewModel.reload,
          );
        }

        final communities = _viewModel.getCommunities(provider);

        if (communities.isEmpty) {
          return EmptyState(
            icon: CupertinoIcons.search,
            title: AppLocalizations.of(context).noCommunitiesFound,
            subtitle: _viewModel.hasActiveFilters
                ? AppLocalizations.of(context).tryAdjustingFilters
                : AppLocalizations.of(context).beFirstToCreateOne,
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