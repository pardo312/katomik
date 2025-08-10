import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../shared/models/habit.dart';
import '../../../../shared/providers/habit_provider.dart';
import '../../../../shared/widgets/common/adaptive_widgets.dart';
import '../widgets/color_picker.dart';
import '../widgets/icon_picker.dart';
import '../widgets/phrases_section.dart';
import '../widgets/images_section.dart';
import '../providers/habit_form_view_model.dart';
import 'dart:io';
import '../../../../core/utils/platform_messages.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../l10n/app_localizations.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habitToEdit;

  const HabitFormScreen({super.key, this.habitToEdit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final HabitFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HabitFormViewModel(
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
        title: AppLocalizations.of(context).missingInformation,
        content: Text(
          AppLocalizations.of(context).provideHabitNameAndPhrase,
        ),
        actions: [
          AdaptiveDialogAction(
            text: AppLocalizations.of(context).ok,
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
          title: Text(AppLocalizations.of(context).error),
          content: Text(error),
          actions: [
            CupertinoDialogAction(
              child: Text(AppLocalizations.of(context).ok),
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
      title: Text(_viewModel.isEditing ? AppLocalizations.of(context).editHabit : AppLocalizations.of(context).newHabit),
      actions: Platform.isIOS
          ? [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveHabit,
                child: Text(
                  AppLocalizations.of(context).save,
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
              label: AppLocalizations.of(context).habitName,
              placeholder: AppLocalizations.of(context).habitNamePlaceholder,
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
                      text: AppLocalizations.of(context).cancel,
                      onPressed: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AdaptiveButton(
                      text: _viewModel.isEditing ? AppLocalizations.of(context).update : AppLocalizations.of(context).create,
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
