import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:katomik/data/models/habit.dart';
import 'package:katomik/data/models/habit_completion.dart';
import 'package:katomik/providers/habit_provider.dart';
import 'package:katomik/shared/widgets/adaptive_widgets.dart';
import 'package:katomik/core/utils/date_utils.dart';
import 'package:katomik/features/habit/widgets/habit_icon.dart';
import 'package:katomik/features/home/widgets/date_header.dart';
import 'package:katomik/features/home/widgets/habit_row.dart';
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
  DateTime _focusedMonth = DateTime.now();
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
        ],
      ),
    );
  }

  Widget _buildWeeklyTracker(Color color) {
    final dates = HomeDateUtils.getLastNDays(5);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DateHeader(dates: dates),
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            if (index < firstWeekday || index >= firstWeekday + daysInMonth) {
              final prevMonthLastDay = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                0,
              ).day;
              final nextMonthDay = index - firstWeekday - daysInMonth + 1;
              final prevMonthDay = prevMonthLastDay - firstWeekday + index + 1;

              return Center(
                child: Text(
                  index < firstWeekday ? '$prevMonthDay' : '$nextMonthDay',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              );
            }

            final day = index - firstWeekday + 1;
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final isCompleted = _isDateCompleted(date);
            final isToday = HomeDateUtils.isSameDay(date, DateTime.now());

            return GestureDetector(
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
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isCompleted
                      ? Border.all(color: color, width: 2)
                      : null,
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
            );
          },
        ),
      ],
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
        startPosition: const Offset(0.1, 0.1),
        endPosition: const Offset(0.3, 0.2),
      ),
      _FloatingPhrase(
        animation: _floatingAnimationController,
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
        startPosition: const Offset(0.6, 0.2),
        endPosition: const Offset(0.7, 0.1),
      ),
    ];
  }

  List<Widget> _buildFloatingCommunityCards() {
    return _communityPhrases.asMap().entries.map((entry) {
      final index = entry.key;
      final phrase = entry.value;

      return _FloatingPhrase(
        animation: _floatingAnimationController,
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
        startPosition: Offset(0.1 + index * 0.3, 0.5 + index * 0.1),
        endPosition: Offset(0.2 + index * 0.3, 0.6 + index * 0.1),
      );
    }).toList();
  }

  String _getDayAbbreviation(DateTime date) {
    const days = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM'];
    return days[date.weekday - 1];
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
