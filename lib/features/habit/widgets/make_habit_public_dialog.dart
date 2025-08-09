import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';

class MakeHabitPublicDialog extends StatefulWidget {
  final String habitName;
  final Function(Map<String, dynamic>) onConfirm;

  const MakeHabitPublicDialog({
    super.key,
    required this.habitName,
    required this.onConfirm,
  });

  @override
  State<MakeHabitPublicDialog> createState() => _MakeHabitPublicDialogState();
}

class _MakeHabitPublicDialogState extends State<MakeHabitPublicDialog> {
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'wellness';
  String _selectedDifficulty = 'medium';
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'value': 'wellness', 'label': 'Wellness', 'icon': CupertinoIcons.heart_fill},
    {'value': 'fitness', 'label': 'Fitness', 'icon': CupertinoIcons.sportscourt_fill},
    {'value': 'education', 'label': 'Education', 'icon': CupertinoIcons.book_fill},
    {'value': 'productivity', 'label': 'Productivity', 'icon': CupertinoIcons.rocket_fill},
    {'value': 'health', 'label': 'Health', 'icon': CupertinoIcons.heart_circle_fill},
    {'value': 'creative', 'label': 'Creative', 'icon': CupertinoIcons.paintbrush_fill},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.globe,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Make "${widget.habitName}" Public',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_triangle_fill,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Once public, you\'ll lose exclusive control after 5 members join. Changes will require community votes.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe this habit to help others understand its purpose',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category['value'];
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category['icon'],
                                size: 16,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(category['label']!),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category['value']!;
                              });
                            }
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Difficulty
                    const Text(
                      'Difficulty Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDifficultyChip('easy', 'Easy', Colors.green),
                        const SizedBox(width: 8),
                        _buildDifficultyChip('medium', 'Medium', Colors.orange),
                        const SizedBox(width: 8),
                        _buildDifficultyChip('hard', 'Hard', Colors.red),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Tags
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: 'Add a tag',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty && !_tags.contains(value)) {
                                setState(() {
                                  _tags.add(value.toLowerCase());
                                  _tagController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            final value = _tagController.text;
                            if (value.isNotEmpty && !_tags.contains(value)) {
                              setState(() {
                                _tags.add(value.toLowerCase());
                                _tagController.clear();
                              });
                            }
                          },
                          icon: Icon(
                            CupertinoIcons.add_circled_solid,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _tags.map((tag) => Chip(
                          label: Text('#$tag'),
                          deleteIcon: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 18,
                          ),
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                          },
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: AppColors.primary,
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _descriptionController.text.isNotEmpty
                        ? () {
                            widget.onConfirm({
                              'description': _descriptionController.text,
                              'category': _selectedCategory,
                              'difficulty': _selectedDifficulty,
                              'tags': _tags,
                            });
                          }
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Make Public',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String value, String label, Color color) {
    final isSelected = _selectedDifficulty == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedDifficulty = value;
          });
        }
      },
      selectedColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey.shade300,
      ),
    );
  }
}