import 'package:flutter/material.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../data/models/community_models.dart';

class UseCommunitySearch {
  final ICommunityRepository _repository;
  final ValueNotifier<List<CommunityHabit>> results = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);
  
  String? _lastSearchTerm;
  String? _lastCategory;
  String? _lastDifficulty;

  UseCommunitySearch(this._repository);

  Future<void> search({
    String? searchTerm,
    String? category,
    String? difficulty,
    int limit = 20,
    int offset = 0,
  }) async {
    if (_isSameSearch(searchTerm, category, difficulty)) {
      return;
    }

    _lastSearchTerm = searchTerm;
    _lastCategory = category;
    _lastDifficulty = difficulty;

    isLoading.value = true;
    error.value = null;

    try {
      final searchResults = await _repository.searchCommunities(
        searchTerm: searchTerm,
        category: category,
        difficulty: difficulty,
        limit: limit,
        offset: offset,
      );
      results.value = searchResults;
    } catch (e) {
      error.value = e.toString();
      results.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore({
    int limit = 20,
  }) async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      final moreResults = await _repository.searchCommunities(
        searchTerm: _lastSearchTerm,
        category: _lastCategory,
        difficulty: _lastDifficulty,
        limit: limit,
        offset: results.value.length,
      );
      results.value = [...results.value, ...moreResults];
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    results.value = [];
    isLoading.value = false;
    error.value = null;
    _lastSearchTerm = null;
    _lastCategory = null;
    _lastDifficulty = null;
  }

  bool _isSameSearch(String? searchTerm, String? category, String? difficulty) {
    return searchTerm == _lastSearchTerm &&
           category == _lastCategory &&
           difficulty == _lastDifficulty;
  }

  void dispose() {
    results.dispose();
    isLoading.dispose();
    error.dispose();
  }
}