import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/adaptive_widgets.dart';
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
  final _descriptionController = TextEditingController();
  
  Color _selectedColor = Colors.blue;
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
      _descriptionController.text = widget.habitToEdit!.description;
      _selectedColor = Color(int.parse(widget.habitToEdit!.color));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (Platform.isIOS || (_formKey.currentState?.validate() ?? false)) {
      if (_nameController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
        if (Platform.isIOS) {
          AdaptiveDialog.show(
            context: context,
            title: 'Missing Information',
            content: const Text('Please fill in all fields to create a habit.'),
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
        description: _descriptionController.text.trim(),
        createdDate: widget.habitToEdit?.createdDate ?? DateTime.now(),
        color: '0x${((_selectedColor.a * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((_selectedColor.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((_selectedColor.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((_selectedColor.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
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
            AdaptiveTextField(
              controller: _descriptionController,
              label: 'Description',
              placeholder: 'Why do you want to build this habit?',
              prefix: Icon(
                Platform.isIOS ? CupertinoIcons.doc_text : Icons.description,
                size: 20,
              ),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
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
}