import 'package:flutter/material.dart';
import 'package:katomik/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';

class CommunityFilters extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedDifficulty;
  final Function(String?) onCategoryChanged;
  final Function(String?) onDifficultyChanged;

  const CommunityFilters({
    super.key,
    this.selectedCategory,
    this.selectedDifficulty,
    required this.onCategoryChanged,
    required this.onDifficultyChanged,
  });

  static List<Map<String, dynamic>> getCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'value': null, 'label': l10n.all},
      {'value': 'wellness', 'label': 'Wellness'},
      {'value': 'fitness', 'label': 'Fitness'},
      {'value': 'education', 'label': 'Education'},
      {'value': 'productivity', 'label': 'Productivity'},
      {'value': 'health', 'label': 'Health'},
      {'value': 'creative', 'label': 'Creative'},
    ];
  }

  static List<Map<String, dynamic>> getDifficulties(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'value': null, 'label': l10n.all},
      {'value': 'easy', 'label': l10n.easy},
      {'value': 'medium', 'label': l10n.medium},
      {'value': 'hard', 'label': l10n.hard},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories
        Text(
          'Category',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: getCategories(context).map((category) {
              final isSelected = selectedCategory == category['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category['label']!),
                  selected: isSelected,
                  onSelected: (_) => onCategoryChanged(category['value']),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Difficulty
        Text(
          AppLocalizations.of(context).difficulty,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: getDifficulties(context).map((difficulty) {
            final isSelected = selectedDifficulty == difficulty['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(difficulty['label']!),
                selected: isSelected,
                onSelected: (_) => onDifficultyChanged(difficulty['value']),
                selectedColor: _getDifficultyColor(
                  difficulty['value'],
                ).withValues(alpha: 0.2),
                checkmarkColor: _getDifficultyColor(difficulty['value']),
                labelStyle: TextStyle(
                  color: isSelected
                      ? _getDifficultyColor(difficulty['value'])
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: isSelected
                      ? _getDifficultyColor(difficulty['value'])
                      : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}
