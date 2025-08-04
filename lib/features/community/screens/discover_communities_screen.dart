import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/community_provider.dart';
import '../../../data/services/community_service.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/community_card.dart';
import '../widgets/community_search_bar.dart';
import '../widgets/community_filters.dart';
import 'community_detail_screen.dart';

class DiscoverCommunitiesScreen extends StatefulWidget {
  const DiscoverCommunitiesScreen({super.key});

  @override
  State<DiscoverCommunitiesScreen> createState() => _DiscoverCommunitiesScreenState();
}

class _DiscoverCommunitiesScreenState extends State<DiscoverCommunitiesScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedDifficulty;
  bool _showFilters = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommunities();
    });
  }

  Future<void> _loadCommunities() async {
    final provider = context.read<CommunityProvider>();
    await provider.loadPopularCommunities();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _performSearch() async {
    final provider = context.read<CommunityProvider>();
    await provider.searchCommunities(
      searchTerm: _searchQuery.isEmpty ? null : _searchQuery,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
    );
  }

  List<CommunityHabit> _getCommunities(CommunityProvider provider) {
    if (_searchQuery.isNotEmpty || _selectedCategory != null || _selectedDifficulty != null) {
      return provider.searchResults;
    }
    return provider.popularCommunities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const SizedBox(width: 48), // Spacer to balance the layout
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
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CommunitySearchBar(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _performSearch();
                },
              ),
            ),

            // Filters
            if (_showFilters)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CommunityFilters(
                  selectedCategory: _selectedCategory,
                  selectedDifficulty: _selectedDifficulty,
                  onCategoryChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    _performSearch();
                  },
                  onDifficultyChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                    _performSearch();
                  },
                ),
              ),

            // Communities List
            Expanded(
              child: Consumer<CommunityProvider>(
                builder: (context, provider, child) {
                  if (!_isInitialized || provider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
                          Text(
                            'Error loading communities',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _loadCommunities,
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final communities = _getCommunities(provider);

                  if (communities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No communities found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: communities.length,
                    itemBuilder: (context, index) {
                      final community = communities[index];
                      final template = community.habitTemplate;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: CommunityCard(
                          id: community.id,
                          name: community.name,
                          icon: template?.icon ?? 'flag',
                          iconColor: template?.color,
                          memberCount: community.memberCount,
                          averageStreak: community.averageStreak.toInt(),
                          description: community.description,
                          category: community.category ?? 'general',
                          difficulty: community.difficulty ?? 'medium',
                          tags: [], // Tags not in GraphQL schema yet
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommunityDetailScreen(
                                  communityId: community.id,
                                  communityName: community.name,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}