import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/models/habit.dart';
import '../../../../shared/providers/habit_provider.dart';

class AddHabitViewModel extends ChangeNotifier {
  final HabitProvider _habitProvider;
  final Habit? habitToEdit;
  
  final TextEditingController nameController = TextEditingController();
  final List<TextEditingController> phraseControllers = [];
  final List<String> imagePaths = [];
  final ImagePicker _picker = ImagePicker();
  
  Color _selectedColor = Colors.blue;
  String _selectedIcon = 'science';
  bool _isLoading = false;
  String? _error;
  
  AddHabitViewModel({
    required HabitProvider habitProvider,
    this.habitToEdit,
  }) : _habitProvider = habitProvider {
    _initializeForEdit();
  }
  
  Color get selectedColor => _selectedColor;
  String get selectedIcon => _selectedIcon;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEditing => habitToEdit != null;
  
  bool get isValid {
    final hasName = nameController.text.trim().isNotEmpty;
    final hasPhrases = phraseControllers.any(
      (controller) => controller.text.trim().isNotEmpty,
    );
    return hasName && hasPhrases;
  }
  
  void _initializeForEdit() {
    if (habitToEdit == null) {
      phraseControllers.add(TextEditingController());
      return;
    }
    
    nameController.text = habitToEdit!.name;
    
    for (final phrase in habitToEdit!.phrases) {
      final controller = TextEditingController(text: phrase);
      phraseControllers.add(controller);
    }
    
    if (phraseControllers.isEmpty) {
      phraseControllers.add(TextEditingController());
    }
    
    imagePaths.addAll(habitToEdit!.images);
    _selectedColor = _parseColor(habitToEdit!.color);
    _selectedIcon = habitToEdit!.icon;
  }
  
  Color _parseColor(String colorStr) {
    if (colorStr.startsWith('#')) {
      final hex = colorStr.substring(1);
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Color(int.parse(colorStr));
  }
  
  void updateSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }
  
  void updateSelectedIcon(String icon) {
    _selectedIcon = icon;
    notifyListeners();
  }
  
  void addPhraseField() {
    phraseControllers.add(TextEditingController());
    notifyListeners();
  }
  
  void removePhraseField(int index) {
    if (phraseControllers.length > 1) {
      phraseControllers[index].dispose();
      phraseControllers.removeAt(index);
      notifyListeners();
    }
  }
  
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        imagePaths.add(image.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pick image: $e';
      notifyListeners();
    }
  }
  
  void removeImage(int index) {
    imagePaths.removeAt(index);
    notifyListeners();
  }
  
  Future<bool> saveHabit() async {
    if (!isValid) {
      _error = 'Please provide a habit name and at least one phrase';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final phrases = phraseControllers
          .map((controller) => controller.text.trim())
          .where((phrase) => phrase.isNotEmpty)
          .toList();
      
      final colorHex = _colorToHex(_selectedColor);
      
      final habit = Habit(
        id: habitToEdit?.id,
        name: nameController.text.trim(),
        phrases: phrases,
        images: imagePaths,
        createdDate: habitToEdit?.createdDate ?? DateTime.now(),
        color: colorHex,
        icon: _selectedIcon,
        isActive: true,
        communityId: habitToEdit?.communityId,
        communityName: habitToEdit?.communityName,
      );
      
      if (isEditing) {
        _habitProvider.updateHabit(habit);
      } else {
        _habitProvider.addHabit(habit);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save habit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    nameController.dispose();
    for (final controller in phraseControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}