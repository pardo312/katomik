import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/providers/community_provider.dart';
import 'package:katomik/core/utils/date_utils.dart';
import 'package:katomik/core/utils/color_utils.dart';
import 'package:katomik/features/home/widgets/date_header.dart';
import 'package:katomik/features/home/widgets/habit_row.dart';
import 'package:katomik/features/habit/add_habit/add_habit_screen.dart';
import 'package:katomik/features/habit/widgets/habit_icon.dart';
import 'package:katomik/features/community/widgets/make_habit_public_dialog.dart';
import 'package:katomik/features/community/screens/community_detail_screen.dart';
import 'dart:io';
import 'package:katomik/features/habit/habit_detail/widgets/floating_phrase.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenNewState();
}

class _HabitDetailScreenNewState extends State<HabitDetailScreen>
    with TickerProviderStateMixin {
  late Habit _habit;
  late DateTime _focusedMonth;
  late AnimationController _floatingAnimationController;

  final List<Map<String, dynamic>> _communityPhrases = [
    {'name': 'Brandon Anderson', 'avatar': '🎮', 'streak': 3},
    {'name': 'Jane Martinez', 'avatar': '👩‍🦰', 'streak': 4},
    {'name': 'Sebas Alzate', 'avatar': '👨‍💼', 'streak': 2},
  ];

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _focusedMonth = DateTime.now();
    _loadCompletions();
    _initializeDateFormatting();

    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('es', null);
  }

  @override
  void dispose() {
    _floatingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletions() async {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    await provider.getCompletionsForHabit(_habit.id!);
    // Force a rebuild to update the calendar
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _showPlatformSnackBar(
    String message, {
    Color? backgroundColor,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    if (Platform.isIOS) {
      // For iOS, we can show a simple dialog or use a different approach
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

  bool _isDateCompleted(DateTime date) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    return habitProvider.isHabitCompletedOnDate(_habit.id!, date);
  }

  void _showMakePublicDialog() {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => MakeHabitPublicDialog(
          habitName: _habit.name,
          onMakePublic: (settings) async {
            Navigator.pop(context);

            final communityProvider = context.read<CommunityProvider>();
            final habitProvider = context.read<HabitProvider>();

            final success = await communityProvider.makeHabitPublic(
              _habit,
              settings,
              habitProvider,
            );

            if (success) {
              if (mounted) {
                // Refresh habit data
                final updatedHabit = habitProvider.habits.firstWhere(
                  (h) => h.id == _habit.id,
                );
                setState(() {
                  _habit = updatedHabit;
                });

                // Store the community info before showing the snackbar
                final communityId = updatedHabit.communityId;
                final communityName = updatedHabit.name;
                final navContext = context;

                _showPlatformSnackBar(
                  '${_habit.name} is now public!',
                  backgroundColor: Colors.green,
                  actionLabel: 'View Community',
                  onActionPressed: () {
                    if (communityId != null) {
                      Navigator.push(
                        navContext,
                        MaterialPageRoute(
                          builder: (_) => CommunityDetailScreen(
                            communityId: communityId,
                            communityName: communityName,
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            } else {
              if (mounted) {
                final errorMessage = communityProvider.error ?? 'Failed to make habit public';
                
                // If habit is already public, refresh the habit data
                if (errorMessage.contains('already shared with the community')) {
                  try {
                    final updatedHabit = habitProvider.habits.firstWhere(
                      (h) => h.id == _habit.id,
                    );
                    setState(() {
                      _habit = updatedHabit;
                    });
                  } catch (e) {
                    // Habit not found in provider - this shouldn't happen but handle gracefully
                    debugPrint('Could not find updated habit in provider');
                  }
                }
                
                _showPlatformSnackBar(
                  errorMessage,
                  backgroundColor: Colors.red,
                );
              }
            }
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => MakeHabitPublicDialog(
          habitName: _habit.name,
          onMakePublic: (settings) async {
            Navigator.pop(context);

            final communityProvider = context.read<CommunityProvider>();
            final habitProvider = context.read<HabitProvider>();

            final success = await communityProvider.makeHabitPublic(
              _habit,
              settings,
              habitProvider,
            );

            if (success) {
              if (mounted) {
                // Refresh habit data
                final updatedHabit = habitProvider.habits.firstWhere(
                  (h) => h.id == _habit.id,
                );
                setState(() {
                  _habit = updatedHabit;
                });

                // Store the community info before showing the snackbar
                final communityId = updatedHabit.communityId;
                final communityName = updatedHabit.name;
                final navContext = context;

                _showPlatformSnackBar(
                  '${_habit.name} is now public!',
                  backgroundColor: Colors.green,
                  actionLabel: 'View Community',
                  onActionPressed: () {
                    if (communityId != null) {
                      Navigator.push(
                        navContext,
                        MaterialPageRoute(
                          builder: (_) => CommunityDetailScreen(
                            communityId: communityId,
                            communityName: communityName,
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            } else {
              if (mounted) {
                final errorMessage = communityProvider.error ?? 'Failed to make habit public';
                
                // If habit is already public, refresh the habit data
                if (errorMessage.contains('already shared with the community')) {
                  try {
                    final updatedHabit = habitProvider.habits.firstWhere(
                      (h) => h.id == _habit.id,
                    );
                    setState(() {
                      _habit = updatedHabit;
                    });
                  } catch (e) {
                    // Habit not found in provider - this shouldn't happen but handle gracefully
                    debugPrint('Could not find updated habit in provider');
                  }
                }
                
                _showPlatformSnackBar(
                  errorMessage,
                  backgroundColor: Colors.red,
                );
              }
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.parseColor(_habit.color);

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomHeader(),
              Expanded(
                child: ListView(
                  children: [
                    _buildHabitHeader(color),
                    _buildWeeklyTracker(color),
                    _buildCalendar(color),
                    _buildWhySection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: ListView(
                children: [
                  _buildHabitHeader(color),
                  _buildWeeklyTracker(color),
                  _buildCalendar(color),
                  _buildWhySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    // Show Make Public button only if habit is not a community habit
    final bool canMakePublic = _habit.communityId == null;

    debugPrint('Habit Detail - Name: ${_habit.name}');
    debugPrint('Habit Detail - ID: ${_habit.id}');
    debugPrint('Habit Detail - communityId: ${_habit.communityId}');

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
          // Make Public Button for habits not associated with any community
          if (canMakePublic)
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
            onPressed: () async {
              final provider = Provider.of<HabitProvider>(
                context,
                listen: false,
              );
              await Navigator.push(
                context,
                Platform.isIOS
                    ? CupertinoPageRoute(
                        builder: (_) => AddHabitScreen(habitToEdit: _habit),
                      )
                    : MaterialPageRoute(
                        builder: (_) => AddHabitScreen(habitToEdit: _habit),
                      ),
              );
              if (!mounted) return;
              // Refresh habit data
              final updatedHabit = provider.habits.firstWhere(
                (h) => h.id == _habit.id,
              );
              setState(() {
                _habit = updatedHabit;
              });
              _loadCompletions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHabitHeader(Color color) {
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
              child: HabitIcon(iconName: _habit.icon, size: 40, color: color),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Text(
                _habit.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_habit.communityId != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (_habit.communityId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityDetailScreen(
                            communityId: _habit.communityId!,
                            communityName: _habit.communityName ?? _habit.name,
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
                          _habit.communityName ?? 'Community',
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

  Widget _buildWeeklyTracker(Color color) {
    final dates = HomeDateUtils.getLastNDays(5);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DateHeader(dates: dates, showIconSpace: false),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: 1,
              ),
            ),
            child: Consumer<HabitProvider>(
              builder: (context, habitProvider, _) => HabitRow(
                habit: _habit,
                dates: dates,
                onToggleCompletion: (habitId, date) async {
                  await habitProvider.toggleHabitCompletion(habitId, date);
                  // Reload completions to update the local state
                  _loadCompletions();
                },
                isCompleted: (habitId, date) {
                  return habitProvider.isHabitCompletedOnDate(habitId, date);
                },
                showIcon: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(Color color) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Platform.isIOS
                            ? CupertinoIcons.chevron_left
                            : Icons.chevron_left,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _navigateToPreviousMonth,
                    ),
                    Text(
                      _getMonthName(_focusedMonth).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Platform.isIOS
                            ? CupertinoIcons.chevron_right
                            : Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _navigateToNextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<HabitProvider>(
                  builder: (context, habitProvider, _) =>
                      _buildCalendarGrid(color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Color color) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['d', 'l', 'm', 'm', 'j', 'v', 's']
              .map(
                (day) => SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        _buildCalendarWeeks(firstWeekday, daysInMonth, color),
      ],
    );
  }

  Widget _buildCalendarWeeks(int firstWeekday, int daysInMonth, Color color) {
    List<Widget> weeks = [];

    for (int weekStart = 0; weekStart < 42; weekStart += 7) {
      weeks.add(
        _buildCalendarWeek(weekStart, firstWeekday, daysInMonth, color),
      );
      if (weekStart + 7 - firstWeekday >= daysInMonth) break;
    }

    return Column(children: weeks);
  }

  Widget _buildCalendarWeek(
    int weekStartIndex,
    int firstWeekday,
    int daysInMonth,
    Color color,
  ) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: _buildWeekDays(
          weekStartIndex,
          firstWeekday,
          daysInMonth,
          color,
        ),
      ),
    );
  }

  List<Widget> _buildWeekDays(
    int weekStartIndex,
    int firstWeekday,
    int daysInMonth,
    Color color,
  ) {
    List<Widget> widgets = [];
    List<int> weekIndices = [];
    List<DateTime> weekDates = [];
    List<bool> weekCompleted = [];

    // Collect week data
    for (int i = 0; i < 7; i++) {
      int index = weekStartIndex + i;
      weekIndices.add(index);

      if (index >= firstWeekday && index < firstWeekday + daysInMonth) {
        final day = index - firstWeekday + 1;
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        weekDates.add(date);
        weekCompleted.add(_isDateCompleted(date));
      } else {
        weekDates.add(DateTime(0)); // Placeholder for out-of-month days
        weekCompleted.add(false);
      }
    }

    // Build widgets with grouping
    int i = 0;
    while (i < 7) {
      final index = weekIndices[i];
      final date = weekDates[i];
      final isCompleted = weekCompleted[i];
      final isValidDate = date.year != 0;

      if (isValidDate && isCompleted) {
        // Find consecutive completed days
        int groupStart = i;
        int groupEnd = i;

        while (groupEnd < 6 &&
            weekDates[groupEnd + 1].year != 0 &&
            weekCompleted[groupEnd + 1]) {
          groupEnd++;
        }

        if (groupEnd > groupStart) {
          // Multiple consecutive days
          widgets.add(
            _buildGroupedCalendarDays(
              weekDates.sublist(groupStart, groupEnd + 1),
              color,
              groupEnd - groupStart + 1,
            ),
          );
          i = groupEnd + 1;
        } else {
          // Single completed day
          widgets.add(
            _buildSingleCalendarDay(index, firstWeekday, daysInMonth, color),
          );
          i++;
        }
      } else {
        // Uncompleted or out-of-month day
        widgets.add(
          _buildSingleCalendarDay(index, firstWeekday, daysInMonth, color),
        );
        i++;
      }
    }

    return widgets;
  }

  Widget _buildGroupedCalendarDays(
    List<DateTime> dates,
    Color color,
    int count,
  ) {
    return Expanded(
      flex: count,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: dates.map((date) {
            final isToday = HomeDateUtils.isSameDay(date, DateTime.now());
            return Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (!date.isAfter(DateTime.now())) {
                    final habitProvider = Provider.of<HabitProvider>(
                      context,
                      listen: false,
                    );
                    await habitProvider.toggleHabitCompletion(_habit.id!, date);
                    _loadCompletions();
                  }
                },
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSingleCalendarDay(
    int index,
    int firstWeekday,
    int daysInMonth,
    Color color,
  ) {
    if (index < firstWeekday || index >= firstWeekday + daysInMonth) {
      final prevMonthLastDay = DateTime(
        _focusedMonth.year,
        _focusedMonth.month,
        0,
      ).day;
      final nextMonthDay = index - firstWeekday - daysInMonth + 1;
      final prevMonthDay = prevMonthLastDay - firstWeekday + index + 1;

      return Expanded(
        child: Center(
          child: Text(
            index < firstWeekday ? '$prevMonthDay' : '$nextMonthDay',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      );
    }

    final day = index - firstWeekday + 1;
    final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final isCompleted = _isDateCompleted(date);
    final isToday = HomeDateUtils.isSameDay(date, DateTime.now());

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (!date.isAfter(DateTime.now())) {
            final habitProvider = Provider.of<HabitProvider>(
              context,
              listen: false,
            );
            await habitProvider.toggleHabitCompletion(_habit.id!, date);
            _loadCompletions();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted
                  ? Colors.transparent
                  : isToday
                  ? color
                  : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
              width: isToday && !isCompleted ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isCompleted
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhySection() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Porque tienes este habito?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: Stack(
              children: [
                if (_habit.phrases.isEmpty && _habit.images.isEmpty)
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final provider = Provider.of<HabitProvider>(
                          context,
                          listen: false,
                        );
                        await Navigator.push(
                          context,
                          Platform.isIOS
                              ? CupertinoPageRoute(
                                  builder: (_) =>
                                      AddHabitScreen(habitToEdit: _habit),
                                )
                              : MaterialPageRoute(
                                  builder: (_) =>
                                      AddHabitScreen(habitToEdit: _habit),
                                ),
                        );
                        if (!mounted) return;
                        // Refresh habit data
                        final updatedHabit = provider.habits.firstWhere(
                          (h) => h.id == _habit.id,
                        );
                        setState(() {
                          _habit = updatedHabit;
                        });
                        _loadCompletions();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'add',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ..._buildFloatingUserPhrases(),
                ..._buildFloatingCommunityCards(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingUserPhrases() {
    final List<Widget> floatingElements = [];

    // Create different positions for floating elements
    final positions = [
      [const Offset(0.1, 0.1), const Offset(0.3, 0.2)],
      [const Offset(0.6, 0.2), const Offset(0.7, 0.1)],
      [const Offset(0.2, 0.3), const Offset(0.4, 0.4)],
      [const Offset(0.5, 0.05), const Offset(0.6, 0.15)],
      [const Offset(0.05, 0.4), const Offset(0.15, 0.5)],
      [const Offset(0.7, 0.35), const Offset(0.8, 0.45)],
      [const Offset(0.15, 0.25), const Offset(0.25, 0.35)],
    ];

    final colors = [
      Colors.white,
      Colors.black,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
    ];

    int positionIndex = 0;

    // Add phrases
    for (final phrase in _habit.phrases) {
      final posIndex = positionIndex % positions.length;
      final bgColor = colors[positionIndex % colors.length];
      final textColor = bgColor == Colors.white ? Colors.black : Colors.white;

      floatingElements.add(
        FloatingPhrase(
          animation: _floatingAnimationController,
          startPosition: positions[posIndex][0],
          endPosition: positions[posIndex][1],
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              phrase,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: Platform.isIOS ? '.SF UI Display' : 'Roboto',
              ),
            ),
          ),
        ),
      );
      positionIndex++;
    }

    // Add images
    for (final imagePath in _habit.images) {
      final posIndex = positionIndex % positions.length;

      floatingElements.add(
        FloatingPhrase(
          animation: _floatingAnimationController,
          startPosition: positions[posIndex][0],
          endPosition: positions[posIndex][1],
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Platform.isIOS ? CupertinoIcons.photo : Icons.image,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      positionIndex++;
    }

    return floatingElements;
  }

  List<Widget> _buildFloatingCommunityCards() {
    return _communityPhrases.asMap().entries.map((entry) {
      final index = entry.key;
      final phrase = entry.value;

      return FloatingPhrase(
        animation: _floatingAnimationController,
        startPosition: Offset(0.1 + index * 0.3, 0.5 + index * 0.1),
        endPosition: Offset(0.2 + index * 0.3, 0.6 + index * 0.1),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    phrase['avatar'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phrase['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'x${phrase['streak']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _getMonthName(DateTime date) {
    const months = [
      'ENERO',
      'FEBRERO',
      'MARZO',
      'ABRIL',
      'MAYO',
      'JUNIO',
      'JULIO',
      'AGOSTO',
      'SEPTIEMBRE',
      'OCTUBRE',
      'NOVIEMBRE',
      'DICIEMBRE',
    ];
    return months[date.month - 1];
  }
}
