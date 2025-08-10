import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:katomik/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/platform_messages.dart';
import '../../../../data/services/community_service.dart';

class MakeHabitPublicDialog extends StatefulWidget {
  final String habitName;
  final Function(CommunitySettings) onMakePublic;

  const MakeHabitPublicDialog({
    super.key,
    required this.habitName,
    required this.onMakePublic,
  });

  @override
  State<MakeHabitPublicDialog> createState() => _MakeHabitPublicDialogState();
}

class _MakeHabitPublicDialogState extends State<MakeHabitPublicDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  String _selectedDifficulty = 'MEDIUM';
  final List<String> _tags = [];
  int _descriptionLength = 0;

  final List<String> _categories = ['health', 'productivity', 'learning', 'fitness', 'mindfulness', 'creativity'];
  
  String _getCategoryDisplayName(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case 'health':
        return l10n.health;
      case 'productivity':
        return l10n.productivity;
      case 'learning':
        return l10n.learning;
      case 'fitness':
        return l10n.fitness;
      case 'mindfulness':
        return l10n.mindfulness;
      case 'creativity':
        return l10n.creativity;
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCategoryPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: CupertinoPicker(
          itemExtent: 32,
          onSelectedItemChanged: (index) {
            setState(() {
              _selectedCategory = _categories[index];
            });
          },
          children: _categories
              .map((category) => Center(
                    child: Text(
                      _getCategoryDisplayName(context, category),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Platform.isIOS 
            ? CupertinoTheme.of(context).barBackgroundColor 
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.globe,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).makeHabitPublic,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.habitName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
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
                    CupertinoIcons.exclamationmark_triangle,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).onceYourHabitHasFiveMembers,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              AppLocalizations.of(context).communitySettings,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).descriptionLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Platform.isIOS
                      ? CupertinoTextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          placeholder: AppLocalizations.of(context).describeHabitCommunityGoals,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      : TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).describeHabitCommunityGoals,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).charactersRequired(10, 500),
                      style: TextStyle(
                        fontSize: 12,
                        color: _descriptionLength >= 10 && _descriptionLength <= 500
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Colors.red,
                      ),
                    ),
                    Text(
                      '$_descriptionLength/500',
                      style: TextStyle(
                        fontSize: 12,
                        color: _descriptionLength > 500
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Category
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).categoryLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Platform.isIOS
                      ? GestureDetector(
                          onTap: () => _showCategoryPicker(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CupertinoColors.systemGrey4,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedCategory != null
                                      ? _getCategoryDisplayName(context, _selectedCategory!)
                                      : AppLocalizations.of(context).selectCategory,
                                  style: TextStyle(
                                    color: _selectedCategory != null
                                        ? CupertinoColors.label
                                        : CupertinoColors.placeholderText,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  size: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ],
                            ),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: Text(AppLocalizations.of(context).selectCategory),
                          items: _categories
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(_getCategoryDisplayName(context, category)),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value),
                        ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Difficulty
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).difficultyLevel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Platform.isIOS
                      ? CupertinoSegmentedControl<String>(
                          groupValue: _selectedDifficulty,
                          onValueChanged: (String? value) {
                            if (value != null) {
                              setState(() => _selectedDifficulty = value);
                            }
                          },
                          children: {
                            'EASY': Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(AppLocalizations.of(context).easy),
                            ),
                            'MEDIUM': Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(AppLocalizations.of(context).medium),
                            ),
                            'HARD': Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(AppLocalizations.of(context).hard),
                            ),
                          },
                        )
                      : SegmentedButton<String>(
                          selected: {_selectedDifficulty},
                          onSelectionChanged: (Set<String> selection) {
                            setState(() => _selectedDifficulty = selection.first);
                          },
                          segments: [
                            ButtonSegment(
                              value: 'EASY',
                              label: Text(AppLocalizations.of(context).easy),
                            ),
                            ButtonSegment(
                              value: 'MEDIUM',
                              label: Text(AppLocalizations.of(context).medium),
                            ),
                            ButtonSegment(
                              value: 'HARD',
                              label: Text(AppLocalizations.of(context).hard),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final description = _descriptionController.text.trim();
                      if (description.isEmpty) {
                        PlatformMessages.showError(
                          context,
                          AppLocalizations.of(context).pleaseProvideDescription,
                        );
                        return;
                      }
                      if (description.length < 10) {
                        PlatformMessages.showError(
                          context,
                          AppLocalizations.of(context).descriptionMustBeAtLeast,
                        );
                        return;
                      }
                      if (description.length > 500) {
                        PlatformMessages.showError(
                          context,
                          AppLocalizations.of(context).descriptionMustBeOrLess,
                        );
                        return;
                      }
                      widget.onMakePublic(
                        CommunitySettings(
                          description: description,
                          category: _selectedCategory,
                          difficultyLevel: _selectedDifficulty,
                          tags: _tags,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).makeHabitPublic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Wrap with Material for Android to support Material widgets
    if (Platform.isAndroid) {
      return Material(
        type: MaterialType.transparency,
        child: content,
      );
    }
    
    return content;
  }
}