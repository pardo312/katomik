import '../constants/community_constants.dart';

class CommunityValidators {
  static void validateId(String id, String fieldName) {
    if (id.isEmpty) {
      throw ArgumentError('$fieldName cannot be empty');
    }
  }

  static void validatePagination(int limit, int offset) {
    validateLimit(limit);
    validateOffset(offset);
  }

  static void validateLimit(int limit) {
    if (limit < 1 || limit > CommunityConstants.maxSearchLimit) {
      throw ArgumentError(
        'Limit must be between 1 and ${CommunityConstants.maxSearchLimit}'
      );
    }
  }

  static void validateOffset(int offset) {
    if (offset < 0) {
      throw ArgumentError('Offset must be non-negative');
    }
  }

  static void validateCategory(String? category) {
    if (category == null) return;
    
    if (!CommunityCategories.all.contains(category.toLowerCase())) {
      throw ArgumentError('Invalid category: $category');
    }
  }

  static void validateDifficulty(String? difficulty) {
    if (difficulty == null) return;
    
    if (!DifficultyLevels.all.contains(difficulty.toLowerCase())) {
      throw ArgumentError('Invalid difficulty level: $difficulty');
    }
  }

  static void validateTimeframe(String timeframe) {
    if (!Timeframes.all.contains(timeframe)) {
      throw ArgumentError('Invalid timeframe: $timeframe');
    }
  }

  static void validateTitle(String title, {int? maxLength}) {
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    
    final limit = maxLength ?? CommunityConstants.maxTitleLength;
    if (title.length > limit) {
      throw ArgumentError('Title must be $limit characters or less');
    }
  }

  static void validateDescription(String description, {int? maxLength}) {
    if (description.isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }
    
    final limit = maxLength ?? CommunityConstants.maxDescriptionLength;
    if (description.length > limit) {
      throw ArgumentError('Description must be $limit characters or less');
    }
  }

  static void validateTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) return;
    
    if (tags.length > 10) {
      throw ArgumentError('Maximum 10 tags allowed');
    }
    
    for (final tag in tags) {
      if (tag.isEmpty || tag.length > 20) {
        throw ArgumentError('Tags must be between 1 and 20 characters');
      }
    }
  }
}