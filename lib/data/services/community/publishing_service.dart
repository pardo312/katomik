import 'package:flutter/widgets.dart';
import 'package:katomik/l10n/app_localizations.dart';
import '../../../shared/models/community_models.dart';
import 'mutations.dart';
import 'base_service.dart';
import 'error_handler.dart';

class CommunityPublishingService extends BaseCommunityService {
  Future<CommunityHabit> makeHabitPublic(
    String habitId,
    CommunitySettings settings,
    BuildContext? context,
  ) async {
    _validatePublishingInput(habitId, settings, context);
    
    return executeMutation(
      mutationDocument: CommunityMutations.makeHabitPublic,
      variables: {
        'habitId': habitId,
        'settings': settings.toJson(),
      },
      dataExtractor: (data) {
        final result = data['makeHabitPublic'];
        if (result == null) {
          final message = context != null 
              ? AppLocalizations.of(context).failedToMakePublic
              : 'Failed to make habit public - no data returned';
          throw CommunityServiceException(
            message,
            type: CommunityErrorType.unknown,
          );
        }
        return CommunityHabit.fromJson(result);
      },
      operationName: 'makeHabitPublic',
    );
  }

  void _validatePublishingInput(String habitId, CommunitySettings settings, BuildContext? context) {
    if (habitId.isEmpty) {
      final message = context != null 
          ? AppLocalizations.of(context).habitIdRequired
          : 'Habit ID cannot be empty';
      throw ArgumentError(message);
    }
    
    if (settings.description == null || settings.description!.isEmpty) {
      final message = context != null 
          ? AppLocalizations.of(context).descriptionRequired
          : 'Community description is required';
      throw ArgumentError(message);
    }
    
    if (settings.category == null || settings.category!.isEmpty) {
      final message = context != null 
          ? AppLocalizations.of(context).categoryRequired
          : 'Category is required';
      throw ArgumentError(message);
    }
    
    _validateCategory(settings.category!, context);
    
    if (settings.difficultyLevel != null) {
      _validateDifficulty(settings.difficultyLevel!, context);
    }
  }

  void _validateCategory(String category, BuildContext? context) {
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
      final message = context != null 
          ? AppLocalizations.of(context).invalidCategory(category)
          : 'Invalid category: $category';
      throw ArgumentError(message);
    }
  }

  void _validateDifficulty(String difficulty, BuildContext? context) {
    const validDifficulties = ['easy', 'medium', 'hard'];
    
    if (!validDifficulties.contains(difficulty.toLowerCase())) {
      final message = context != null 
          ? AppLocalizations.of(context).invalidDifficulty(difficulty)
          : 'Invalid difficulty level: $difficulty';
      throw ArgumentError(message);
    }
  }
}