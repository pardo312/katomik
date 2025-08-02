import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/data/models/habit_completion.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/core/utils/date_utils.dart';
import 'package:katomik/features/home/widgets/date_header.dart';
import 'package:katomik/features/home/widgets/habit_row.dart';
import 'package:katomik/features/habit/screens/add_habit_screen.dart';
import 'package:katomik/features/habit/widgets/habit_icon.dart';
import 'dart:io';
import 'dart:math' as math;

class HabitDetailScreenNew extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreenNew({super.key, required this.habit});

  @override
  State<HabitDetailScreenNew> createState() => _HabitDetailScreenNewState();
}

class _HabitDetailScreenNewState extends State<HabitDetailScreenNew>
    with TickerProviderStateMixin {
  late Habit _habit;
  final DateTime _focusedMonth = DateTime.now();
  List<HabitCompletion> _completions = [];
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
    final completions = await provider.getCompletionsForHabit(_habit.id!);
    setState(() {
      _completions = completions;
    });
  }

  bool _isDateCompleted(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _completions.any(
      (c) => c.date.toIso8601String().split('T')[0] == dateStr && c.isCompleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(_habit.color));

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
          IconButton(
            icon: Icon(
              Platform.isIOS ? CupertinoIcons.pencil : Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              final provider = Provider.of<HabitProvider>(context, listen: false);
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
              final updatedHabit = provider.habits.firstWhere((h) => h.id == _habit.id);
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
              child: HabitIcon(
                iconName: _habit.icon,
                size: 40,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _habit.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
            child: HabitRow(
              habit: _habit,
              dates: dates,
              onToggleCompletion: (habitId, date) {
                Provider.of<HabitProvider>(
                  context,
                  listen: false,
                ).toggleHabitCompletion(habitId, date);
                _loadCompletions();
              },
              isCompleted: (habitId, date) => _isDateCompleted(date),
              showIcon: false,
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
                Text(
                  _getMonthName(_focusedMonth).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCalendarGrid(color),
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
                onTap: () {
                  if (!date.isAfter(DateTime.now())) {
                    Provider.of<HabitProvider>(
                      context,
                      listen: false,
                    ).toggleHabitCompletion(_habit.id!, date);
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
        onTap: () {
          if (!date.isAfter(DateTime.now())) {
            Provider.of<HabitProvider>(
              context,
              listen: false,
            ).toggleHabitCompletion(_habit.id!, date);
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
    return [
      _FloatingPhrase(
        animation: _floatingAnimationController,
        startPosition: const Offset(0.1, 0.1),
        endPosition: const Offset(0.3, 0.2),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/discipline.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'DISCIPLINE\nBEATS\nMOTIVATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      _FloatingPhrase(
        animation: _floatingAnimationController,
        startPosition: const Offset(0.6, 0.2),
        endPosition: const Offset(0.7, 0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'Aquí todos\nestamos locos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: Platform.isIOS ? '.SF UI Display' : 'Roboto',
                ),
              ),
              const SizedBox(height: 8),
              const Text('😀 😀', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildFloatingCommunityCards() {
    return _communityPhrases.asMap().entries.map((entry) {
      final index = entry.key;
      final phrase = entry.value;

      return _FloatingPhrase(
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

class _FloatingPhrase extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset startPosition;
  final Offset endPosition;

  const _FloatingPhrase({
    required this.animation,
    required this.child,
    required this.startPosition,
    required this.endPosition,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        final x =
            startPosition.dx +
            (endPosition.dx - startPosition.dx) * math.sin(value * 2 * math.pi);
        final y =
            startPosition.dy +
            (endPosition.dy - startPosition.dy) * math.cos(value * 2 * math.pi);

        return Positioned(
          left: x * MediaQuery.of(context).size.width * 0.8,
          top: y * 400,
          child: Transform.scale(
            scale: 0.9 + 0.1 * math.sin(value * 4 * math.pi),
            child: this.child,
          ),
        );
      },
    );
  }
}
