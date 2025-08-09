import 'package:flutter/material.dart';

class UsePagination<T> {
  final Future<List<T>> Function(int offset, int limit) fetchData;
  final int pageSize;
  
  final ValueNotifier<List<T>> items = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> hasMore = ValueNotifier(true);
  final ValueNotifier<String?> error = ValueNotifier(null);
  
  int _currentOffset = 0;

  UsePagination({
    required this.fetchData,
    this.pageSize = 20,
  });

  Future<void> loadInitial() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;
    _currentOffset = 0;

    try {
      final initialItems = await fetchData(0, pageSize);
      items.value = initialItems;
      hasMore.value = initialItems.length >= pageSize;
      _currentOffset = initialItems.length;
    } catch (e) {
      error.value = e.toString();
      items.value = [];
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      final moreItems = await fetchData(_currentOffset, pageSize);
      if (moreItems.isEmpty) {
        hasMore.value = false;
      } else {
        items.value = [...items.value, ...moreItems];
        _currentOffset += moreItems.length;
        hasMore.value = moreItems.length >= pageSize;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  void reset() {
    items.value = [];
    isLoading.value = false;
    hasMore.value = true;
    error.value = null;
    _currentOffset = 0;
  }

  void dispose() {
    items.dispose();
    isLoading.dispose();
    hasMore.dispose();
    error.dispose();
  }
}