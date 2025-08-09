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
import '../view_models/add_habit_view_model.dart';
import 'dart:io';
import 'package:katomik/core/utils/platform_messages.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habitToEdit;

  const AddHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddHabitViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddHabitViewModel(
      habitProvider: context.read<HabitProvider>(),
      habitToEdit: widget.habitToEdit,
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_viewModel.isValid) {
      _showValidationError();
      return;
    }
    
    final success = await _viewModel.saveHabit();
    if (success && mounted) {
      Navigator.pop(context);
    } else if (_viewModel.error != null && mounted) {
      _showError(_viewModel.error!);
    }
  }
  
  void _showValidationError() {
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
    }
  }
  
  void _showError(String error) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      PlatformMessages.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: Text(_viewModel.isEditing ? 'Edit Habit' : 'New Habit'),
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
              controller: _viewModel.nameController,
              label: 'Habit Name',
              placeholder: 'e.g., Drink Water, Exercise, Read',
              prefix: Icon(
                Platform.isIOS ? CupertinoIcons.pencil : Icons.edit,
                size: 20,
              ),
              onChanged: (_) => _viewModel.clearError(),
            ),
            const SizedBox(height: 16),
            PhrasesSection(
              phraseControllers: _viewModel.phraseControllers,
              onAddPhrase: _viewModel.addPhraseField,
              onRemovePhrase: _viewModel.removePhraseField,
              onChanged: () => _viewModel.clearError(),
            ),
            const SizedBox(height: 24),
            ImagesSection(
              imagePaths: _viewModel.imagePaths,
              onAddImage: _pickImage,
              onRemoveImage: _viewModel.removeImage,
            ),
            const SizedBox(height: 24),
            ColorPicker(
              selectedColor: _viewModel.selectedColor,
              onColorSelected: _viewModel.updateSelectedColor,
            ),
            const SizedBox(height: 24),
            IconPicker(
              selectedIcon: _viewModel.selectedIcon,
              selectedColor: _viewModel.selectedColor,
              onIconSelected: _viewModel.updateSelectedIcon,
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
                      text: _viewModel.isEditing ? 'Update' : 'Create',
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
      onSourceSelected: (source) => _viewModel.pickImage(source),
    );
  }
}
