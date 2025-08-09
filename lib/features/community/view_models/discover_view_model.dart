import 'package:flutter/foundation.dart';
import '../../../providers/community_provider.dart';
import '../../../data/services/community_service.dart';

class DiscoverViewModel extends ChangeNotifier {
  final CommunityProvider _provider;

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedDifficulty;
  bool _showFilters = false;
  bool _isInitialized = false;

  DiscoverViewModel(this._provider);

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedDifficulty => _selectedDifficulty;
  bool get showFilters => _showFilters;
  bool get isInitialized => _isInitialized;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != null ||
      _selectedDifficulty != null;

  Future<void> initialize() async {
    await _provider.loadPopularCommunities();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _isInitialized = false;
    notifyListeners();
    await initialize();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _performSearch();
  }

  void updateCategory(String? category) {
    _selectedCategory = category;
    _performSearch();
  }

  void updateDifficulty(String? difficulty) {
    _selectedDifficulty = difficulty;
    _performSearch();
  }

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  Future<void> _performSearch() async {
    await _provider.searchCommunities(
      searchTerm: _searchQuery.isEmpty ? null : _searchQuery,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
    );
  }

  List<CommunityHabit> getCommunities(CommunityProvider provider) {
    if (hasActiveFilters) {
      return provider.searchResults;
    }
    return provider.popularCommunities;
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedDifficulty = null;
    _performSearch();
  }
}
