import 'package:flutter/material.dart';
import 'package:katomik/core/utils/date_utils.dart';

class DateHeader extends StatelessWidget {
  final List<DateTime> dates;

  const DateHeader({
    super.key,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 60), // Space for habit icons
          ...dates.map((date) {
            final isToday = HomeDateUtils.isSameDay(date, today);
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    HomeDateUtils.getWeekdayAbbreviation(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    HomeDateUtils.getDayNumber(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}