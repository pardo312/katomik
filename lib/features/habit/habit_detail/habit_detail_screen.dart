import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/providers/community_provider.dart';
import 'package:katomik/features/habit/add_habit/add_habit_screen.dart';
import 'package:katomik/features/habit/widgets/habit_icon.dart';
import 'package:katomik/features/community/widgets/make_habit_public_dialog.dart';
import 'package:katomik/features/community/screens/community_detail_screen.dart';
import '../view_models/habit_detail_view_model.dart';
import 'widgets/habit_weekly_tracker.dart';
import 'widgets/habit_calendar.dart';
import 'widgets/habit_why_section.dart';
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
    _viewModel = HabitDetailViewModel(
      habitProvider: context.read<HabitProvider>(),
      communityProvider: context.read<CommunityProvider>(),
      habit: widget.habit,
    );
    _viewModel.addListener(_onViewModelChanged);
    _initializeDateFormatting();

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

  void _showPlatformSnackBar(
    String message, {
    Color? backgroundColor,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    if (Platform.isIOS) {
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
    } else {
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

  void _showMakePublicDialog() {
    Widget buildMakePublicDialog(BuildContext context) {
      return MakeHabitPublicDialog(
        habitName: _viewModel.habit.name,
        onMakePublic: (settings) async {
          Navigator.pop(context);

          final result = await _viewModel.makeHabitPublic(settings);

          if (result.success && mounted) {
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
          } else if (!result.success && mounted) {
            _showPlatformSnackBar(
              result.error ?? 'Failed to make habit public',
              backgroundColor: Colors.red,
            );
          }
        },
      );
    }

    if (Platform.isIOS) {
      showCupertinoModalPopup(context: context, builder: buildMakePublicDialog);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: buildMakePublicDialog,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = SafeArea(
      child: Column(
        children: [
          _buildCustomHeader(),
          Expanded(
            child: ListView(
              children: [
                _buildHabitHeader(),
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
                  onAddContent: () => _navigateToEditHabit(),
                  communityPhrases: _viewModel.communityPhrases,
                ),
              ],
            ),
          ),
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

  Widget _buildCustomHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Platform.isIOS ? CupertinoIcons.xmark : Icons.close,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          if (_viewModel.canMakePublic)
            IconButton(
              icon: Icon(
                Platform.isIOS ? CupertinoIcons.globe : Icons.public,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _showMakePublicDialog,
            ),
          IconButton(
            icon: Icon(
              Platform.isIOS ? CupertinoIcons.pencil : Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => _navigateToEditHabit(),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditHabit() async {
    final route = Platform.isIOS
        ? CupertinoPageRoute(
            builder: (_) => AddHabitScreen(habitToEdit: _viewModel.habit),
          )
        : MaterialPageRoute(
            builder: (_) => AddHabitScreen(habitToEdit: _viewModel.habit),
          );

    await Navigator.push(context, route);
    if (mounted) {
      await _viewModel.refreshHabit();
    }
  }

  Widget _buildHabitHeader() {
    final habit = _viewModel.habit;
    final color = _viewModel.habitColor;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HabitIcon(iconName: habit.icon, size: 40, color: color),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Text(
                habit.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (habit.communityId != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (habit.communityId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityDetailScreen(
                            communityId: habit.communityId!,
                            communityName: habit.communityName ?? habit.name,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Platform.isIOS
                              ? CupertinoIcons.person_2_fill
                              : Icons.people,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          habit.communityName ?? 'Community',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
