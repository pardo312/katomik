import '../../models/community_models.dart';
import 'mutations.dart';
import 'base_service.dart';
import 'error_handler.dart';

class CommunityPublishingService extends BaseCommunityService {
  Future<CommunityHabit> makeHabitPublic(
    String habitId,
    CommunitySettings settings,
  ) async {
    _validatePublishingInput(habitId, settings);
    
    return executeMutation(
      mutationDocument: CommunityMutations.makeHabitPublic,
      variables: {
        'habitId': habitId,
        'settings': settings.toJson(),
      },
      dataExtractor: (data) {
        final result = data['makeHabitPublic'];
        if (result == null) {
          throw CommunityServiceException(
            'Failed to make habit public - no data returned',
            type: CommunityErrorType.unknown,
          );
        }
        return CommunityHabit.fromJson(result);
      },
      operationName: 'makeHabitPublic',
    );
  }

  void _validatePublishingInput(String habitId, CommunitySettings settings) {
    if (habitId.isEmpty) {
      throw ArgumentError('Habit ID cannot be empty');
    }
    
    if (settings.description == null || settings.description!.isEmpty) {
      throw ArgumentError('Community description is required');
    }
    
    if (settings.category == null || settings.category!.isEmpty) {
      throw ArgumentError('Category is required');
    }
    
    _validateCategory(settings.category!);
    
    if (settings.difficultyLevel != null) {
      _validateDifficulty(settings.difficultyLevel!);
    }
  }

  void _validateCategory(String category) {
    const validCategories = [
      'health',
      'fitness',
      'productivity',
      'learning',
      'mindfulness',
      'creativity',
      'social',
      'finance',
      'other'
    ];
    
    if (!validCategories.contains(category.toLowerCase())) {
      throw ArgumentError('Invalid category: $category');
    }
  }

  void _validateDifficulty(String difficulty) {
    const validDifficulties = ['easy', 'medium', 'hard'];
    
    if (!validDifficulties.contains(difficulty.toLowerCase())) {
      throw ArgumentError('Invalid difficulty level: $difficulty');
    }
  }
}