import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/shared/widgets/adaptive_widgets.dart';
import 'package:katomik/features/habit/add_habit/widgets/color_picker.dart';
import 'package:katomik/features/habit/add_habit/widgets/icon_picker.dart';
import 'package:katomik/features/habit/add_habit/widgets/phrases_section.dart';
import 'package:katomik/features/habit/add_habit/widgets/images_section.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:katomik/core/utils/platform_messages.dart';

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
  final List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  Color _selectedColor = Colors.blue;
  String _selectedIcon = 'science';

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
      // Initialize images
      _imagePaths.addAll(widget.habitToEdit!.images);
      // Parse color from either #RRGGBB or 0xAARRGGBB format
      final colorStr = widget.habitToEdit!.color;
      if (colorStr.startsWith('#')) {
        // Handle #RRGGBB format
        final hex = colorStr.substring(1);
        _selectedColor = Color(int.parse('FF$hex', radix: 16));
      } else {
        // Handle 0xAARRGGBB format (legacy)
        _selectedColor = Color(int.parse(colorStr));
      }
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
            content: const Text(
              'Please provide a habit name and at least one phrase.',
            ),
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
        images: _imagePaths,
        createdDate: widget.habitToEdit?.createdDate ?? DateTime.now(),
        color:
            '#${((_selectedColor.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((_selectedColor.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((_selectedColor.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}'
                .toUpperCase(),
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
            PhrasesSection(
              phraseControllers: _phraseControllers,
              onAddPhrase: () {
                setState(() {
                  _phraseControllers.add(TextEditingController());
                });
              },
              onRemovePhrase: (index) {
                setState(() {
                  _phraseControllers[index].dispose();
                  _phraseControllers.removeAt(index);
                });
              },
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 24),
            ImagesSection(
              imagePaths: _imagePaths,
              onAddImage: _pickImage,
              onRemoveImage: (index) {
                setState(() {
                  _imagePaths.removeAt(index);
                });
              },
            ),
            const SizedBox(height: 24),
            ColorPicker(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 24),
            IconPicker(
              selectedIcon: _selectedIcon,
              selectedColor: _selectedColor,
              onIconSelected: (icon) {
                setState(() {
                  _selectedIcon = icon;
                });
              },
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

  Future<void> _pickImage() async {
    ImagePickerHelper.showImagePicker(
      context: context,
      onSourceSelected: _getImage,
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePaths.add(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      if (Platform.isIOS) {
        if (!mounted) return;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to pick image: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        PlatformMessages.showError(context, 'Failed to pick image: $e');
      }
    }
  }
}
