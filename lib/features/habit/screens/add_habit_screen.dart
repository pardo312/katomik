import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/shared/widgets/adaptive_widgets.dart';
import 'package:katomik/features/habit/widgets/habit_icon.dart';
import 'dart:io';

class AddHabitScreen extends StatefulWidget {
  final Habit? habitToEdit;
  
  const AddHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<TextEditingController> _phraseControllers = [];
  
  Color _selectedColor = Colors.blue;
  String _selectedIcon = 'science';
  
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      _nameController.text = widget.habitToEdit!.name;
      // Initialize phrase controllers with existing phrases
      for (final phrase in widget.habitToEdit!.phrases) {
        final controller = TextEditingController(text: phrase);
        _phraseControllers.add(controller);
      }
      // Add one empty controller if no phrases exist
      if (_phraseControllers.isEmpty) {
        _phraseControllers.add(TextEditingController());
      }
      _selectedColor = Color(int.parse(widget.habitToEdit!.color));
      _selectedIcon = widget.habitToEdit!.icon;
    } else {
      // Add one empty controller for new habits
      _phraseControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _phraseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveHabit() {
    if (Platform.isIOS || (_formKey.currentState?.validate() ?? false)) {
      final phrases = _phraseControllers
          .map((controller) => controller.text.trim())
          .where((phrase) => phrase.isNotEmpty)
          .toList();
      
      if (_nameController.text.trim().isEmpty || phrases.isEmpty) {
        if (Platform.isIOS) {
          AdaptiveDialog.show(
            context: context,
            title: 'Missing Information',
            content: const Text('Please provide a habit name and at least one phrase.'),
            actions: [
              AdaptiveDialogAction(
                text: 'OK',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
          return;
        }
      }
      
      final habit = Habit(
        id: widget.habitToEdit?.id,
        name: _nameController.text.trim(),
        phrases: phrases,
        createdDate: widget.habitToEdit?.createdDate ?? DateTime.now(),
        color: '0x${((_selectedColor.a * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((_selectedColor.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((_selectedColor.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((_selectedColor.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
        icon: _selectedIcon,
        isActive: true,
      );

      final provider = Provider.of<HabitProvider>(context, listen: false);
      
      if (widget.habitToEdit != null) {
        provider.updateHabit(habit);
      } else {
        provider.addHabit(habit);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitToEdit != null;
    
    return AdaptiveScaffold(
      title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
      actions: Platform.isIOS
          ? [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveHabit,
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ]
          : null,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdaptiveTextField(
              controller: _nameController,
              label: 'Habit Name',
              placeholder: 'e.g., Drink Water, Exercise, Read',
              prefix: Icon(
                Platform.isIOS ? CupertinoIcons.pencil : Icons.edit,
                size: 20,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _buildPhrasesSection(),
            const SizedBox(height: 24),
            Text(
              'Choose a Color',
              style: Platform.isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    )
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
                      border: isSelected
                          ? Border.all(
                              color: Platform.isIOS
                                  ? CupertinoColors.activeBlue
                                  : Theme.of(context).colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Platform.isIOS ? CupertinoIcons.checkmark : Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose an Icon',
              style: Platform.isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    )
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: HabitIcon.availableIcons.length,
                itemBuilder: (context, index) {
                  final iconName = HabitIcon.availableIcons[index];
                  final isSelected = _selectedIcon == iconName;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconName;
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.2)
                              : Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: HabitIcon(
                            iconName: iconName,
                            size: 28,
                            color: isSelected
                                ? _selectedColor
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            if (!Platform.isIOS)
              Row(
                children: [
                  Expanded(
                    child: AdaptiveButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AdaptiveButton(
                      text: isEditing ? 'Update' : 'Create',
                      onPressed: _saveHabit,
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhrasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Why do you want to build this habit?',
              style: Platform.isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    )
                  : Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: Icon(
                Platform.isIOS ? CupertinoIcons.add : Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _phraseControllers.add(TextEditingController());
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add phrases that motivate you',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ..._phraseControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: AdaptiveTextField(
                    controller: controller,
                    label: 'Phrase ${index + 1}',
                    placeholder: 'Enter a motivating phrase',
                    prefix: Icon(
                      Platform.isIOS ? CupertinoIcons.quote_bubble : Icons.format_quote,
                      size: 20,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_phraseControllers.length > 1)
                  IconButton(
                    icon: Icon(
                      Platform.isIOS ? CupertinoIcons.minus_circle : Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        controller.dispose();
                        _phraseControllers.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}