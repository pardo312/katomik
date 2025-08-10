import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:katomik/shared/models/habit.dart';
import 'package:katomik/shared/providers/habit_provider.dart';
import 'package:katomik/shared/providers/community_provider.dart';
import 'habit_form_screen.dart';
import '../../../../shared/widgets/common/habit_icon.dart';
import 'package:katomik/features/community/presentation/widgets/make_habit_public_dialog.dart';
import 'package:katomik/features/community/presentation/screens/community_detail_screen.dart';
import 'package:katomik/shared/models/community_models.dart';
import '../providers/habit_detail_view_model.dart';
import '../widgets/habit_weekly_tracker.dart';
import '../widgets/habit_calendar.dart';
import '../widgets/habit_why_section.dart';
import 'dart:io';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen>
    with TickerProviderStateMixin {
  late HabitDetailViewModel _viewModel;
  late AnimationController _floatingAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
    _initializeAnimation();
    _initializeDateFormatting();
  }

  void _initializeViewModel() {
    _viewModel = HabitDetailViewModel(
      habitProvider: context.read<HabitProvider>(),
      communityProvider: context.read<CommunityProvider>(),
      habit: widget.habit,
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  void _initializeAnimation() {
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('es', null);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: body,
    );
  }

  Widget _buildContent() {
    return ListView(
      children: [
        _buildHabitInfo(),
        HabitWeeklyTracker(
          habit: _viewModel.habit,
          isDateCompleted: _viewModel.isDateCompleted,
          onCompletionToggled: () => _viewModel.refreshHabit(),
        ),
        HabitCalendar(
          focusedMonth: _viewModel.focusedMonth,
          habitColor: _viewModel.habitColor,
          isDateCompleted: _viewModel.isDateCompleted,
          onDateTap: _viewModel.toggleDateCompletion,
          onPreviousMonth: _viewModel.navigateToPreviousMonth,
          onNextMonth: _viewModel.navigateToNextMonth,
        ),
        HabitWhySection(
          habit: _viewModel.habit,
          floatingAnimationController: _floatingAnimationController,
          onAddContent: _navigateToEditHabit,
          communityPhrases: _viewModel.communityPhrases,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildCloseButton(),
          const Spacer(),
          if (_viewModel.canMakePublic) _buildMakePublicButton(),
          _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      icon: Icon(
        Platform.isIOS ? CupertinoIcons.xmark : Icons.close,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildMakePublicButton() {
    return IconButton(
      icon: Icon(
        Platform.isIOS ? CupertinoIcons.globe : Icons.public,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: _showMakePublicDialog,
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      icon: Icon(
        Platform.isIOS ? CupertinoIcons.pencil : Icons.edit,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: _navigateToEditHabit,
    );
  }

  Widget _buildHabitInfo() {
    final color = _viewModel.habitColor;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          _buildHabitIcon(color),
          const SizedBox(height: 16),
          _buildHabitName(),
        ],
      ),
    );
  }

  Widget _buildHabitIcon(Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: HabitIcon(
          iconName: _viewModel.habit.icon,
          size: 40,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHabitName() {
    return Column(
      children: [
        Text(
          _viewModel.habit.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        if (_viewModel.habit.communityId != null) ...[
          const SizedBox(height: 8),
          _buildCommunityBadge(),
        ],
      ],
    );
  }

  Widget _buildCommunityBadge() {
    return GestureDetector(
      onTap: _navigateToCommunity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Platform.isIOS ? CupertinoIcons.person_2_fill : Icons.people,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              _viewModel.habit.communityName ?? 'Community',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCommunity() {
    if (_viewModel.habit.communityId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityDetailScreen(
            communityId: _viewModel.habit.communityId!,
            communityName:
                _viewModel.habit.communityName ?? _viewModel.habit.name,
          ),
        ),
      );
    }
  }

  Future<void> _navigateToEditHabit() async {
    final route = Platform.isIOS
        ? CupertinoPageRoute(
            builder: (_) => HabitFormScreen(habitToEdit: _viewModel.habit),
          )
        : MaterialPageRoute(
            builder: (_) => HabitFormScreen(habitToEdit: _viewModel.habit),
          );

    await Navigator.push(context, route);
    if (mounted) {
      await _viewModel.refreshHabit();
    }
  }

  void _showMakePublicDialog() {
    builder(BuildContext context) => MakeHabitPublicDialog(
      habitName: _viewModel.habit.name,
      onMakePublic: (settings) => _handleMakePublic(settings),
    );

    if (Platform.isIOS) {
      showCupertinoModalPopup(context: context, builder: builder);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: builder,
      );
    }
  }

  Future<void> _handleMakePublic(CommunitySettings settings) async {
    Navigator.pop(context);

    final result = await _viewModel.makeHabitPublic(settings);

    if (!mounted) return;

    if (result.success) {
      _showSuccessMessage(result);
    } else {
      _showErrorMessage(result.error ?? 'Failed to make habit public');
    }
  }

  void _showSuccessMessage(MakePublicResult result) {
    _showPlatformSnackBar(
      '${_viewModel.habit.name} is now public!',
      backgroundColor: Colors.green,
      actionLabel: 'View Community',
      onActionPressed: () {
        if (result.communityId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityDetailScreen(
                communityId: result.communityId!,
                communityName: result.communityName!,
              ),
            ),
          );
        }
      },
    );
  }

  void _showErrorMessage(String message) {
    _showPlatformSnackBar(message, backgroundColor: Colors.red);
  }

  void _showPlatformSnackBar(
    String message, {
    Color? backgroundColor,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    if (Platform.isIOS) {
      _showIOSAlert(message, actionLabel, onActionPressed);
    } else {
      _showAndroidSnackBar(
        message,
        backgroundColor,
        actionLabel,
        onActionPressed,
      );
    }
  }

  void _showIOSAlert(
    String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          if (onActionPressed != null && actionLabel != null)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                onActionPressed();
              },
              child: Text(actionLabel),
            ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAndroidSnackBar(
    String message,
    Color? backgroundColor,
    String? actionLabel,
    VoidCallback? onActionPressed,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }
}
